import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../../categorias/domain/entities/categoria_entity.dart';
import '../../../categorias/presentation/widgets/categoria_chip.dart';
import '../../../categorias/providers/categorias_provider.dart';
import '../../../gastos/providers/gastos_provider.dart';
import '../../domain/entities/presupuesto_entity.dart';
import '../../providers/presupuestos_provider.dart';

/// Genera un ID único basado en microsegundos
String _generateId() =>
    DateTime.now().microsecondsSinceEpoch.toRadixString(16).padLeft(32, '0');

class PresupuestosPage extends ConsumerStatefulWidget {
  const PresupuestosPage({super.key});

  @override
  ConsumerState<PresupuestosPage> createState() => _PresupuestosPageState();
}

class _PresupuestosPageState extends ConsumerState<PresupuestosPage> {
  late DateTime _mes;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mes = DateTime(now.year, now.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);
    final presupuestosAsync = ref.watch(presupuestosMesProvider(_mes));
    final resumenAsync = ref.watch(dashboardResumenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presupuestos'),
        actions: [
          // Navegación de mes
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _mes = DateTime(_mes.year, _mes.month - 1, 1);
            }),
          ),
          TextButton(
            onPressed: null,
            child: Text(
              _mes.monthYear,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final next = DateTime(_mes.year, _mes.month + 1, 1);
              if (!next.isAfter(DateTime.now())) {
                setState(() => _mes = next);
              }
            },
          ),
        ],
      ),
      body: categoriasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Sin categorías',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sincroniza para cargar las categorías disponibles.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return presupuestosAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (presupuestos) {
              // Mapa categoriaId → presupuesto
              final Map<String, PresupuestoEntity> pMap = {
                for (final p in presupuestos)
                  if (p.categoriaId != null) p.categoriaId!: p,
              };

              // Mapa categoriaId → gastado este mes
              final Map<String, double> gastadoMap = {};
              resumenAsync.whenData((resumen) {
                gastadoMap.addAll(resumen.totalPorCategoria);
              });

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: categorias.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final cat = categorias[index];
                  final presupuesto = pMap[cat.id];
                  final gastado = gastadoMap[cat.id] ?? 0.0;

                  return _PresupuestoItem(
                    categoria: cat,
                    presupuesto: presupuesto,
                    gastado: gastado,
                    mes: _mes,
                    onEdit: () => _showEditDialog(cat, presupuesto),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(
    CategoriaEntity cat,
    PresupuestoEntity? existing,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _PresupuestoDialog(
        categoria: cat,
        existing: existing,
        mes: _mes,
      ),
    );
  }
}

class _PresupuestoItem extends StatelessWidget {
  const _PresupuestoItem({
    required this.categoria,
    required this.presupuesto,
    required this.gastado,
    required this.mes,
    required this.onEdit,
  });

  final CategoriaEntity categoria;
  final PresupuestoEntity? presupuesto;
  final double gastado;
  final DateTime mes;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color =
        categoria.colorValue ?? Theme.of(context).colorScheme.primary;
    final limite = presupuesto?.montoLimite;

    double? progress;
    if (limite != null && limite > 0) {
      progress = (gastado / limite).clamp(0.0, 1.0);
    }

    final progressColor = progress == null
        ? color
        : progress >= 0.9
            ? Colors.red
            : progress >= 0.7
                ? Colors.orange
                : color;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoriaChip(categoria: categoria),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    presupuesto == null ? Icons.add_circle_outline : Icons.edit_outlined,
                    color: color,
                  ),
                  tooltip: presupuesto == null
                      ? 'Establecer presupuesto'
                      : 'Editar presupuesto',
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gastado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    Text(
                      gastado.toCurrency,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (limite != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Presupuesto',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      Text(
                        limite.toCurrency,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ] else
                  Text(
                    'Sin presupuesto',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% utilizado',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PresupuestoDialog extends ConsumerStatefulWidget {
  const _PresupuestoDialog({
    required this.categoria,
    required this.existing,
    required this.mes,
  });

  final CategoriaEntity categoria;
  final PresupuestoEntity? existing;
  final DateTime mes;

  @override
  ConsumerState<_PresupuestoDialog> createState() =>
      _PresupuestoDialogState();
}

class _PresupuestoDialogState extends ConsumerState<_PresupuestoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _montoController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _montoController = TextEditingController(
      text: widget.existing?.montoLimite.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? 'Nuevo presupuesto'
            : 'Editar presupuesto',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoriaChip(categoria: widget.categoria),
            const SizedBox(height: 16),
            TextFormField(
              controller: _montoController,
              decoration: const InputDecoration(
                labelText: 'Monto límite',
                prefixText: 'Q ',
                hintText: '0.00',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa un monto';
                }
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Ingresa un monto válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.existing != null)
          TextButton(
            onPressed: _guardando ? null : _eliminar,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final monto = double.parse(
      _montoController.text.replaceAll(',', '.'),
    );

    final presupuesto = PresupuestoEntity(
      id: widget.existing?.id ?? _generateId(),
      userId: userId,
      categoriaId: widget.categoria.id,
      montoLimite: monto,
      mes: DateTime(widget.mes.year, widget.mes.month, 1),
    );

    await ref
        .read(presupuestosNotifierProvider.notifier)
        .guardar(presupuesto);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _eliminar() async {
    if (widget.existing == null) return;

    setState(() => _guardando = true);

    await ref
        .read(presupuestosNotifierProvider.notifier)
        .eliminar(widget.existing!.id);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
