-- ============================================================
-- BD/schema.sql — Gastos Personal · Supabase PostgreSQL
-- ============================================================
-- Ejecutar en: Supabase Dashboard → SQL Editor → New query
--
-- NOTA: auth.users ya es gestionado automáticamente por Supabase Auth.
--       Este script crea todas las tablas públicas con RLS.
-- ============================================================


-- ----------------------------------------------------------------
-- Tabla: gastos
-- Almacena todos los gastos de cada usuario autenticado.
-- ----------------------------------------------------------------
create table if not exists public.gastos (
  id                uuid          primary key default gen_random_uuid(),
  user_id           uuid          not null references auth.users (id) on delete cascade,
  descripcion       text          not null,
  monto             numeric(12,2) not null,
  -- Valores válidos: 'efectivo' | 'tarjeta_credito' | 'transferencia'
  tipo_pago         text          not null,
  fecha             timestamptz   not null,
  created_at        timestamptz   not null default now(),
  updated_at        timestamptz   not null default now(),

  -- Categoría (schema v4)
  categoria_id      uuid          references public.categorias (id) on delete set null,

  -- Foto del recibo en Supabase Storage (schema v5)
  foto_url          text,

  -- Cuotas de tarjeta de crédito (schema v6)
  es_cuota          boolean       not null default false,
  numero_cuotas     smallint,
  -- Valores válidos: 'mensual' | 'quincenal' | 'semanal'
  frecuencia_cuotas text,

  -- Restricciones de integridad
  constraint gastos_descripcion_length    check (char_length(descripcion) between 1 and 200),
  constraint gastos_monto_positivo        check (monto > 0),
  constraint gastos_tipo_pago_valido      check (
    tipo_pago in ('efectivo', 'tarjeta_credito', 'transferencia')
  ),
  constraint gastos_numero_cuotas_rango   check (numero_cuotas is null or (numero_cuotas >= 1 and numero_cuotas <= 60)),
  constraint gastos_frecuencia_cuotas_valida check (
    frecuencia_cuotas is null or frecuencia_cuotas in ('mensual', 'quincenal', 'semanal')
  ),
  -- Las cuotas solo aplican a tarjeta de crédito
  constraint gastos_cuotas_solo_tarjeta   check (
    not es_cuota or tipo_pago = 'tarjeta_credito'
  )
);

-- ----------------------------------------------------------------
-- Tabla: tarjetas_credito
-- Tarjetas de crédito del usuario con su día de corte.
-- ----------------------------------------------------------------
create table if not exists public.tarjetas_credito (
  id          text        primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  nombre      text        not null,
  dia_corte   smallint    not null,
  color       text,
  is_default  boolean     not null default false,
  orden       smallint    not null default 0,
  created_at  timestamptz not null default now(),

  constraint tarjetas_dia_corte_rango check (dia_corte >= 1 and dia_corte <= 28)
);

alter table public.tarjetas_credito enable row level security;

create policy "tarjetas_select_own"
  on public.tarjetas_credito for select
  using (auth.uid() = user_id);

create policy "tarjetas_insert_own"
  on public.tarjetas_credito for insert
  with check (auth.uid() = user_id);

create policy "tarjetas_update_own"
  on public.tarjetas_credito for update
  using (auth.uid() = user_id);

create policy "tarjetas_delete_own"
  on public.tarjetas_credito for delete
  using (auth.uid() = user_id);


-- ----------------------------------------------------------------
-- Tabla: categorias
-- Categorías de gastos (defaults del sistema + personales del usuario)
-- ----------------------------------------------------------------
create table if not exists public.categorias (
  id          uuid    primary key default gen_random_uuid(),
  user_id     uuid    references auth.users (id) on delete cascade,
  nombre      text    not null,
  icono       text,
  color       text,
  es_default  boolean not null default false
);

-- ----------------------------------------------------------------
-- Tabla: cuotas_programadas
-- Seguimiento de cada cuota de una compra a plazos.
-- ----------------------------------------------------------------
create table if not exists public.cuotas_programadas (
  id                    uuid        primary key default gen_random_uuid(),
  gasto_origen_id       uuid        not null references public.gastos (id) on delete cascade,
  descripcion           text        not null,
  numero_cuota          smallint    not null,
  total_cuotas          smallint    not null,
  monto                 numeric(12,2) not null,
  fecha_vencimiento     timestamptz not null,
  is_pagado             boolean     not null default false,
  fecha_pagado          timestamptz,
  gasto_registrado_id   uuid        references public.gastos (id) on delete set null,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),

  constraint cuotas_numero_valido check (numero_cuota >= 1 and numero_cuota <= total_cuotas),
  constraint cuotas_total_valido  check (total_cuotas >= 2 and total_cuotas <= 60)
);

