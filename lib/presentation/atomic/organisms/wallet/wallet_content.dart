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
  final MovementController _movementController =
      Get.put(MovementController());
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
                          Text(
                            'Balance Total',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                                '\$${_financeController.allTimeBalance.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: _textColorAnimation.value,
                                ),
                              )),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildQuickAction(
                                icon: Icons.add,
                                label: 'Agregar',
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryGreen,
                                onTap: () {
                                  Get.toNamed('/register');
                                },
                              ),
                              _buildQuickAction(
                                icon: Icons.history,
                                label: 'Historial',
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.primaryGreen,
                                onTap: () {
                                  Get.toNamed('/history');
                                },
                              ),
                            ],
                          ),
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isDarkMode = _userController.isDarkMode.value;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : color.withOpacity(0.1),
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
    bool isDarkMode,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkSurface.withOpacity(0.8)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: isDarkMode
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
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
                  color: isDarkMode ? Colors.white70 : color,
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
