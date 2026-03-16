import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../domain/entities/gasto_entity.dart';
import 'tipo_pago_chip.dart';

class GastoCard extends StatelessWidget {
  const GastoCard({
    super.key,
    required this.gasto,
    this.onDelete,
  });

  final GastoEntity gasto;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key('gasto_${gasto.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colorScheme.error),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono del tipo de pago
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForTipo(gasto.tipoPago),
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              // Descripción y tipo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gasto.descripcion,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          gasto.fecha.dayMonth,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TipoPagoChip(tipoPago: gasto.tipoPago, small: true),
                        // TODO: ícono de foto desactivado temporalmente
                        // if (gasto.fotoUrl != null) ...[
                        //   const SizedBox(width: 6),
                        //   Icon(Icons.photo_camera, size: 14,
                        //       color: colorScheme.onSurfaceVariant),
                        // ],
                      ],
                    ),
                  ],
                ),
              ),
              // Monto
              Text(
                gasto.monto.toCurrency,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForTipo(TipoPago tipo) {
    return switch (tipo) {
      TipoPago.efectivo => Icons.money,
      TipoPago.tarjetaCredito => Icons.credit_card,
      TipoPago.transferencia => Icons.swap_horiz,
    };
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text(
          '¿Deseas eliminar "${gasto.descripcion}"?',
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
  }
}
