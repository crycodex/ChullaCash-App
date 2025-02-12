import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
//get
import 'package:get/get.dart';
//controllers
import '../../../controllers/user_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../../controllers/movement_controller.dart';
import '../../../controllers/Login/auth_controller.dart';
import '../history/history_content.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin {
  final UserController userController = Get.put(UserController());
  final FinanceController financeController = Get.put(FinanceController());
  final MovementController movementController = Get.put(MovementController());
  final AuthController authController = Get.put(AuthController());

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    financeController.getTotalBalance();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final bool isDarkMode = userController.isDarkMode.value;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido de nuevo,',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode
                              ? const Color(0xFFE0E0E0)
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            authController.userName.value,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDarkMode
                                  ? const Color(0xFFE0E0E0)
                                  : AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección de Balance
              GestureDetector(
                onTap: () {
                  Get.to(() => const HistoryContent());
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance Total',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? const Color(0xFFE0E0E0)
                                  : AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Obx(() {
                            final balance =
                                financeController.allTimeBalance.value;
                            final isPositive = balance >= 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (isPositive
                                        ? AppColors.primaryGreen
                                        : Colors.red)
                                    .withOpacity(isDarkMode ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPositive
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: isPositive
                                        ? AppColors.primaryGreen
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPositive ? 'Positivo' : 'Negativo',
                                    style: TextStyle(
                                      color: isPositive
                                          ? AppColors.primaryGreen
                                          : Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),
                      //balance total
                      Obx(() {
                        final balance = financeController.allTimeBalance.value;
                        final isPositive = balance >= 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${balance.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: isPositive
                                    ? AppColors.primaryGreen
                                    : Colors.red,
                              ),
                            ),
                            Text(
                              isPositive
                                  ? 'Tu balance está en buen estado'
                                  : 'Tu balance está en números rojos',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? const Color(0xFFE0E0E0)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Movimientos recientes
              Text(
                'Movimientos recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDarkMode
                      ? const Color(0xFFE0E0E0)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final movements = movementController.currentMonthMovements;
                  if (movements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay movimientos este mes',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? const Color(0xFFE0E0E0)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: movements.length,
                    itemBuilder: (context, index) {
                      final movement = movements[index];
                      final isIncome = movement['type'] == 'income';
                      return Dismissible(
                        key: Key(movement['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: isDarkMode
                                    ? const Color(0xFF252525)
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Confirmar eliminación',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                content: Text(
                                  '¿Estás seguro de que quieres eliminar este movimiento?',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancelar',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          movementController.deleteMovement(movement['id']);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF252525)
                                : isIncome
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.1)
                                  : isIncome
                                      ? AppColors.primaryGreen.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (isIncome
                                        ? AppColors.primaryGreen
                                        : Colors.red)
                                    .withOpacity(isDarkMode ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isIncome
                                    ? AppColors.primaryGreen
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              movement['description'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              movementController
                                  .getTimeAgo(movement['timestamp']),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}\$${movement['amount'].toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: isIncome
                                    ? AppColors.primaryGreen
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
