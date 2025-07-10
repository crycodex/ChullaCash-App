import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../atoms/buttons/custom_button.dart';
import '../../../controllers/Login/auth_controller.dart';
import '../../../controllers/user_controller.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInfoContent extends StatelessWidget {
  const PersonalInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final userController = Get.put(UserController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Información Personal',
          style: TextStyle(
            color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto de perfil
            Center(
              child: Stack(
                children: [
                  Obx(() => CircleAvatar(
                        radius: 60,
                        backgroundColor: isDarkMode
                            ? AppColors.darkSurface
                            : AppColors.lightGray,
                        backgroundImage:
                            userController.photoUrl.value.isNotEmpty
                                ? NetworkImage(userController.photoUrl.value)
                                : null,
                        child: userController.isLoading.value
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryGreen),
                              )
                            : (userController.photoUrl.value.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: isDarkMode
                                        ? AppColors.textLight
                                        : AppColors.primaryGreen,
                                  )
                                : null),
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Obx(() => userController.isLoading.value
                        ? const SizedBox.shrink()
                        : _buildImagePickerButton(userController, isDarkMode)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Información del usuario
            _buildSection(
              title: 'Datos personales',
              isDarkMode: isDarkMode,
              children: [
                _buildEditableField(
                  label: 'Nombre',
                  value: authController.userName,
                  onEdit: () => _showEditNameDialog(context, authController),
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  label: 'Correo electrónico',
                  value: authController.userEmail,
                  isEditable: false,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Zona de peligro
            _buildSection(
              title: 'Zona de peligro',
              isDarkMode: isDarkMode,
              children: [
                CustomButton(
                  text: 'Eliminar cuenta',
                  onPressed: () =>
                      _showDeleteAccountDialog(context, authController),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton(UserController controller, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDarkMode ? AppColors.darkSurface : Colors.white,
          width: 2,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
        onPressed: () async {
          final source = await _showImageSourceDialog(isDarkMode);
          if (source != null) {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
              source: source,
              maxWidth: 512,
              maxHeight: 512,
              imageQuality: 85,
            );
            if (image != null) {
              controller.updateProfileImage(image.path);
            }
          }
        },
      ),
    );
  }

  Future<ImageSource?> _showImageSourceDialog(bool isDarkMode) async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : null,
        title: Text(
          'Seleccionar imagen',
          style: TextStyle(
            color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera,
                color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
              ),
              title: Text(
                'Tomar foto',
                style: TextStyle(
                  color:
                      isDarkMode ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
              ),
              title: Text(
                'Galería',
                style: TextStyle(
                  color:
                      isDarkMode ? AppColors.textLight : AppColors.textPrimary,
                ),
              ),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required RxString value,
    bool isEditable = true,
    VoidCallback? onEdit,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? AppColors.darkSurface : AppColors.lightGray,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? AppColors.textLight
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      value.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    )),
              ],
            ),
          ),
          if (isEditable)
            IconButton(
              icon: Icon(
                Icons.edit,
                color: isDarkMode
                    ? AppColors.primaryGreen
                    : AppColors.primaryGreen,
              ),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AuthController controller) {
    final TextEditingController nameController = TextEditingController(
      text: controller.userName.value,
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : null,
        title: Text(
          'Editar nombre',
          style: TextStyle(
            color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(
            color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Nombre',
            labelStyle: TextStyle(
              color: isDarkMode ? AppColors.textLight : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDarkMode ? AppColors.textLight : AppColors.lightGray,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isDarkMode ? AppColors.textLight : AppColors.lightGray,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDarkMode ? AppColors.textLight : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.updateUserName(nameController.text);
                Get.back();
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, AuthController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : null,
        title: Text(
          'Eliminar cuenta permanentemente',
          style: TextStyle(
            color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar tu cuenta?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta acción eliminará permanentemente:',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Todos tus datos personales',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? AppColors.textLight.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
            Text(
              '• Historial de transacciones',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? AppColors.textLight.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
            Text(
              '• Metas financieras',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? AppColors.textLight.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
            Text(
              '• Configuraciones de la aplicación',
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode
                    ? AppColors.textLight.withOpacity(0.7)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDarkMode ? AppColors.textLight : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount();
            },
            child: const Text(
              'Eliminar cuenta',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
