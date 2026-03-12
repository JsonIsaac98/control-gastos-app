-- ============================================================
-- BD/schema.sql — Gastos Personal · Supabase PostgreSQL
-- ============================================================
-- Ejecutar en: Supabase Dashboard → SQL Editor → New query
--
-- NOTA: auth.users ya es gestionado automáticamente por Supabase Auth.
--       Este script solo crea la tabla pública de gastos con RLS.
-- ============================================================


-- ----------------------------------------------------------------
-- Tabla: gastos
-- Almacena todos los gastos de cada usuario autenticado.
-- ----------------------------------------------------------------
create table if not exists public.gastos (
  id          uuid          primary key default gen_random_uuid(),
  user_id     uuid          not null references auth.users (id) on delete cascade,
  descripcion text          not null,
  monto       numeric(12,2) not null,
  -- Valores válidos: 'efectivo' | 'tarjeta_credito' | 'transferencia'
  tipo_pago   text          not null,
  fecha       timestamptz   not null,
  created_at  timestamptz   not null default now(),
  updated_at  timestamptz   not null default now(),

  -- Restricciones de integridad
  constraint gastos_descripcion_length check (char_length(descripcion) between 1 and 200),
  constraint gastos_monto_positivo     check (monto > 0),
  constraint gastos_tipo_pago_valido   check (
    tipo_pago in ('efectivo', 'tarjeta_credito', 'transferencia')
  )
);

-- ----------------------------------------------------------------
-- Índices de rendimiento
-- ----------------------------------------------------------------
-- Consultas por usuario + fecha descendente (el patrón más común)
create index if not exists gastos_user_id_fecha_idx
  on public.gastos (user_id, fecha desc);


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
-- Row Level Security (RLS)
-- Cada usuario SOLO puede ver y modificar SUS propios gastos.
-- Sin estas políticas cualquier usuario autenticado podría leer
-- los datos de otro usuario.
-- ----------------------------------------------------------------
alter table public.gastos enable row level security;

-- SELECT: solo los propios registros
create policy "gastos_select_own"
  on public.gastos
  for select
  using (auth.uid() = user_id);

-- INSERT: el campo user_id debe coincidir con el UID autenticado
create policy "gastos_insert_own"
  on public.gastos
  for insert
  with check (auth.uid() = user_id);

-- UPDATE: solo los propios registros
create policy "gastos_update_own"
  on public.gastos
  for update
  using (auth.uid() = user_id);

-- DELETE: solo los propios registros
create policy "gastos_delete_own"
  on public.gastos
  for delete
  using (auth.uid() = user_id);
