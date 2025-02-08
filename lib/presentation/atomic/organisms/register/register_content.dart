import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../atoms/buttons/custom_button.dart';
import 'package:get/get.dart';
import '../../../controllers/finance_controller.dart';

class RegisterContent extends StatefulWidget {
  const RegisterContent({super.key});

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent>
    with AutomaticKeepAliveClientMixin {
  String _amount = '0';
  bool _isIncome = true;
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  final FinanceController _financeController = Get.put(FinanceController());

  final Map<String, List<String>> _categories = {
    'income': [
      'Sueldo',
      'Regalo',
      'Inversión',
      'Venta',
      'Préstamo',
      'Reembolso',
      'Otro',
    ],
    'expense': [
      'Comida',
      'Transporte',
      'Servicios',
      'Entretenimiento',
      'Salud',
      'Ropa',
      'Educación',
      'Otro',
    ],
  };

  final Map<String, IconData> _categoryIcons = {
    'Sueldo': Icons.work,
    'Regalo': Icons.card_giftcard,
    'Inversión': Icons.trending_up,
    'Venta': Icons.store,
    'Préstamo': Icons.account_balance,
    'Reembolso': Icons.replay,
    'Comida': Icons.restaurant,
    'Transporte': Icons.directions_car,
    'Servicios': Icons.home,
    'Entretenimiento': Icons.sports_esports,
    'Salud': Icons.medical_services,
    'Ropa': Icons.shopping_bag,
    'Educación': Icons.school,
    'Otro': Icons.more_horiz,
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories['income']![0];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateAmount(String value) {
    setState(() {
      if (_amount == '0' && value != '.') {
        _amount = value;
      } else if (_amount.contains('.') && value == '.') {
        return;
      } else {
        if (_amount.contains('.')) {
          final decimalPlaces = _amount.split('.')[1].length;
          if (decimalPlaces >= 2) return;
        }
        _amount = _amount + value;
      }
    });
  }

  void _deleteLastDigit() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _handleSubmit() async {
    try {
      if (double.parse(_amount) <= 0) {
        Get.snackbar(
          'Error',
          'El monto debe ser mayor a 0',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final amount = double.parse(_amount);
      final description = _selectedCategory == 'Otro'
          ? _descriptionController.text.isEmpty
              ? 'Otro'
              : _descriptionController.text
          : _selectedCategory ?? 'Sin categoría';

      // Mostrar indicador de carga
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      try {
        // Registrar la transacción
        if (_isIncome) {
          await _financeController.addIncome(amount, description);
        } else {
          await _financeController.addExpense(amount, description);
        }

        // Cerrar el indicador de carga
        Get.back();

        // Limpiar el formulario
        _descriptionController.clear();
        setState(() {
          _amount = '0';
        });

        // Navegar a la página de inicio
        final pageController = Get.put(PageController());
        pageController.jumpToPage(0);

        // Mostrar mensaje de éxito
        Get.snackbar(
          'Éxito',
          _isIncome ? 'Ingreso registrado' : 'Egreso registrado',
          backgroundColor: _isIncome ? AppColors.primaryGreen : Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        // Cerrar el indicador de carga si hay error
        Get.back();
        rethrow;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo registrar la transacción: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Widget _buildCategorySelector() {
    final currentCategories =
        _isIncome ? _categories['income']! : _categories['expense']!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categoría',
            style: TextStyle(
              color: _isIncome ? AppColors.primaryGreen : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isIncome ? AppColors.primaryGreen : Colors.red,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _isIncome ? AppColors.primaryGreen : Colors.red,
                ),
                items: currentCategories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(
                          _categoryIcons[category] ?? Icons.more_horiz,
                          color:
                              _isIncome ? AppColors.primaryGreen : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
              ),
            ),
          ),
          if (_selectedCategory == 'Otro') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Descripción personalizada',
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: _isIncome ? AppColors.primaryGreen : Colors.red,
                ),
                suffixIcon: Icon(
                  Icons.edit,
                  color: _isIncome
                      ? AppColors.primaryGreen.withOpacity(0.5)
                      : Colors.red.withOpacity(0.5),
                  size: 18,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _isIncome ? AppColors.primaryGreen : Colors.red,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Column(
        children: [
          // Amount Display
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$$_amount',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _isIncome ? AppColors.primaryGreen : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Toggle Button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleButton(true),
                      _buildToggleButton(false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Category Selector
                _buildCategorySelector(),
              ],
            ),
          ),
          const Spacer(),
          // Numeric Keypad
          Container(
            margin: const EdgeInsets.only(bottom: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildKeypadButton('1'),
                    _buildKeypadButton('2'),
                    _buildKeypadButton('3'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadButton('4'),
                    _buildKeypadButton('5'),
                    _buildKeypadButton('6'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadButton('7'),
                    _buildKeypadButton('8'),
                    _buildKeypadButton('9'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadButton('.'),
                    _buildKeypadButton('0'),
                    _buildKeypadButton('⌫', onTap: _deleteLastDigit),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    text: _isIncome ? 'Registrar Ingreso' : 'Registrar Egreso',
                    onPressed: _handleSubmit,
                    backgroundColor:
                        _isIncome ? AppColors.primaryGreen : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(bool isIncome) {
    final isSelected = _isIncome == isIncome;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isIncome = isIncome;
          // Actualizar la categoría seleccionada al cambiar el tipo
          _selectedCategory = _categories[isIncome ? 'income' : 'expense']![0];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isIncome ? AppColors.primaryGreen : Colors.red)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          isIncome ? 'Ingreso' : 'Egreso',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String text, {VoidCallback? onTap}) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: InkWell(
            onTap: onTap ?? () => _updateAmount(text),
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.textSecondary.withOpacity(0.1),
            highlightColor: AppColors.textSecondary.withOpacity(0.2),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
