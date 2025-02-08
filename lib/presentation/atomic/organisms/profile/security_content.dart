import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/Login/auth_controller.dart';
//local auth
import 'package:local_auth/local_auth.dart';
//auth controller
import '../../../controllers/Login/auth_controller.dart';

class SecurityContent extends StatelessWidget {
  SecurityContent({super.key});

  final LocalAuthentication localAuth = LocalAuthentication();
  final authController = Get.find<AuthController>();

  Future<void> _checkBiometricAvailability() async {
    try {
      final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      final bool canAuthenticate = await localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !canAuthenticate) {
        Get.snackbar(
          'No disponible',
          'Tu dispositivo no soporta autenticación biométrica',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await authController.toggleBiometric(false);
      }
    } catch (e) {
      debugPrint('Error al verificar biometría: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bloqueo de aplicación
            _buildSection(
              title: 'Bloqueo de aplicación',
              children: [
                Obx(() => _buildSwitchTile(
                      title: 'Habilitar bloqueo',
                      subtitle: 'Solicitar autenticación al abrir la app',
                      value: authController.isAppLockEnabled.value,
                      onChanged: (value) => authController.toggleAppLock(value),
                    )),
                const SizedBox(height: 16),
                Obx(
                  () => authController.isAppLockEnabled.value
                      ? Column(
                          children: [
                            _buildOptionTile(
                              title: 'Cambiar PIN',
                              icon: Icons.pin,
                              onTap: () =>
                                  _showChangePinDialog(context, authController),
                            ),
                            const SizedBox(height: 8),
                            FutureBuilder<bool>(
                              future: localAuth.canCheckBiometrics,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data == true) {
                                  return Obx(() => _buildSwitchTile(
                                        title: 'Usar biometría',
                                        subtitle: 'Huella digital o Face ID',
                                        value: authController
                                            .isBiometricEnabled.value,
                                        onChanged: (value) async {
                                          await authController
                                              .toggleBiometric(value);
                                          if (value) {
                                            await _checkBiometricAvailability();
                                          }
                                        },
                                      ));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tiempo de bloqueo
            Obx(
              () => authController.isAppLockEnabled.value
                  ? _buildSection(
                      title: 'Tiempo de bloqueo',
                      children: [
                        _buildDropdownTile(
                          title: 'Bloquear después de',
                          value: authController.lockTimeout.value,
                          items: const {
                            'immediately': 'Inmediatamente',
                            '1min': '1 minuto',
                            '5min': '5 minutos',
                            '30min': '30 minutos',
                            '1hour': '1 hora',
                          },
                          onChanged: (value) =>
                              authController.setLockTimeout(value),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildOptionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          underline: const SizedBox(),
        ),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, AuthController controller) {
    final TextEditingController pinController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Cambiar PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nuevo PIN (4 dígitos)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text.length == 4) {
                controller.updatePin(pinController.text);
                Get.back();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
