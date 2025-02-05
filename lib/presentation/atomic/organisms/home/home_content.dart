import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
//get
import 'package:get/get.dart';
//controllers
import '../../../controllers/user_controller.dart';
import '../../../controllers/finance_controller.dart';
import '../../../controllers/movement_controller.dart';

class HomeContent extends StatelessWidget {
  HomeContent({super.key});

  final UserController userController = Get.put(UserController());
  final FinanceController financeController = Get.put(FinanceController());
  final MovementController movementController = Get.put(MovementController());

  Color _textColor(BuildContext context) {
    return userController.isDarkMode.value
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge!.color!;
  }

  @override
  Widget build(BuildContext context) {
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
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                      FutureBuilder(
                        future: userController.userName(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return Obx(() => Text(
                                userController.name.value,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sección de Balance
              Container(
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    //balance total
                    Obx(() => Text(
                          '\$${financeController.allTimeBalance.value.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        )),
                    const SizedBox(height: 24),
                    // Time period selector
                    Row(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Movimientos recientes
              Text(
                'Movimientos recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final movements = movementController.currentMonthMovements;
                  if (movements.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay movimientos este mes',
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
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
                          color: Colors.red,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: const Text(
                                    '¿Estás seguro de que quieres eliminar este movimiento?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          movementController.deleteMovement(movement['id']);
                        },
                        child: Card(
                          color: isDarkMode
                              ? AppColors.darkSurface.withOpacity(0.8)
                              : Colors.white,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isDarkMode
                                  ? (isIncome
                                          ? AppColors.primaryGreen
                                          : Colors.red)
                                      .withOpacity(0.2)
                                  : (isIncome
                                          ? AppColors.primaryGreen
                                          : Colors.red)
                                      .withOpacity(0.1),
                              child: Icon(
                                isIncome ? Icons.add : Icons.remove,
                                color: isIncome
                                    ? AppColors.primaryGreen
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              movement['description'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _textColor(context),
                              ),
                            ),
                            subtitle: Text(
                              movementController
                                  .getTimeAgo(movement['timestamp']),
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}\$${movement['amount'].toStringAsFixed(2)}',
                              style: TextStyle(
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
