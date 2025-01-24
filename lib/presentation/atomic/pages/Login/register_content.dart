import 'package:flutter/material.dart';
import '.../../../../../theme/app_colors.dart';
import 'package:get/get.dart';
import '../../../controllers/Login/auth_controller.dart';

class RegisterContent extends StatefulWidget {
  final VoidCallback onClose;

  const RegisterContent({super.key, required this.onClose});

  @override
  State<RegisterContent> createState() => _RegisterContentState();
}

class _RegisterContentState extends State<RegisterContent> {
  bool _obscureText = true;
  bool _obscureConfirmText = true;

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
                'Crear cuenta',
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
            'Regístrate para comenzar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Campo de nombre
          TextField(
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
            ),
          ),

          const SizedBox(height: 16),

          // Campo de correo
          TextField(
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
            ),
          ),

          const SizedBox(height: 16),

          // Campo de contraseña
          TextField(
            obscureText: _obscureText,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
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
            ),
          ),

          const SizedBox(height: 16),

          // Campo de confirmar contraseña
          TextField(
            obscureText: _obscureConfirmText,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmText = !_obscureConfirmText;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botón de Registro
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Registrarse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Enlace de inicio de sesión
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿Ya tienes una cuenta? ",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  final controller = Get.find<AuthController>();
                  controller.toggleLogin();
                },
                child: Text(
                  'Inicia sesión',
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
