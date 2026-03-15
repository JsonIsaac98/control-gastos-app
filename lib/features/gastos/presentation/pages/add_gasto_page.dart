import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../domain/entities/gasto_entity.dart';
import '../../providers/gastos_provider.dart';

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
  bool _guardando = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (tipo) => setState(() => _tipoPago = tipo),
            ),
            const SizedBox(height: 20),

            // Fecha
            _FechaField(
              fecha: _fecha,
              onChanged: (fecha) => setState(() => _fecha = fecha),
            ),
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

      final gasto = GastoEntity(
        descripcion: _descripcionController.text.trim(),
        monto: monto,
        tipoPago: _tipoPago,
        fecha: _fecha,
      );

      await ref.read(gastosDelMesProvider.notifier).addGasto(gasto);

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
