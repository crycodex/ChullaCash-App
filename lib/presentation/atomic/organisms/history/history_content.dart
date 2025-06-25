import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/movement_controller.dart';
import '../../../controllers/user_controller.dart';
import 'package:intl/intl.dart';

class HistoryContent extends StatefulWidget {
  const HistoryContent({super.key});

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  final MovementController _movementController = Get.put(MovementController());
  final UserController _userController = Get.find<UserController>();

  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Ingresos', 'Gastos'];

  DateTime _selectedDate = DateTime.now();
  final DateFormat _monthFormat = DateFormat('MMMM yyyy', 'es_ES');

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _movementController.setupMovementsStream(
          _selectedDate.year, _selectedDate.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Historial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Obx(() {
        final bool isDarkMode = _userController.isDarkMode.value;
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de mes y año
                    InkWell(
                      onTap: _showDatePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.darkSurface
                              : AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _monthFormat.format(_selectedDate),
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Resumen del mes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingresos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+\$${_calculateIncome().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.lightGray,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Gastos',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '-\$${_calculateExpenses().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _filters
                      .map((filter) => _buildFilterChip(
                            filter,
                            _selectedFilter == filter,
                            () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                            isDarkMode,
                          ))
                      .toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de transacciones
              Expanded(
                child: Obx(() {
                  final movements = _movementController.currentMonthMovements;

                  if (movements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.2)
                                : AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay transacciones en ${_monthFormat.format(_selectedDate)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Colors.white70
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredMovements = movements.where((movement) {
                    if (_selectedFilter == 'Todos') return true;
                    if (_selectedFilter == 'Ingresos') {
                      return movement['type'] == 'income';
                    }
                    return movement['type'] == 'expense';
                  }).toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredMovements.length,
                    itemBuilder: (context, index) {
                      final movement = filteredMovements[index];
                      final isIncome = movement['type'] == 'income';

                      return Dismissible(
                        key: Key(movement['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
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
                                    ? AppColors.darkSurface
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
                                  '¿Estás seguro de que quieres eliminar esta transacción?',
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
                          _movementController.deleteMovement(movement['id']);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? AppColors.darkSurface
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppColors.lightGray,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: (isIncome
                                        ? AppColors.primaryGreen
                                        : Colors.red)
                                    .withValues(alpha: isDarkMode ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome
                                    ? AppColors.primaryGreen
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              movement['description'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDarkMode
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  isIncome ? 'Ingreso' : 'Gasto',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _movementController
                                      .getTimeAgo(movement['timestamp']),
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}\$${movement['amount'].toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isIncome
                                    ? AppColors.primaryGreen
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
        );
      }),
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

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
        backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
        checkmarkColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGray,
          ),
        ),
      ),
    );
  }
}
