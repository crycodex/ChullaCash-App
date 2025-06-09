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
    final controller = Get.put(AuthController());

    // Obtener información de la pantalla y fuente
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaleFactor;

    // Espaciados dinámicos basados en el tamaño de pantalla y fuente
    final dynamicSpacing =
        screenHeight < 700 || textScaleFactor > 1.2 ? 12.0 : 16.0;
    final headerSpacing =
        screenHeight < 700 || textScaleFactor > 1.2 ? 16.0 : 24.0;
    final sectionSpacing =
        screenHeight < 700 || textScaleFactor > 1.2 ? 16.0 : 24.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header más compacto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recuperar contraseña',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.fontSize !=
                                null
                            ? Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .fontSize! *
                                (textScaleFactor > 1.3 ? 0.9 : 1.0)
                            : null,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
          SizedBox(height: dynamicSpacing * 0.5),
          Text(
            'Ingresa tu correo electrónico para recuperar tu contraseña',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize !=
                              null &&
                          textScaleFactor > 1.3
                      ? Theme.of(context).textTheme.bodyMedium!.fontSize! * 0.95
                      : null,
                ),
          ),
          SizedBox(height: headerSpacing),

          // Formulario expandido con mejor scroll
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Campo de correo
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Correo electrónico',
                  ),

                  SizedBox(height: sectionSpacing),

                  // Botón de enviar
                  CustomButton(
                    text: 'Enviar instrucciones',
                    onPressed: () {
                      controller.recoverPassword(
                        email: _emailController.text,
                        onSuccess: () {
                          Get.snackbar('Correo de recuperación enviado',
                              'Se ha enviado un correo de recuperación a su correo electrónico.');
                        },
                        onError: (error) {
                          Get.snackbar('Error', error,
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                        },
                      );
                    },
                  ),

                  SizedBox(height: sectionSpacing),

                  // Enlace para volver al login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "¿Recordaste tu contraseña? ",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.toggleLogin();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
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

                  // Espacio adicional para el scroll
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 20
                          : 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
