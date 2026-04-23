import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/tarjeta_entity.dart';
import '../../providers/tarjetas_provider.dart';

class TarjetasSettingsPage extends ConsumerWidget {
  const TarjetasSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tarjetasAsync = ref.watch(tarjetasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tarjetas de crédito')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_tarjeta',
        onPressed: () => _mostrarFormTarjeta(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Agregar tarjeta'),
      ),
      body: tarjetasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tarjetas) {
          if (tarjetas.isEmpty) {
            return _EmptyState(
              onAdd: () => _mostrarFormTarjeta(context, ref, null),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: tarjetas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _TarjetaCard(
              tarjeta: tarjetas[i],
              onEdit: () =>
                  _mostrarFormTarjeta(context, ref, tarjetas[i]),
              onDelete: () =>
                  _confirmarEliminar(context, ref, tarjetas[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _mostrarFormTarjeta(
      BuildContext context, WidgetRef ref, TarjetaEntity? existing) async {
    final result = await showDialog<TarjetaEntity>(
      context: context,
      builder: (ctx) => _TarjetaDialog(existing: existing),
    );
    if (result == null) return;

    if (existing == null) {
      await ref.read(tarjetasProvider.notifier).addTarjeta(result);
    } else {
      await ref.read(tarjetasProvider.notifier).updateTarjeta(result);
    }
  }

  Future<void> _confirmarEliminar(
      BuildContext context, WidgetRef ref, TarjetaEntity tarjeta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarjeta'),
        content: Text(
          '¿Eliminar "${tarjeta.nombre}"?\n\n'
          'Los gastos vinculados no se eliminarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(tarjetasProvider.notifier)
          .deleteTarjeta(tarjeta.id);
    }
  }
}

// ----------------------------------------------------------------
// Tarjeta card
// ----------------------------------------------------------------
class _TarjetaCard extends StatelessWidget {
  const _TarjetaCard({
    required this.tarjeta,
    required this.onEdit,
    required this.onDelete,
  });

  final TarjetaEntity tarjeta;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cardColor = _parseColor(tarjeta.color) ??
        Theme.of(context).colorScheme.primaryContainer;
    final onCardColor =
        _parseColor(tarjeta.color) != null ? Colors.white : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.credit_card,
              color: onCardColor ??
                  Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: Text(
          tarjeta.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Día de corte: ${tarjeta.diaCorte}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? hex) {
    if (hex == null) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}

// ----------------------------------------------------------------
// Diálogo de formulario para agregar/editar tarjeta
// ----------------------------------------------------------------
class _TarjetaDialog extends StatefulWidget {
  const _TarjetaDialog({this.existing});

  final TarjetaEntity? existing;

  @override
  State<_TarjetaDialog> createState() => _TarjetaDialogState();
}

class _TarjetaDialogState extends State<_TarjetaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late int _diaCorte;
  late String _colorHex;

  @override
  void initState() {
    super.initState();
    _nombreCtrl =
        TextEditingController(text: widget.existing?.nombre ?? '');
    _diaCorte = widget.existing?.diaCorte ?? 1;
    _colorHex =
        widget.existing?.color ?? TarjetaEntity.coloresPreset.first;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existing != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar tarjeta' : 'Nueva tarjeta'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la tarjeta',
                  hintText: 'Ej: TC PROMERICA',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa el nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Día de corte
              Text(
                'Día de corte',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _diaCorte,
                decoration: const InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                items: List.generate(
                  28,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('Día ${i + 1} de cada mes'),
                  ),
                ),
                onChanged: (v) {
                  if (v != null) setState(() => _diaCorte = v);
                },
              ),
              const SizedBox(height: 20),

              // Color
              Text(
                'Color',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: TarjetaEntity.coloresPreset.map((hex) {
                  final color =
                      Color(int.parse(hex.replaceFirst('#', '0xFF')));
                  final selected = _colorHex == hex;
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = hex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3)
                            : null,
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardar,
          child: Text(isEditing ? 'Guardar' : 'Agregar'),
        ),
      ],
    );
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final tarjeta = TarjetaEntity(
      id: widget.existing?.id ??
          'tc_${DateTime.now().millisecondsSinceEpoch}',
      nombre: _nombreCtrl.text.trim().toUpperCase(),
      diaCorte: _diaCorte,
      color: _colorHex,
      isDefault: widget.existing?.isDefault ?? false,
      orden: widget.existing?.orden ?? 0,
    );
    Navigator.pop(context, tarjeta);
  }
}

// ----------------------------------------------------------------
// Estado vacío
// ----------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_off_outlined,
                size: 72,
                color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'Sin tarjetas configuradas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega tus tarjetas de crédito para llevar '
              'seguimiento de cuotas por tarjeta.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarjeta'),
            ),
          ],
        ),
      ),
    );
  }
}
