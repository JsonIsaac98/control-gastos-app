import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/extensions/date_extensions.dart';
import '../../../categorias/domain/entities/categoria_entity.dart';
import '../../../categorias/providers/categorias_provider.dart';
import '../../../gastos/domain/entities/gasto_entity.dart';
import '../../../gastos/providers/gastos_provider.dart';

class ReportesPage extends ConsumerStatefulWidget {
  const ReportesPage({super.key});

  @override
  ConsumerState<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends ConsumerState<ReportesPage> {
  DateTime _mes = DateTime(DateTime.now().year, DateTime.now().month, 1);

  /// Key del botón PDF — necesario en iOS para anclar el share sheet.
  final _pdfButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final gastosAsync = ref.watch(gastosDelMesPorFechaProvider(_mes));
    final gastosMesAnterior = ref.watch(gastosDelMesPorFechaProvider(
      DateTime(_mes.year, _mes.month - 1, 1),
    ));
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          gastosAsync.maybeWhen(
            data: (gastos) => IconButton(
              key: _pdfButtonKey,
              tooltip: 'Exportar PDF',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: () =>
                  _exportarPDF(context, gastos, categoriasAsync.value ?? []),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Selector de mes ───────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => setState(() {
                    _mes = DateTime(_mes.year, _mes.month - 1, 1);
                  }),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Mes anterior',
                ),
                Text(
                  _mes.monthYear,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                IconButton(
                  onPressed: () {
                    final next = DateTime(_mes.year, _mes.month + 1, 1);
                    final now = DateTime.now();
                    if (next.isBefore(DateTime(now.year, now.month + 1, 1))) {
                      setState(() => _mes = next);
                    }
                  },
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Mes siguiente',
                ),
              ],
            ),
          ),
          Expanded(
            child: gastosAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (gastos) {
                final totalMes = gastos.fold(0.0, (s, g) => s + g.monto);
                final totalAnterior = gastosMesAnterior.value
                        ?.fold(0.0, (s, g) => s + g.monto) ??
                    0.0;
                final cats = categoriasAsync.value ?? [];
                final catMap = {for (final c in cats) c.id: c};

                // Calcular totales por categoría
                final Map<String, double> totalPorCat = {};
                for (final g in gastos) {
                  final key = g.categoriaId ?? '__sin_categoria__';
                  totalPorCat[key] = (totalPorCat[key] ?? 0) + g.monto;
                }

                // Top 5
                final top5 = [...gastos]
                  ..sort((a, b) => b.monto.compareTo(a.monto));
                final top5List = top5.take(5).toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Resumen ─────────────────────────────
                    _ResumenCard(
                        total: totalMes,
                        totalAnterior: totalAnterior,
                        mes: _mes),
                    const SizedBox(height: 16),

                    // ── Pie Chart ───────────────────────────
                    if (totalPorCat.isNotEmpty) ...[
                      const _SeccionTitulo(titulo: 'Por categoría'),
                      const SizedBox(height: 8),
                      _CategoriaChart(
                          totalPorCat: totalPorCat,
                          catMap: catMap,
                          total: totalMes),
                      const SizedBox(height: 16),
                    ],

                    // ── Top 5 ────────────────────────────────
                    if (top5List.isNotEmpty) ...[
                      const _SeccionTitulo(titulo: 'Top 5 gastos del mes'),
                      const SizedBox(height: 8),
                      ...top5List
                          .map((g) => _Top5Item(gasto: g, catMap: catMap)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportarPDF(BuildContext context, List<GastoEntity> gastos,
      List<CategoriaEntity> cats) async {
    final catMap = {for (final c in cats) c.id: c};
    final total = gastos.fold(0.0, (s, g) => s + g.monto);
    final mesStr = _mes.monthYear;

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Gastos Personal — $mesStr',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Total del mes: Q ${total.toStringAsFixed(2)}',
              style: const pw.TextStyle(
                  fontSize: 14, color: PdfColors.grey700)),
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text('Detalle de gastos',
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Descripción', 'Categoría', 'Monto'],
            data: gastos.map((g) {
              final cat = g.categoriaId != null
                  ? catMap[g.categoriaId!]?.nombre ?? '—'
                  : '—';
              return [
                g.fecha.formattedDate,
                g.descripcion,
                cat,
                'Q ${g.monto.toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.indigo700),
            cellStyle: const pw.TextStyle(fontSize: 10),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300)),
            ),
          ),
        ],
      ),
    ));

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/reporte_$mesStr.pdf');
    await file.writeAsBytes(bytes);
    // En iOS el share sheet necesita un Rect de origen para anclarse.
    // Obtenemos la posición del botón PDF usando su GlobalKey.
    final box =
        _pdfButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromLTWH(0, 0, 1, 1);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Reporte de gastos — $mesStr',
      sharePositionOrigin: origin,
    );
  }
}

