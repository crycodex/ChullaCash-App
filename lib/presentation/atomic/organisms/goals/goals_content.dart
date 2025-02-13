import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/finance_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/goals_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

class GoalsContent extends StatefulWidget {
  const GoalsContent({super.key});

  @override
  State<GoalsContent> createState() => _GoalsContentState();
}

class _GoalsContentState extends State<GoalsContent>
    with SingleTickerProviderStateMixin {
  final FinanceController financeController = Get.find<FinanceController>();
  final UserController userController = Get.find<UserController>();
  final GoalsController goalsController = Get.put(GoalsController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late AnimationController _animationController;
  final RxBool _showTutorial = true.obs;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    ever(goalsController.isCelebrating, (isCelebrating) {
      if (isCelebrating) {
        _startCelebration();
      } else {
        _stopCelebration();
      }
    });
  }

  void _startCelebration() {
    goalsController.startCelebration();
  }

  void _stopCelebration() {
    goalsController.stopCelebration();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.network(
          'https://assets2.lottiefiles.com/packages/lf20_yzoqyyqf.json',
          height: 200,
          repeat: true,
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            '¡Comienza a establecer tus objetivos!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Establece objetivos financieros y visualiza tu progreso hacia ellos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _buildTutorialStep(
          isDarkMode,
          '1. Toca el botón + para agregar un nuevo objetivo',
          Icons.add_circle_outline,
        ),
        _buildTutorialStep(
          isDarkMode,
          '2. Establece un monto y fecha objetivo',
          Icons.calendar_today,
        ),
        _buildTutorialStep(
          isDarkMode,
          '3. ¡Visualiza tu progreso!',
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildTutorialStep(bool isDarkMode, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, bool isDarkMode) {
    final double progress = goal['progress'] as double;
    final bool isCompleted = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (goal['description']?.isNotEmpty ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                goal['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    CircularPercentIndicator(
                      radius: 25.0,
                      lineWidth: 4.0,
                      percent: progress.clamp(0.0, 1.0),
                      center: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      progressColor: AppColors.primaryGreen,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearPercentIndicator(
                  animation: true,
                  lineHeight: 8.0,
                  animationDuration: 1000,
                  percent: progress.clamp(0.0, 1.0),
                  barRadius: const Radius.circular(4),
                  progressColor:
                      isCompleted ? Colors.green : AppColors.primaryGreen,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance actual / Meta',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${goal['currentAmount'].toStringAsFixed(2)} / \$${goal['targetAmount'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.green.withOpacity(0.1)
                            : AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.access_time,
                            size: 16,
                            color: isCompleted
                                ? Colors.green
                                : AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted ? '¡Completado!' : 'En progreso',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.green
                                  : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : AppColors.primaryGreen.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Te faltan \$${(goal['targetAmount'] - goal['currentAmount']).toStringAsFixed(2)} para alcanzar tu objetivo',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final bool isDarkMode = userController.isDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Nuevo Objetivo',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Ahorrar para un carro',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto objetivo',
                hintText: 'Ej: 5000',
                prefixText: '\$',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Quiero comprar un carro en 6 meses',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty ||
                  _amountController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Por favor completa todos los campos requeridos',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                Get.snackbar(
                  'Error',
                  'Por favor ingresa un monto válido',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              await goalsController.addGoal(
                title: _titleController.text,
                targetAmount: amount,
                description: _descriptionController.text,
              );

              _titleController.clear();
              _amountController.clear();
              _descriptionController.clear();
              _showTutorial.value = false;
              Navigator.pop(context);

              Get.snackbar(
                '¡Éxito!',
                'Objetivo creado correctamente',
                backgroundColor: AppColors.primaryGreen,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Crear Objetivo',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(Map<String, dynamic> goal) {
    final bool isDarkMode = userController.isDarkMode.value;
    _titleController.text = goal['title'];
    _amountController.text = goal['targetAmount'].toString();
    _descriptionController.text = goal['description'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Editar Objetivo',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Monto objetivo',
                prefixText: '\$',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty ||
                  _amountController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Por favor completa todos los campos requeridos',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final amount = double.tryParse(_amountController.text);
              if (amount == null || amount <= 0) {
                Get.snackbar(
                  'Error',
                  'Por favor ingresa un monto válido',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              await goalsController.updateGoal(
                goalId: goal['id'],
                title: _titleController.text,
                targetAmount: amount,
                description: _descriptionController.text,
              );

              _titleController.clear();
              _amountController.clear();
              _descriptionController.clear();
              Navigator.pop(context);

              Get.snackbar(
                '¡Éxito!',
                'Objetivo actualizado correctamente',
                backgroundColor: AppColors.primaryGreen,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Mis Objetivos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showAddGoalDialog,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Obx(() {
            final bool isDarkMode = userController.isDarkMode.value;
            final goals = goalsController.goals;

            if (goals.isEmpty) {
              return _buildEmptyState(isDarkMode);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(goals[index]['id']),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: isDarkMode
                                ? AppColors.darkSurface
                                : Colors.white,
                            title: Text(
                              '¿Eliminar objetivo?',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            content: Text(
                              '¿Estás seguro de que deseas eliminar este objetivo?',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : AppColors.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      _showEditGoalDialog(goals[index]);
                      return false;
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      goalsController.deleteGoal(goals[index]['id']);
                    }
                  },
                  child: _buildGoalCard(goals[index], isDarkMode),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
