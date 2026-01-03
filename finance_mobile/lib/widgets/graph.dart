import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/home_models.dart';

class GraphCard extends StatefulWidget {
  final ChartData chartData;
  final List<Transaction> transactions;
  final double netWorth;

  const GraphCard({
    super.key,
    required this.chartData,
    required this.transactions,
    this.netWorth = 0,
  });

  @override
  State<GraphCard> createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard> {
  bool _showPieChart = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _showPieChart ? "Kategoriye Göre Harcama" : "Net Değer Grafiği",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPieChart = !_showPieChart;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _showPieChart ? Icons.show_chart : Icons.pie_chart,
                      size: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isWeb ? 200 : 220,
              child: _showPieChart ? _buildPieChart(isWeb) : _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isWeb) {
    final categoryData = _calculateCategoryExpenses();
    
    if (categoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              "Bu ay henüz harcama yok",
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];

    // Mobilde düşey layout, web'de yatay layout
    if (isWeb) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((entry) {
                    final index = categoryData.keys.toList().indexOf(entry.key);
                    final color = colors[index % colors.length];
                    final percentage = (entry.value / _getTotalExpenses() * 100);
                    
                    return PieChartSectionData(
                      value: entry.value,
                      title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                      color: color,
                      radius: 70,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 35,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryData.entries.map((entry) {
                  final index = categoryData.keys.toList().indexOf(entry.key);
                  final color = colors[index % colors.length];
                  final percentage = (entry.value / _getTotalExpenses() * 100);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '₺${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    } else {
      // Mobil: Üstte pasta, altta legend
      return Column(
        children: [
          SizedBox(
            height: 140,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    sections: categoryData.entries.map((entry) {
                      final index = categoryData.keys.toList().indexOf(entry.key);
                      final color = colors[index % colors.length];
                      final percentage = (entry.value / _getTotalExpenses() * 100);
                      
                      return PieChartSectionData(
                        value: entry.value,
                        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                        color: color,
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: categoryData.entries.map((entry) {
                  final index = categoryData.keys.toList().indexOf(entry.key);
                  final color = colors[index % colors.length];
                  final percentage = (entry.value / _getTotalExpenses() * 100);
                  
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${entry.key} (${percentage.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    }
  }

  Map<String, double> _calculateCategoryExpenses() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final nextMonth = DateTime(now.year, now.month + 1);
    
    final Map<String, double> categoryTotals = {};
    
    for (final tx in widget.transactions) {
      if (tx.transactionType == 'Expense') {
        try {
          final txDate = DateTime.parse(tx.transactionDate);
          if (txDate.isAfter(currentMonth.subtract(const Duration(days: 1))) &&
              txDate.isBefore(nextMonth)) {
            categoryTotals[tx.transactionCategory] = 
                (categoryTotals[tx.transactionCategory] ?? 0) + tx.transactionAmount.abs();
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  double _getTotalExpenses() {
    return _calculateCategoryExpenses().values.fold(0, (sum, value) => sum + value);
  }

  Widget _buildLineChart() {
    final spots = _generateNetWorthSpots();
    final dateLabels = _generateDateLabels();

    if (spots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              "Henüz veri bulunmuyor",
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      );
    }

    double maxY = 0;
    double minY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
      if (spot.y < minY) minY = spot.y;
    }
    
    final double chartMaxY = maxY > 0 ? maxY * 1.1 : 1000;
    final double chartMinY = minY < 0 ? minY * 1.1 : 0;
    final double interval = (chartMaxY - chartMinY) / 4;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: interval > 0 ? interval : 1000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha(50), strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.withAlpha(30), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < dateLabels.length) {
                  if (index % 7 == 0 || index == dateLabels.length - 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(dateLabels[index], style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: interval > 0 ? interval : 1000,
              getTitlesWidget: (value, meta) {
                String text;
                if (value.abs() >= 1000) {
                  text = "₺${(value / 1000).toStringAsFixed(1)}K";
                } else {
                  text = "₺${value.toStringAsFixed(0)}";
                }
                return Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: chartMinY,
        maxY: chartMaxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: Colors.deepPurple,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.deepPurple.withAlpha(60), Colors.deepPurple.withAlpha(10)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem("₺${spot.y.toStringAsFixed(0)}", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateNetWorthSpots() {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayEnd = DateTime(date.year, date.month, date.day).add(const Duration(days: 1));
      
      double dailyNetChange = 0;
      for (final tx in widget.transactions) {
        try {
          final txDate = DateTime.parse(tx.transactionDate);
          if (txDate.isBefore(dayEnd)) {
            if (tx.transactionType == 'Income') {
              dailyNetChange += tx.transactionAmount;
            } else {
              dailyNetChange -= tx.transactionAmount.abs();
            }
          }
        } catch (e) {
          continue;
        }
      }
      
      final spotValue = widget.netWorth - widget.chartData.total + dailyNetChange;
      spots.add(FlSpot((29 - i).toDouble(), spotValue));
    }
    
    if (spots.isNotEmpty) return spots;
    return List.generate(30, (i) => FlSpot(i.toDouble(), widget.netWorth));
  }

  List<String> _generateDateLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add("${date.day} ${months[date.month - 1]}");
    }
    
    return labels;
  }
}
