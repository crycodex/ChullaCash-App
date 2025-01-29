import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../atoms/buttons/custom_button.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.lightGray,
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Juan Pérez',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text(
              'juan.perez@example.com',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Account Settings
            const _SectionTitle(title: 'Configuración de cuenta'),
            _SettingsItem(
              icon: Icons.person_outline,
              title: 'Información personal',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.lock_outline,
              title: 'Seguridad',
              onTap: () {},
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
              trailing: 'Español',
              onTap: () {},
            ),
            _SettingsItem(
              icon: Icons.dark_mode_outlined,
              title: 'Tema',
              trailing: 'Claro',
              onTap: () {},
            ),

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
              onPressed: () {},
              backgroundColor: Colors.red,
            ),
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
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryGreen),
        title: Text(title),
        trailing: trailing != null
            ? Text(
                trailing!,
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
