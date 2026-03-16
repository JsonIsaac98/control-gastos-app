import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../features/categorias/domain/entities/categoria_entity.dart';
import '../../../../features/categorias/providers/categorias_provider.dart';

class CategoriasSettingsPage extends ConsumerWidget {
  const CategoriasSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: categoriasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final cat = cats[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: cat.colorValue ?? Colors.grey,
                child: Text(cat.icono ?? '📦',
                    style: const TextStyle(fontSize: 18)),
              ),
              title: Text(cat.nombre),
              subtitle:
                  cat.esDefault ? const Text('Categoría del sistema') : null,
              trailing: cat.esDefault
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              _showCategoriaDialog(context, ref, cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () => _confirmDelete(context, ref, cat),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoriaDialog(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Nueva categoría'),
      ),
    );
  }

  static const _presetColors = [
    '#EF4444',
    '#F97316',
    '#EAB308',
    '#22C55E',
    '#14B8A6',
    '#3B82F6',
    '#4318FF',
    '#A855F7',
    '#EC4899',
    '#6B7280',
    '#059669',
    '#0891B2',
  ];

  void _showCategoriaDialog(
      BuildContext context, WidgetRef ref, CategoriaEntity? existing) {
    final nombreCtrl = TextEditingController(text: existing?.nombre ?? '');
    final iconoCtrl = TextEditingController(text: existing?.icono ?? '');
    String selectedColor = existing?.color ?? '#4318FF';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Nueva categoría' : 'Editar categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nombre', hintText: 'Ej: Restaurantes'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: iconoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Emoji',
                    hintText: '🍕',
                    helperText: 'Escribe o pega un emoji',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Color',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetColors.map((c) {
                    final hex = c.replaceAll('#', '');
                    final color = Color(int.parse('FF$hex', radix: 16));
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == c
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: selectedColor == c
                              ? [
                                  BoxShadow(
                                      color: color.withValues(alpha: 0.5),
                                      blurRadius: 6)
                                ]
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (nombreCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final userId =
                    Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;
                final id = existing?.id ?? const Uuid().v4();
                final cat = CategoriaEntity(
                  id: id,
                  userId: userId,
                  nombre: nombreCtrl.text.trim(),
                  icono: iconoCtrl.text.trim().isEmpty
                      ? '📦'
                      : iconoCtrl.text.trim(),
                  color: selectedColor,
                  esDefault: false,
                );
                // Save locally
                await ref
                    .read(categoriasLocalDatasourceProvider)
                    .upsertCategoria(cat);
                // Save to Supabase
                try {
                  await ref
                      .read(categoriasRemoteDatasourceProvider)
                      .upsertCategoria(cat, userId);
                } catch (_) {}
                ref.invalidate(categoriasProvider);
              },
              child: Text(existing == null ? 'Crear' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CategoriaEntity cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
            '¿Eliminar "${cat.nombre}"? Los gastos de esta categoría quedarán sin categoría.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(categoriasLocalDatasourceProvider)
          .deleteCategoria(cat.id);
      try {
        await ref
            .read(categoriasRemoteDatasourceProvider)
            .deleteCategoria(cat.id);
      } catch (_) {}
      ref.invalidate(categoriasProvider);
    }
  }
}
