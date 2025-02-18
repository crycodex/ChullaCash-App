import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../atoms/buttons/custom_button.dart';
//controllers
import '../../../controllers/Login/auth_controller.dart';
import '../../../controllers/user_controller.dart';
//url launcher
import 'package:url_launcher/url_launcher.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'isnotcristhian@gmail.com',
        queryParameters: {
          'subject': 'Ayuda ChullaCash',
          'body': 'Hola, necesito ayuda con...'
        });

    if (!await launchUrl(emailLaunchUri)) {
      Get.snackbar(
        'Error',
        'No se pudo abrir el correo electrónico',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final userController = Get.put(UserController());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Obx(() {
              final hasValidImage = userController.photoUrl.value.isNotEmpty;

              return CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : AppColors.lightGray,
                backgroundImage: hasValidImage
                    ? NetworkImage(userController.photoUrl.value)
                    : null,
                child: userController.isLoading.value
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen),
                      )
                    : (!hasValidImage
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : AppColors.primaryGreen,
                          )
                        : null),
              );
            }),
            const SizedBox(height: 16),

            // Nombre del usuario
            Obx(() => Text(
                  userController.name.value.isEmpty
                      ? 'Usuario'
                      : userController.name.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                )),
            Obx(() => Text(
                  userController.email.value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                )),
            const SizedBox(height: 32),

            // Account Settings
            const _SectionTitle(title: 'Configuración de cuenta'),
            _SettingsItem(
              icon: Icons.person_outline,
              title: 'Información personal',
              onTap: () => Get.toNamed('/personal-info'),
            ),
            _SettingsItem(
              icon: Icons.lock_outline,
              title: 'Seguridad',
              onTap: () => Get.toNamed('/security'),
            ),
            _SettingsItem(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              onTap: () {
                Get.snackbar(
                  'Notificaciones',
                  'Esta funcionalidad no está disponible en esta versión',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
            ),

            const SizedBox(height: 24),

            // Preferences
            const _SectionTitle(title: 'Preferencias'),
            _SettingsItem(
              icon: Icons.language,
              title: 'Idioma',
              trailing: const Text('Español'),
              onTap: () {
                Get.snackbar(
                  'Idioma',
                  'Esta funcionalidad no está disponible en esta versión',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              },
            ),
            Obx(() => _SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tema oscuro',
                  subtitle: authController.isDarkMode.value
                      ? 'Activado'
                      : 'Desactivado',
                  trailing: Switch.adaptive(
                    value: authController.isDarkMode.value,
                    onChanged: (value) => authController.toggleTheme(),
                    activeColor: AppColors.primaryGreen,
                    activeTrackColor: AppColors.primaryGreen.withOpacity(0.5),
                  ),
                  onTap: () => authController.toggleTheme(),
                )),

            const SizedBox(height: 24),

            // Support
            const _SectionTitle(title: 'Soporte'),
            _SettingsItem(
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              onTap: _launchEmail,
            ),
            _SettingsItem(
              icon: Icons.policy_outlined,
              title: 'Términos y condiciones',
              onTap: () {
                //url
                launchUrl(Uri.parse(
                    'https://sites.google.com/view/chullacash/inicio'));
              },
            ),

            const SizedBox(height: 32),

            // Logout Button
            CustomButton(
              text: 'Cerrar sesión',
              onPressed: () {
                authController.logout();
              },
              backgroundColor: Colors.red,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
