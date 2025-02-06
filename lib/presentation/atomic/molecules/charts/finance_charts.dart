import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../controllers/movement_controller.dart';
import '../../../theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinanceCharts extends StatelessWidget {
  final MovementController movementController;
  final DateTime selectedDate;
  final String selectedFilter;

  const FinanceCharts({
    super.key,
    required this.movementController,
    required this.selectedDate,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gráfica de línea para el balance diario
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final movements = movementController.currentMonthMovements;
            if (movements.isEmpty) {
              return const Center(
                child: Text('No hay datos para mostrar'),
              );
            }

            final dailyBalances = _calculateDailyBalances(movements);
            final spots = _createLineSpots(dailyBalances);

            return LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 != 0) return const Text('');
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primaryGreen,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryGreen.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '\$${spot.y.toStringAsFixed(2)}',
                          TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 24),

        // Gráfica de barras para ingresos vs gastos
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final movements = movementController.currentMonthMovements;
            if (movements.isEmpty) {
              return const Center(
                child: Text('No hay datos para mostrar'),
              );
            }

            final weeklyData = _calculateWeeklyData(movements);

            return BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekNames = ['S1', 'S2', 'S3', 'S4', 'S5'];
                        if (value >= 0 && value < weekNames.length) {
                          return Text(
                            weekNames[value.toInt()],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['income']!,
                        color: AppColors.primaryGreen,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: data['expense']!,
                        color: Colors.red,
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '\$${rod.toY.toStringAsFixed(2)}',
                        TextStyle(
                          color: rodIndex == 0
                              ? AppColors.primaryGreen
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<FlSpot> _createLineSpots(Map<int, double> dailyBalances) {
    final spots = <FlSpot>[];
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    for (int day = 1; day <= daysInMonth; day++) {
      spots.add(FlSpot(
        day.toDouble(),
        dailyBalances[day] ?? 0,
      ));
    }
    return spots;
  }

  Map<int, double> _calculateDailyBalances(
      List<Map<String, dynamic>> movements) {
    final dailyBalances = <int, double>{};
    double runningBalance = 0;

    for (final movement in movements) {
      final timestamp = movement['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      final day = date.day;
      final amount = movement['amount'] as double;
      final isIncome = movement['type'] == 'income';

      runningBalance += isIncome ? amount : -amount;
      dailyBalances[day] = runningBalance;
    }

    return dailyBalances;
  }

  List<Map<String, double>> _calculateWeeklyData(
      List<Map<String, dynamic>> movements) {
    final weeklyData =
        List.generate(5, (index) => {'income': 0.0, 'expense': 0.0});

    for (final movement in movements) {
      final timestamp = movement['timestamp'] as Timestamp;
      final date = timestamp.toDate();
      final weekOfMonth = ((date.day - 1) ~/ 7);
      final amount = movement['amount'] as double;
      final isIncome = movement['type'] == 'income';

      if (weekOfMonth < 5) {
        if (isIncome) {
          weeklyData[weekOfMonth]['income'] =
              (weeklyData[weekOfMonth]['income'] ?? 0) + amount;
        } else {
          weeklyData[weekOfMonth]['expense'] =
              (weeklyData[weekOfMonth]['expense'] ?? 0) + amount;
        }
      }
    }

    return weeklyData;
  }
}