create trigger cuotas_updated_at
  before update on public.cuotas_programadas
  for each row
  execute function public.set_updated_at();

alter table public.cuotas_programadas enable row level security;

-- El usuario ve las cuotas de sus gastos (vía join con gastos)
create policy "cuotas_select_own"
  on public.cuotas_programadas for select
  using (
    exists (
      select 1 from public.gastos g
      where g.id = gasto_origen_id and g.user_id = auth.uid()
    )
  );

create policy "cuotas_insert_own"
  on public.cuotas_programadas for insert
  with check (
    exists (
      select 1 from public.gastos g
      where g.id = gasto_origen_id and g.user_id = auth.uid()
    )
  );

create policy "cuotas_update_own"
  on public.cuotas_programadas for update
  using (
    exists (
      select 1 from public.gastos g
      where g.id = gasto_origen_id and g.user_id = auth.uid()
    )
  );


-- ----------------------------------------------------------------
-- Índices de rendimiento
-- ----------------------------------------------------------------
-- Consultas por usuario + fecha descendente (el patrón más común)
create index if not exists gastos_user_id_fecha_idx
  on public.gastos (user_id, fecha desc);

-- Categorías por usuario (incluye defaults donde user_id IS NULL)
create index if not exists categorias_user_id_idx
  on public.categorias (user_id);


-- ----------------------------------------------------------------
-- Función y trigger: actualiza updated_at automáticamente
-- ----------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger gastos_updated_at
  before update on public.gastos
  for each row
  execute function public.set_updated_at();


-- ----------------------------------------------------------------
-- Row Level Security (RLS) — gastos
-- Cada usuario SOLO puede ver y modificar SUS propios gastos.
-- ----------------------------------------------------------------
alter table public.gastos enable row level security;

create policy "gastos_select_own"
  on public.gastos for select
  using (auth.uid() = user_id);

create policy "gastos_insert_own"
  on public.gastos for insert
  with check (auth.uid() = user_id);

create policy "gastos_update_own"
  on public.gastos for update
  using (auth.uid() = user_id);

create policy "gastos_delete_own"
  on public.gastos for delete
  using (auth.uid() = user_id);


-- ----------------------------------------------------------------
-- Row Level Security (RLS) — categorias
-- ----------------------------------------------------------------
alter table public.categorias enable row level security;

-- El usuario ve sus categorías propias + las defaults del sistema
create policy "categorias_select_own_or_default"
  on public.categorias for select
  using (auth.uid() = user_id or user_id is null);

create policy "categorias_insert_own"
  on public.categorias for insert
  with check (auth.uid() = user_id);

create policy "categorias_update_own"
  on public.categorias for update
  using (auth.uid() = user_id);

create policy "categorias_delete_own"
  on public.categorias for delete
  using (auth.uid() = user_id);


-- ================================================================
-- MIGRACIONES — ejecutar solo en bases de datos existentes
-- (Si aplicas este script desde cero, ignora esta sección)
-- ================================================================

-- v4: categorias + categoria_id en gastos
-- alter table public.gastos add column if not exists categoria_id uuid references public.categorias (id) on delete set null;

-- v5: foto del recibo
-- alter table public.gastos add column if not exists foto_url text;

-- v8: tarjetas de crédito + tarjetaId en gastos y cuotas
-- create table if not exists public.tarjetas_credito (...); -- ver DDL completo arriba
-- alter table public.gastos add column if not exists tarjeta_id text references public.tarjetas_credito (id) on delete set null;
-- alter table public.cuotas_programadas add column if not exists tarjeta_id text references public.tarjetas_credito (id) on delete set null;

-- v7: tabla de cuotas programadas (ejecutar después de v6)
-- Crear la tabla con el DDL de arriba si aplica el script desde cero.
-- Solo ejecutar estas líneas si ya tienes la tabla gastos creada:
-- create table if not exists public.cuotas_programadas (...);  -- ver DDL completo arriba

-- v6: cuotas de tarjeta de crédito
-- alter table public.gastos add column if not exists es_cuota boolean not null default false;
-- alter table public.gastos add column if not exists numero_cuotas smallint;
-- alter table public.gastos add column if not exists frecuencia_cuotas text;
-- alter table public.gastos add constraint gastos_numero_cuotas_rango check (numero_cuotas is null or (numero_cuotas >= 1 and numero_cuotas <= 60));
-- alter table public.gastos add constraint gastos_frecuencia_cuotas_valida check (frecuencia_cuotas is null or frecuencia_cuotas in ('mensual', 'quincenal', 'semanal'));
-- alter table public.gastos add constraint gastos_cuotas_solo_tarjeta check (not es_cuota or tipo_pago = 'tarjeta_credito');