class _ResumenCard extends StatelessWidget {
  const _ResumenCard(
      {required this.total,
      required this.totalAnterior,
      required this.mes});
  final double total;
  final double totalAnterior;
  final DateTime mes;

  @override
  Widget build(BuildContext context) {
    final diff = totalAnterior > 0
        ? ((total - totalAnterior) / totalAnterior * 100)
        : 0.0;
    final subiendo = diff > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mes.monthYear,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 8),
            Text(total.toCurrency,
                style:
                    Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        )),
            if (totalAnterior > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    subiendo ? Icons.trending_up : Icons.trending_down,
                    size: 18,
                    color: subiendo
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${diff.abs().toStringAsFixed(1)}% vs mes anterior (${totalAnterior.toCurrency})',
                    style: TextStyle(
                      color: subiendo
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF22C55E),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoriaChart extends StatefulWidget {
  const _CategoriaChart(
      {required this.totalPorCat,
      required this.catMap,
      required this.total});
  final Map<String, double> totalPorCat;
  final Map<String, CategoriaEntity> catMap;
  final double total;

  @override
  State<_CategoriaChart> createState() => _CategoriaChartState();
}

class _CategoriaChartState extends State<_CategoriaChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.totalPorCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sections: List.generate(entries.length, (i) {
                    final e = entries[i];
                    final cat = widget.catMap[e.key];
                    final hexStr =
                        (cat?.color ?? '#6B7280').replaceAll('#', '');
                    final color =
                        Color(int.parse('FF$hexStr', radix: 16));
                    final isTouched = i == _touchedIndex;
                    return PieChartSectionData(
                      value: e.value,
                      color: color,
                      radius: isTouched ? 60 : 50,
                      title: isTouched
                          ? '${(e.value / widget.total * 100).toStringAsFixed(1)}%'
                          : '',
                      titleStyle: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: entries.map((e) {
                final cat = widget.catMap[e.key];
                final hexStr =
                    (cat?.color ?? '#6B7280').replaceAll('#', '');
                final color = Color(int.parse('FF$hexStr', radix: 16));
                final nombre = e.key == '__sin_categoria__'
                    ? 'Sin categoría'
                    : (cat?.nombre ?? e.key.substring(0, 8));
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(
                        '$nombre (${(e.value / widget.total * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Top5Item extends StatelessWidget {
  const _Top5Item({required this.gasto, required this.catMap});
  final GastoEntity gasto;
  final Map<String, CategoriaEntity> catMap;

  @override
  Widget build(BuildContext context) {
    final cat =
        gasto.categoriaId != null ? catMap[gasto.categoriaId!] : null;
    final hexStr = (cat?.color ?? '#6B7280').replaceAll('#', '');
    final color = Color(int.parse('FF$hexStr', radix: 16));
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child:
            Text(cat?.icono ?? '📦', style: const TextStyle(fontSize: 18)),
      ),
      title: Text(gasto.descripcion,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(gasto.fecha.formattedDate),
      trailing: Text(gasto.monto.toCurrency,
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  const _SeccionTitulo({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) => Text(titulo,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold));
}
