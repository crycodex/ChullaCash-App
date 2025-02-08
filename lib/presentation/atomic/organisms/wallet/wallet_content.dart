import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/movement_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../molecules/charts/finance_charts.dart';

class WalletContent extends StatefulWidget {
  const WalletContent({super.key});

  @override
  State<WalletContent> createState() => _WalletContentState();
}

class _WalletContentState extends State<WalletContent>
    with SingleTickerProviderStateMixin {
  final MovementController _movementController = Get.put(MovementController());
  final FinanceController _financeController = Get.put(FinanceController());
  final UserController _userController = Get.put(UserController());
  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _textColorAnimation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _colorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _setupAnimations();
    _financeController.allTimeBalance.listen((_) {
      if (!_disposed) {
        _setupAnimations();
        _colorAnimationController.forward(from: 0);
      }
    });
  }

  void _setupAnimations() {
    if (_disposed) return;

    final bool isPositive = _financeController.allTimeBalance.value >= 0;
    _colorAnimation = ColorTween(
      begin: _userController.isDarkMode.value
          ? AppColors.darkSurface
          : Colors.white,
      end: isPositive
          ? AppColors.primaryGreen.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
    ).animate(_colorAnimationController);

    _textColorAnimation = ColorTween(
      begin: _userController.isDarkMode.value
          ? Colors.white
          : AppColors.textPrimary,
      end: isPositive ? AppColors.primaryGreen : Colors.red,
    ).animate(_colorAnimationController);
  }

  @override
  void dispose() {
    _disposed = true;
    _colorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isDarkMode = _userController.isDarkMode.value;
      return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Overview
                AnimatedBuilder(
                  animation: _colorAnimationController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkSurface.withOpacity(0.8)
                            : _colorAnimation.value,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Balance Total',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : AppColors.primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 16,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : AppColors.primaryGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Mi Billetera',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : AppColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(() => Text(
                                '\$${_financeController.allTimeBalance.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: _textColorAnimation.value,
                                ),
                              )),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Gráficas
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkSurface.withOpacity(0.8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: FinanceCharts(
                    movementController: _movementController,
                    selectedDate: DateTime.now(),
                    selectedFilter: 'Todos',
                  ),
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
                        isDarkMode ? Colors.green : AppColors.primaryGreen,
                        Icons.arrow_upward,
                        isDarkMode,
                      ),
                      _buildSummaryCard(
                        'Gastos del Mes',
                        totalExpense,
                        Colors.red,
                        Icons.arrow_downward,
                        isDarkMode,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.8)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.5)
                : color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDarkMode ? Colors.white : color,
              fontSize: 24,
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
