import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/Login/auth_controller.dart';
//molecules
import '../../molecules/Login/login_form.dart';

class LoginContent extends StatefulWidget {
  final VoidCallback onClose;

  const LoginContent({super.key, required this.onClose});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  //controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    print('LoginContent: Iniciando login con email: $email'); // Debug log
    try {
      await _authController.login(
        email: email,
        password: password,
        onSuccess: () {
          print('LoginContent: Login exitoso'); // Debug log
          onSuccess();
        },
        onError: (error) {
          print('LoginContent: Error en login - $error'); // Debug log
          onError(error);
        },
      );
    } catch (e) {
      print('LoginContent: Error inesperado - $e'); // Debug log
      onError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Iniciar sesión',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'En tu cuenta',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          //login form
          LoginForm(
            emailController: _emailController,
            passwordController: _passwordController,
            emailFocusNode: _emailFocusNode,
            passwordFocusNode: _passwordFocusNode,
            formKey: _formKey,
            onSubmit: _handleLogin,
          ),

          const SizedBox(height: 8),

          // Olvidé mi contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final controller = Get.find<AuthController>();
                controller.toggleForgotPassword();
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // O inicia sesión con
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.lightGray)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'O inicia sesión con',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppColors.lightGray)),
            ],
          ),

          const SizedBox(height: 24),

          // Botones de redes sociales
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'lib/assets/icons/others/googleIcon.png',
                    height: 24,
                  ),
                  label: Text(
                    'Google',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.lightGray),
                    backgroundColor: AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Image.asset(
                    'lib/assets/icons/others/apple.png',
                    height: 24,
                  ),
                  label: Text(
                    'Apple',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.lightGray),
                    backgroundColor: AppColors.surfaceLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Enlace de registro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿No tienes una cuenta? ",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  final controller = Get.find<AuthController>();
                  controller.toggleRegister();
                },
                child: Text(
                  'Regístrate',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
