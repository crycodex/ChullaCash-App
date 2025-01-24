import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'package:get/get.dart';
import '../../atoms/inputs/custom_text_field.dart';
import '../../atoms/buttons/custom_button.dart';
import '../../../controllers/Login/auth_controller.dart';

class ForgotPasswordContent extends StatefulWidget {
  final VoidCallback onClose;

  const ForgotPasswordContent({super.key, required this.onClose});

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
                'Recuperar contraseña',
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
            'Ingresa tu correo electrónico para recuperar tu contraseña',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Campo de correo
          CustomTextField(
            controller: _emailController,
            labelText: 'Correo electrónico',
          ),

          const SizedBox(height: 24),

          // Botón de enviar
          CustomButton(
            text: 'Enviar instrucciones',
            onPressed: () {
              // TODO: Implementar lógica de recuperación
              if (_emailController.text.isNotEmpty) {
                // Mostrar mensaje de éxito
                Get.snackbar(
                  'Correo enviado',
                  'Se han enviado las instrucciones a tu correo electrónico',
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  colorText: AppColors.primaryGreen,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(20),
                );
                widget.onClose();
              } else {
                // Mostrar error
                Get.snackbar(
                  'Error',
                  'Por favor ingresa un correo electrónico válido',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(20),
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Enlace para volver al login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿Recordaste tu contraseña? ",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  final controller = Get.find<AuthController>();
                  controller.toggleLogin();
                },
                child: Text(
                  'Iniciar sesión',
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
