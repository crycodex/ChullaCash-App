import 'package:flutter/material.dart';
import '../../atoms/inputs/custom_text_field.dart';
import '../../atoms/buttons/custom_button.dart';
import '../../../theme/app_colors.dart';
import 'package:get/get.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final GlobalKey<FormState> formKey;
  final Function({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String) onError,
  }) onSubmit;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscureText = true;
  bool _isLoading = false;

  void _handleSubmit() async {
    print('Intentando submit del formulario...'); // Debug log

    // Forzar la validación del formulario
    final isValid = widget.formKey.currentState?.validate() ?? false;
    print('¿Formulario válido? $isValid'); // Debug log

    if (!isValid) {
      print('Formulario inválido, mostrando error...'); // Debug log
      Get.snackbar(
        'Error',
        'Por favor, complete todos los campos correctamente',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    if (widget.emailController.text.isEmpty ||
        widget.passwordController.text.isEmpty) {
      print('Campos vacíos, mostrando error...'); // Debug log
      Get.snackbar(
        'Error',
        'Por favor, complete todos los campos',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
      return;
    }

    setState(() => _isLoading = true);
    print('Iniciando proceso de login...'); // Debug log

    try {
      await widget.onSubmit(
        email: widget.emailController.text.trim(),
        password: widget.passwordController.text,
        onSuccess: () {
          setState(() => _isLoading = false);
          print('Login exitoso, navegando a home...'); // Debug log
          Get.offAllNamed('/home');
        },
        onError: (error) {
          setState(() => _isLoading = false);
          print('Error en login: $error'); // Debug log
          Get.snackbar(
            'Error',
            error,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(20),
          );
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error inesperado: $e'); // Debug log
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          CustomTextField(
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onEditingComplete: () => widget.passwordFocusNode.requestFocus(),
            labelText: 'Correo electrónico',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo electrónico';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Por favor ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: widget.passwordController,
            focusNode: widget.passwordFocusNode,
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleSubmit,
            labelText: 'Contraseña',
            obscureText: _obscureText,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: _isLoading ? 'Iniciando sesión...' : 'Iniciar sesión',
            onPressed: _isLoading ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}
