import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/home_models.dart';

class GraphCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                const Text(
                  "Net Değer Grafiği",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                _buildSummaryChip(),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip() {
    final total = chartData.total;
    final isPositive = total >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive 
            ? Colors.green.withAlpha(30) 
            : Colors.red.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "${isPositive ? '+' : ''}₺${total.toStringAsFixed(0)}",
        style: TextStyle(
          color: isPositive ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildChart() {
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

    // Y ekseni değerlerini hesapla
    double maxY = 0;
    double minY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
      if (spot.y < minY) minY = spot.y;
    }
    
    // Y ekseni: 0'dan max değere kadar
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
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withAlpha(50),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withAlpha(30),
            strokeWidth: 1,
          ),
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
                      child: Text(
                        dateLabels[index],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
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
                return Text(
                  text,
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                );
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
                colors: [
                  Colors.deepPurple.withAlpha(60),
                  Colors.deepPurple.withAlpha(10),
                ],
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
                return LineTooltipItem(
                  "₺${spot.y.toStringAsFixed(0)}",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
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
      for (final tx in transactions) {
        try {
          final txDate = DateTime.parse(tx.transactionDate);
          if (txDate.isBefore(dayEnd)) {
            if (tx.transactionType == 'Income') {
              dailyNetChange += tx.transactionAmount;
            } else {
              dailyNetChange -= tx.transactionAmount;
            }
          }
        } catch (e) {
          continue;
        }
      }
      
      final spotValue = netWorth - chartData.total + dailyNetChange;
      spots.add(FlSpot((29 - i).toDouble(), spotValue));
    }
    
    if (spots.isNotEmpty) {
      return spots;
    }
    
    return List.generate(30, (i) => FlSpot(i.toDouble(), netWorth));
  }

  List<String> _generateDateLabels() {
    final now = DateTime.now();
    final labels = <String>[];
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
                    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add("${date.day} ${months[date.month - 1]}");
    }
    
    return labels;
  }
}