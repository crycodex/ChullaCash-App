import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
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
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      // Validar nombre
      if (_nameController.text.isEmpty) {
        _nameError = 'El nombre es requerido';
        isValid = false;
      } else if (_nameController.text.length < AuthController.minNameLength) {
        _nameError = 'El nombre es muy corto';
        isValid = false;
      } else if (_nameController.text.length > AuthController.maxNameLength) {
        _nameError = 'El nombre es muy largo';
        isValid = false;
      }

      // Validar email
      if (_emailController.text.isEmpty) {
        _emailError = 'El correo es requerido';
        isValid = false;
      } else if (!GetUtils.isEmail(_emailController.text)) {
        _emailError = 'Ingrese un correo válido';
        isValid = false;
      }

      // Validar contraseña
      if (_passwordController.text.isEmpty) {
        _passwordError = 'La contraseña es requerida';
        isValid = false;
      } else if (_passwordController.text.length <
          AuthController.minPasswordLength) {
        _passwordError =
            'La contraseña debe tener al menos ${AuthController.minPasswordLength} caracteres';
        isValid = false;
      } else if (_passwordController.text.length >
          AuthController.maxPasswordLength) {
        _passwordError =
            'La contraseña no puede tener más de ${AuthController.maxPasswordLength} caracteres';
        isValid = false;
      }

      // Validar confirmación de contraseña
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Confirme su contraseña';
        isValid = false;
      } else if (_confirmPasswordController.text != _passwordController.text) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
        isValid = false;
      }
    });
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    // Obtener información de la pantalla y fuente
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaler;

    // Espaciados dinámicos basados en el tamaño de pantalla y fuente
    final dynamicSpacing =
        screenHeight < 700 || textScaleFactor.scale(1.2) > 1.2 ? 12.0 : 16.0;
    final headerSpacing =
        screenHeight < 700 || textScaleFactor.scale(1.2) > 1.2 ? 16.0 : 24.0;
    final buttonSpacing =
        screenHeight < 700 || textScaleFactor.scale(1.2) > 1.2 ? 16.0 : 24.0;

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
                  'Crear cuenta',
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
                                (textScaleFactor.scale(1.3) > 1.3 ? 0.9 : 1.0)
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
            'Regístrate para comenzar',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: headerSpacing),

          // Formulario expandido con mejor scroll
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de nombre con padding más compacto
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: AppColors.textPrimary),
                      maxLength: AuthController.maxNameLength,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        errorText: _nameError,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: textScaleFactor.scale(1.2) > 1.2 ? 12 : 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                      ),
                    ),

                    SizedBox(height: dynamicSpacing),

                    // Campo de correo
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: AppColors.textPrimary),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        errorText: _emailError,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: textScaleFactor.scale(1.2) > 1.2 ? 12 : 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                      ),
                    ),

                    SizedBox(height: dynamicSpacing),

                    // Campo de contraseña
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        errorText: _passwordError,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: textScaleFactor.scale(1.2) > 1.2 ? 12 : 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
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

                    SizedBox(height: dynamicSpacing),

                    // Campo de confirmar contraseña
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmText,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Confirmar contraseña',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        errorText: _confirmPasswordError,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: textScaleFactor.scale(1.2) > 1.2 ? 12 : 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.lightGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primaryBlue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceLight,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmText
                                ? Icons.visibility_off
                                : Icons.visibility,
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

                    SizedBox(height: buttonSpacing),

                    // Botón de Registro
                    Obx(() => ElevatedButton(
                          onPressed: _authController.isLoading.value
                              ? null
                              : () {
                                  if (_validateInputs()) {
                                    _authController.register(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                      onSuccess: () {
                                        Get.offAllNamed('/welcome');
                                      },
                                      onError: (error) {
                                        // Manejar errores específicos
                                        if (error.contains('email')) {
                                          setState(() => _emailError = error);
                                        } else if (error
                                            .contains('contraseña')) {
                                          setState(
                                              () => _passwordError = error);
                                        } else {
                                          Get.snackbar(
                                            'Error',
                                            error,
                                            backgroundColor: AppColors.error,
                                            colorText: AppColors.textLight,
                                          );
                                        }
                                      },
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.textLight,
                            padding: EdgeInsets.symmetric(
                                vertical: textScaleFactor.scale(1.2) > 1.2 ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _authController.isLoading.value
                                ? 'Registrando...'
                                : 'Registrarse',
                            style: TextStyle(
                              fontSize: textScaleFactor.scale(1.3) > 1.3 ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )),

                    SizedBox(height: dynamicSpacing),

                    // Enlace de inicio de sesión
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "¿Ya tienes una cuenta? ",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _authController.toggleLogin();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
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

                    // Espacio adicional para el scroll
                    SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 20
                            : 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
