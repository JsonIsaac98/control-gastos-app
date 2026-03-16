import 'package:flutter/material.dart';

import '../../domain/entities/categoria_entity.dart';

class CategoriaChip extends StatelessWidget {
  const CategoriaChip({
    super.key,
    required this.categoria,
    this.onTap,
    this.isSelected = false,
  });

  final CategoriaEntity categoria;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color =
        categoria.colorValue ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (categoria.icono != null) ...[
              Text(categoria.icono!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
            ],
            Text(
              categoria.nombre,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
