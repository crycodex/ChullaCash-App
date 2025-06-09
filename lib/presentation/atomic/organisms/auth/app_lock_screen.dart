import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/Login/auth_controller.dart';
import 'package:local_auth/local_auth.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final authController = Get.find<AuthController>();
  final LocalAuthentication auth = LocalAuthentication();
  String enteredPin = '';
  bool showError = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    if (authController.isBiometricEnabled.value) {
      try {
        final bool canCheckBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate = await auth.isDeviceSupported();

        if (canCheckBiometrics && canAuthenticate) {
          // Intentar autenticación biométrica automáticamente
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _authenticateWithBiometrics();
          });
        } else {
          // Si la biometría no está disponible, desactivarla
          authController.toggleBiometric(false);
          Get.snackbar(
            'Biometría no disponible',
            'Tu dispositivo no soporta autenticación biométrica',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        debugPrint('Error al verificar biometría: $e');
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Por favor, autentícate para acceder a la app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        Get.offAllNamed('/home');
      }
    } catch (e) {
      debugPrint('Error en autenticación biométrica: $e');
      Get.snackbar(
        'Error',
        'No se pudo realizar la autenticación biométrica',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handlePinInput(String digit) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += digit;
        showError = false;
      });

      if (enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _verifyPin() {
    if (enteredPin == authController.pin.value) {
      Get.offAllNamed('/home');
    } else {
      setState(() {
        showError = true;
        enteredPin = '';
      });
    }
  }

  void _deleteDigit() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        showError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener información de la pantalla y fuente
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final textScaleFactor = mediaQuery.textScaleFactor;

    // Espaciados y tamaños dinámicos basados en el tamaño de pantalla y fuente
    final dynamicSpacing =
        screenHeight < 700 || textScaleFactor > 1.2 ? 16.0 : 24.0;
    final iconSize = textScaleFactor > 1.3 ? 48.0 : 64.0;
    final titleFontSize = textScaleFactor > 1.3 ? 20.0 : 24.0;
    final subtitleFontSize = textScaleFactor > 1.3 ? 15.0 : 18.0;
    final errorFontSize = textScaleFactor > 1.3 ? 14.0 : 16.0;
    final keypadMaxWidth = screenWidth < 400 ? screenWidth * 0.8 : 300.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icono de bloqueo más compacto
                  Container(
                    padding: EdgeInsets.all(textScaleFactor > 1.2 ? 12 : 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: iconSize,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: dynamicSpacing),

                  // Título responsivo
                  Text(
                    'Desbloquear App',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: dynamicSpacing * 0.7),

                  // Sección de biometría si está habilitada
                  if (authController.isBiometricEnabled.value) ...[
                    ElevatedButton.icon(
                      onPressed: _authenticateWithBiometrics,
                      icon: Icon(
                        Icons.fingerprint,
                        size: textScaleFactor > 1.3 ? 18 : 20,
                      ),
                      label: Text(
                        'Usar biometría',
                        style: TextStyle(
                          fontSize: textScaleFactor > 1.3 ? 14 : 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: textScaleFactor > 1.2 ? 20 : 24,
                          vertical: textScaleFactor > 1.2 ? 10 : 12,
                        ),
                      ),
                    ),
                    SizedBox(height: dynamicSpacing),
                    Text(
                      'O',
                      style: TextStyle(
                        fontSize: textScaleFactor > 1.3 ? 14 : 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: dynamicSpacing),
                  ],

                  // Subtítulo del PIN
                  Text(
                    'Ingresa tu PIN',
                    style: TextStyle(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  // Mensaje de error más compacto
                  if (showError) ...[
                    SizedBox(height: dynamicSpacing * 0.7),
                    Text(
                      'PIN incorrecto. Intenta nuevamente.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: errorFontSize,
                      ),
                    ),
                  ],
                  SizedBox(height: dynamicSpacing),

                  // PIN dots más pequeños para fuentes grandes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final dotSize = textScaleFactor > 1.3 ? 16.0 : 20.0;
                      return Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: textScaleFactor > 1.3 ? 6 : 8,
                        ),
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < enteredPin.length
                              ? AppColors.primaryGreen
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: dynamicSpacing * 1.5),

                  // Teclado numérico responsivo
                  Container(
                    constraints: BoxConstraints(maxWidth: keypadMaxWidth),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: textScaleFactor > 1.3 ? 1.8 : 1.5,
                      mainAxisSpacing: textScaleFactor > 1.2 ? 12 : 16,
                      crossAxisSpacing: textScaleFactor > 1.2 ? 12 : 16,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((digit) {
                          return _buildKeypadButton(digit.toString());
                        }),
                        const SizedBox(),
                        _buildKeypadButton('0'),
                        _buildKeypadButton('⌫', isDelete: true),
                      ],
                    ),
                  ),

                  // Espacio adicional en la parte inferior
                  SizedBox(height: dynamicSpacing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String text, {bool isDelete = false}) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final buttonFontSize = textScaleFactor > 1.3 ? 20.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isDelete) {
            _deleteDigit();
          } else {
            _handlePinInput(text);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: buttonFontSize,
                fontWeight: FontWeight.w500,
                color: isDelete ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
