import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/movement_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../molecules/charts/finance_charts.dart';

class WalletContent extends StatefulWidget {
  const WalletContent({super.key});

  @override
  State<WalletContent> createState() => _WalletContentState();
}

class _WalletContentState extends State<WalletContent> {
  final MovementController _movementController = Get.find<MovementController>();
  final FinanceController _financeController = Get.find<FinanceController>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Overview
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Align(),
                    const Text(
                      'Balance Total',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          '\$${_financeController.allTimeBalance.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gráficas
              FinanceCharts(
                movementController: _movementController,
                selectedDate: DateTime.now(),
                selectedFilter: 'Todos',
              ),

              const SizedBox(height: 24),

              // Resumen del mes actual
              Obx(() {
                final totalIncome = _calculateIncome();
                final totalExpense = _calculateExpenses();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryCard(
                      'Ingresos del Mes',
                      totalIncome,
                      AppColors.primaryGreen,
                      Icons.arrow_upward,
                    ),
                    _buildSummaryCard(
                      'Gastos del Mes',
                      totalExpense,
                      Colors.red,
                      Icons.arrow_downward,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateIncome() {
    return _movementController.currentMonthMovements
        .where((movement) => movement['type'] == 'income')
        .fold(0.0, (sum, movement) => sum + (movement['amount'] as double));
  }

  double _calculateExpenses() {
    return _movementController.currentMonthMovements
        .where((movement) => movement['type'] == 'expense')
        .fold(0.0, (sum, movement) => sum + (movement['amount'] as double));
  }
}
