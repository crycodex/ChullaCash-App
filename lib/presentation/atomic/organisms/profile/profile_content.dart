import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../atoms/buttons/custom_button.dart';
//controllers
import '../../../controllers/Login/auth_controller.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Obx(() => CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.lightGray,
                  backgroundImage: authController.profileImage.value != null
                      ? NetworkImage(authController.profileImage.value!)
                      : null,
                  child: authController.profileImage.value == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primaryGreen,
                        )
                      : null,
                )),
            const SizedBox(height: 16),

            // Nombre del usuario
            Obx(() => Text(
                  authController.userName.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                )),
            Obx(() => Text(
                  authController.userEmail.value,
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
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // Preferences
            const _SectionTitle(title: 'Preferencias'),
            _SettingsItem(
              icon: Icons.language,
              title: 'Idioma',
              trailing: const Text('Español'),
              onTap: () {},
            ),
            Obx(() => _SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Tema oscuro',
                  trailing: Switch(
                    value: authController.isDarkMode.value,
                    onChanged: (value) => authController.toggleTheme(),
                    activeColor: AppColors.primaryGreen,
                  ),
                  onTap: () => authController.toggleTheme(),
                )),

            const SizedBox(height: 24),

            // Support
            const _SectionTitle(title: 'Soporte'),
            _SettingsItem(
              icon: Icons.help_outline,
              title: 'Centro de ayuda',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.policy_outlined,
              title: 'Términos y condiciones',
              onTap: () {},
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

  void _showEditNameDialog(
      BuildContext context, AuthController authController) {
    final TextEditingController nameController = TextEditingController(
      text: authController.userName.value,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                authController.updateUserName(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
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
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primaryGreen),
        title: Text(
          title,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
