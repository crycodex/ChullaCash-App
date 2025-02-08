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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Personal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                        backgroundColor: AppColors.lightGray,
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
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primaryGreen,
                                  )
                                : null),
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Obx(() => userController.isLoading.value
                        ? const SizedBox.shrink()
                        : _buildImagePickerButton(userController)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Información del usuario
            _buildSection(
              title: 'Datos personales',
              children: [
                _buildEditableField(
                  label: 'Nombre',
                  value: authController.userName,
                  onEdit: () => _showEditNameDialog(context, authController),
                ),
                const SizedBox(height: 16),
                _buildEditableField(
                  label: 'Correo electrónico',
                  value: authController.userEmail,
                  isEditable: false,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Zona de peligro
            _buildSection(
              title: 'Zona de peligro',
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

  Widget _buildImagePickerButton(UserController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: IconButton(
        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
        onPressed: () async {
          final source = await _showImageSourceDialog();
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

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Tomar foto'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Get.back(result: ImageSource.gallery),
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

  Widget _buildEditableField({
    required String label,
    required RxString value,
    bool isEditable = true,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
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
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      value.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
              ],
            ),
          ),
          if (isEditable)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
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

    Get.dialog(
      AlertDialog(
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
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.updateUserName(nameController.text);
                Get.back();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
      BuildContext context, AuthController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteAccount();
              Get.back();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
