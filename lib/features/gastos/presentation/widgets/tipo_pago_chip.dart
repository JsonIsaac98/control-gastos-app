import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../domain/entities/gasto_entity.dart';

class TipoPagoChip extends StatelessWidget {
  const TipoPagoChip({super.key, required this.tipoPago, this.small = false});

  final TipoPago tipoPago;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (color, bgColor, icon) = _getStyle(tipoPago, isDark);

    if (small) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              tipoPago.label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        tipoPago.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      backgroundColor: bgColor,
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  (Color, Color, IconData) _getStyle(TipoPago tipo, bool isDark) {
    return switch (tipo) {
      TipoPago.efectivo => (
          isDark ? AppColors.efectivoDark  : AppColors.efectivo,
          isDark ? AppColors.efectivoBgDark : AppColors.efectivoBg,
          Icons.money,
        ),
      TipoPago.tarjetaCredito => (
          isDark ? AppColors.tarjetaDark  : AppColors.tarjeta,
          isDark ? AppColors.tarjetaBgDark : AppColors.tarjetaBg,
          Icons.credit_card,
        ),
      TipoPago.transferencia => (
          isDark ? AppColors.transferDark  : AppColors.transfer,
          isDark ? AppColors.transferBgDark : AppColors.transferBg,
          Icons.swap_horiz,
        ),
    };
  }
}
