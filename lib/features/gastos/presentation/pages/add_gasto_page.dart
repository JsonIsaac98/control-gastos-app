import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../../categorias/presentation/widgets/categoria_chip.dart';
import '../../../categorias/providers/categorias_provider.dart';
import '../../../tarjetas/domain/entities/tarjeta_entity.dart';
import '../../../tarjetas/providers/tarjetas_provider.dart';
import '../../domain/entities/gasto_entity.dart';
import '../../providers/cuotas_provider.dart';
import '../../providers/gastos_provider.dart';

// TODO: imports de foto desactivados temporalmente
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../providers/receipt_storage_provider.dart';

class AddGastoPage extends ConsumerStatefulWidget {
  const AddGastoPage({super.key});

  @override
  ConsumerState<AddGastoPage> createState() => _AddGastoPageState();
}

class _AddGastoPageState extends ConsumerState<AddGastoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();

  TipoPago _tipoPago = TipoPago.efectivo;
  DateTime _fecha = DateTime.now();
  String? _categoriaId;
  bool _guardando = false;
  // Tarjeta y cuotas
  TarjetaEntity? _tarjetaSeleccionada;
  bool _esCuota = false;
  int _numeroCuotas = 3;
  String _frecuenciaCuotas = 'mensual';
  // TODO: estado de foto desactivado temporalmente
  // File? _fotoFile;
  // String? _fotoUrl;

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final tarjetasAsync = ref.watch(tarjetasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Monto (primero, es lo más importante)
            _MontoField(controller: _montoController),
            const SizedBox(height: 20),

            // Descripción
            TextFormField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Supermercado, gasolina...',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 200,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Tipo de pago
            _TipoPagoSelector(
              selected: _tipoPago,
              onChanged: (tipo) => setState(() {
                _tipoPago = tipo;
                // Limpiar cuotas si cambia a otro tipo de pago
                if (tipo != TipoPago.tarjetaCredito) {
                  _esCuota = false;
                }
              }),
            ),
            const SizedBox(height: 20),

            // Selector de tarjeta (solo para tarjeta de crédito)
            if (_tipoPago == TipoPago.tarjetaCredito) ...[
              _TarjetaSelector(
                tarjetasAsync: tarjetasAsync,
                seleccionada: _tarjetaSeleccionada,
                onChanged: (t) => setState(() {
                  _tarjetaSeleccionada = t;
                }),
              ),
              const SizedBox(height: 16),
            ],

            // Cuotas (solo para tarjeta de crédito)
            if (_tipoPago == TipoPago.tarjetaCredito) ...[
              _CuotasSection(
                esCuota: _esCuota,
                numeroCuotas: _numeroCuotas,
                frecuenciaCuotas: _frecuenciaCuotas,
                diaCorte: _tarjetaSeleccionada?.diaCorte ?? 1,
                montoTotal: double.tryParse(
                      _montoController.text.replaceAll(',', '.'),
                    ) ??
                    0,
                onEsCuotaChanged: (v) => setState(() => _esCuota = v),
                onNumeroCuotasChanged: (v) =>
                    setState(() => _numeroCuotas = v),
                onFrecuenciaCuotasChanged: (v) =>
                    setState(() => _frecuenciaCuotas = v),
                onDiaCorteChanged: null, // el día de corte viene de la tarjeta
              ),
              const SizedBox(height: 20),
            ],

            // Categoría (opcional)
            Text(
              'Categoría (opcional)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            categoriasAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (cats) => cats.isEmpty
                  ? Text(
                      'Sin categorías. Sincroniza para cargarlas.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cats
                          .map(
                            (c) => CategoriaChip(
                              categoria: c,
                              isSelected: _categoriaId == c.id,
                              onTap: () => setState(() {
                                _categoriaId =
                                    _categoriaId == c.id ? null : c.id;
                              }),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 20),

            // Fecha
            _FechaField(
              fecha: _fecha,
              onChanged: (fecha) => setState(() => _fecha = fecha),
            ),

            // TODO: sección foto desactivada temporalmente
            // const SizedBox(height: 20),
            // _FotoReciboSection(
            //   fotoFile: _fotoFile,
            //   fotoUrl: _fotoUrl,
            //   onFotoSelected: (file) => setState(() {
            //     _fotoFile = file; _fotoUrl = null;
            //   }),
            //   onFotoRemoved: () => setState(() {
            //     _fotoFile = null; _fotoUrl = null;
            //   }),
            // ),
            const SizedBox(height: 32),

            // Botón guardar
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_guardando ? 'Guardando...' : 'Guardar Gasto'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final monto = double.tryParse(
            _montoController.text.replaceAll(',', '.'),
          ) ??
          0;

      // TODO: upload de foto desactivado temporalmente
      // String? uploadedFotoUrl = _fotoUrl;
      // if (_fotoFile != null) { ... }

      final esCuotaFinal =
          _tipoPago == TipoPago.tarjetaCredito && _esCuota;

      // Si es cuota, guardar el monto por cuota (total / número de cuotas)
      final montoGuardado = esCuotaFinal && _numeroCuotas > 1
          ? monto / _numeroCuotas
          : monto;

      final diaCorte = _tarjetaSeleccionada?.diaCorte ?? 1;

      final gasto = GastoEntity(
        descripcion: _descripcionController.text.trim(),
        monto: montoGuardado,
        tipoPago: _tipoPago,
        fecha: _fecha,
        categoriaId: _categoriaId,
        fotoUrl: null, // TODO: reactivar con uploadedFotoUrl
        esCuota: esCuotaFinal,
        numeroCuotas: esCuotaFinal ? _numeroCuotas : null,
        frecuenciaCuotas: esCuotaFinal ? _frecuenciaCuotas : null,
        tarjetaId: _tarjetaSeleccionada?.id,
      );

      final gastoGuardado =
          await ref.read(gastosDelMesProvider.notifier).addGasto(gasto);

      // Crear registros de cuotas programadas
      if (esCuotaFinal && _numeroCuotas > 1) {
        await ref
            .read(cuotasLocalDatasourceProvider)
            .crearCuotasProgramadas(
              gastoOrigen: gastoGuardado,
              diaCorte: diaCorte,
            );
        ref.invalidate(cuotasPendientesProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gasto guardado correctamente'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
}

class _MontoField extends StatelessWidget {
  const _MontoField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Monto',
        hintText: '0.00',
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: 'Q ',
        prefixStyle: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Ingresa el monto';
        final parsed = double.tryParse(v.replaceAll(',', '.'));
        if (parsed == null || parsed <= 0) return 'Ingresa un monto válido';
        return null;
      },
    );
  }
}

class _TipoPagoSelector extends StatelessWidget {
  const _TipoPagoSelector({
    required this.selected,
    required this.onChanged,
  });

  final TipoPago selected;
  final ValueChanged<TipoPago> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de pago',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<TipoPago>(
          segments: TipoPago.values
              .map(
                (tipo) => ButtonSegment<TipoPago>(
                  value: tipo,
                  icon: Icon(_iconForTipo(tipo)),
                  label: Text(
                    tipo.label,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              )
              .toList(),
          selected: {selected},
          onSelectionChanged: (set) => onChanged(set.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  IconData _iconForTipo(TipoPago tipo) {
    return switch (tipo) {
      TipoPago.efectivo => Icons.money,
      TipoPago.tarjetaCredito => Icons.credit_card,
      TipoPago.transferencia => Icons.swap_horiz,
    };
  }
}

class _FechaField extends StatelessWidget {
  const _FechaField({required this.fecha, required this.onChanged});

  final DateTime fecha;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickDate(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          fecha.formattedDate,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }
}

// ----------------------------------------------------------------
// Selector de tarjeta de crédito
// ----------------------------------------------------------------
class _TarjetaSelector extends StatelessWidget {
  const _TarjetaSelector({
    required this.tarjetasAsync,
    required this.seleccionada,
    required this.onChanged,
  });

  final AsyncValue<List<TarjetaEntity>> tarjetasAsync;
  final TarjetaEntity? seleccionada;
  final ValueChanged<TarjetaEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return tarjetasAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (tarjetas) {
        if (tarjetas.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16,
                    color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Configura tus tarjetas en Ajustes → Tarjetas de crédito',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarjeta',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Opción "Sin especificar"
                _TarjetaChip(
                  label: 'Sin especificar',
                  colorHex: null,
                  isSelected: seleccionada == null,
                  onTap: () => onChanged(null),
                ),
                ...tarjetas.map(
                  (t) => _TarjetaChip(
                    label: t.nombre,
                    colorHex: t.color,
                    isSelected: seleccionada?.id == t.id,
                    onTap: () => onChanged(
                      seleccionada?.id == t.id ? null : t,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaChip extends StatelessWidget {
  const _TarjetaChip({
    required this.label,
    required this.colorHex,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String? colorHex;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cardColor = colorHex != null
        ? Color(int.parse(colorHex!.replaceFirst('#', '0xFF')))
        : cs.outline;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? cardColor.withValues(alpha: 0.15)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? cardColor : cs.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card,
                size: 14,
                color: isSelected ? cardColor : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? cardColor : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CuotasSection extends StatelessWidget {
  const _CuotasSection({
    required this.esCuota,
    required this.numeroCuotas,
    required this.frecuenciaCuotas,
    required this.diaCorte,
    required this.montoTotal,
    required this.onEsCuotaChanged,
    required this.onNumeroCuotasChanged,
    required this.onFrecuenciaCuotasChanged,
    required this.onDiaCorteChanged,  // null = día de corte viene de la tarjeta
  });

  final bool esCuota;
  final int numeroCuotas;
  final String frecuenciaCuotas;
  final int diaCorte;
  final double montoTotal;
  final ValueChanged<bool> onEsCuotaChanged;
  final ValueChanged<int> onNumeroCuotasChanged;
  final ValueChanged<String> onFrecuenciaCuotasChanged;
  final ValueChanged<int>? onDiaCorteChanged;

  static const _frecuencias = ['mensual', 'quincenal', 'semanal'];
  static const _frecuenciaLabels = {
    'mensual': 'Mensual',
    'quincenal': 'Quincenal',
    'semanal': 'Semanal',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Toggle principal
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            secondary: Icon(
              Icons.view_list_outlined,
              color: esCuota ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            title: Text(
              'Compra a cuotas',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            value: esCuota,
            onChanged: onEsCuotaChanged,
          ),

          // Detalle de cuotas (solo si está activado)
          if (esCuota) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila 1: # cuotas + frecuencia
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Número de cuotas',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _StepButton(
                                  icon: Icons.remove,
                                  onPressed: numeroCuotas > 2
                                      ? () => onNumeroCuotasChanged(
                                          numeroCuotas - 1)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$numeroCuotas',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _StepButton(
                                  icon: Icons.add,
                                  onPressed: numeroCuotas < 60
                                      ? () => onNumeroCuotasChanged(
                                          numeroCuotas + 1)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Frecuencia',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: frecuenciaCuotas,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              items: _frecuencias
                                  .map(
                                    (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(_frecuenciaLabels[f]!),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) onFrecuenciaCuotasChanged(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Fila 2: día de corte
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Día de corte',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Si viene de la tarjeta, mostrar info-only
                            if (onDiaCorteChanged == null)
                              InputDecorator(
                                decoration: const InputDecoration(
                                  isDense: true,
                                  prefixIcon: Icon(Icons.event_outlined),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                child: Text(
                                  'Día $diaCorte (de la tarjeta)',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              )
                            else
                              DropdownButtonFormField<int>(
                                value: diaCorte,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  prefixIcon: Icon(Icons.event_outlined),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                ),
                                items: List.generate(
                                  28,
                                  (i) => DropdownMenuItem(
                                    value: i + 1,
                                    child: Text('Día ${i + 1}'),
                                  ),
                                ),
                                onChanged: (v) {
                                  if (v != null) onDiaCorteChanged!(v);
                                },
                              ),
                          ],
                        ),
                      ),
                      // Resumen de monto por cuota
                      if (montoTotal > 0) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Por cuota',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  'Q ${(montoTotal / numeroCuotas).toStringAsFixed(2)}',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                Text(
                                  '× $numeroCuotas cuotas',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Icon(icon, size: 18),
    );
  }
}

// TODO: _FotoReciboSection desactivada temporalmente.
// Para reactivar: descomentar, añadir image_picker en pubspec.yaml y
// restaurar los imports de dart:io, image_picker y receipt_storage_provider.

/*
class _FotoReciboSection extends StatelessWidget {
  const _FotoReciboSection({
    required this.fotoFile,
    required this.fotoUrl,
    required this.onFotoSelected,
    required this.onFotoRemoved,
  });

  final File? fotoFile;
  final String? fotoUrl;
  final ValueChanged<File> onFotoSelected;
  final VoidCallback onFotoRemoved;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = fotoFile != null || fotoUrl != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto del recibo (opcional)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        if (hasPhoto)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: fotoFile != null
                    ? Image.file(fotoFile!,
                        height: 160, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(fotoUrl!,
                        height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: onFotoRemoved,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Cámara'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galería'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, imageQuality: 80, maxWidth: 1200);
    if (picked != null) onFotoSelected(File(picked.path));
  }
}
*/
