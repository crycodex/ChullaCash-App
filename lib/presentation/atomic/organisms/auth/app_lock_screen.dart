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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 64,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Desbloquear App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (authController.isBiometricEnabled.value) ...[
                    ElevatedButton.icon(
                      onPressed: _authenticateWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Usar biometría'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'O',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Ingresa tu PIN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (showError) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'PIN incorrecto. Intenta nuevamente.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index < enteredPin.length
                              ? AppColors.primaryGreen
                              : Colors.grey[300],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 48),
                  // Numeric keypad
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadButton(String text, {bool isDelete = false}) {
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
                fontSize: 24,
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
