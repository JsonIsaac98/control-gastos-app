import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../providers/gastos_provider.dart';

class MesSelector extends ConsumerWidget {
  const MesSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () =>
              ref.read(selectedMonthProvider.notifier).previousMonth(),
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Mes anterior',
        ),
        Text(
          selectedMonth.monthYear,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                textBaseline: TextBaseline.alphabetic,
              ),
        ),
        IconButton(
          onPressed: isCurrentMonth
              ? null
              : () => ref.read(selectedMonthProvider.notifier).nextMonth(),
          icon: Icon(
            Icons.chevron_right,
            color: isCurrentMonth
                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
                : null,
          ),
          tooltip: 'Mes siguiente',
        ),
      ],
    );
  }
}
