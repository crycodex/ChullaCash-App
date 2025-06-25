import 'package:get/get.dart';
//firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final RxBool isDarkMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxString uid = ''.obs;
  final RxString email = ''.obs;
  final RxString name = ''.obs;
  final RxString photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
    // Escuchar cambios en el modo oscuro
    ever(isDarkMode, _updateTheme);
  }

  void _updateTheme(bool darkMode) {
    // Actualizar el tema en la aplicación
    Get.changeThemeMode(darkMode ? ThemeMode.dark : ThemeMode.light);

    // Si el usuario está autenticado, guardar la preferencia en Firestore
    if (_auth.currentUser != null) {
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'darkMode': darkMode})
          .then((_) => debugPrint('Tema actualizado en Firestore'))
          .catchError((error) => debugPrint('Error updating theme: $error'));
    }
  }

  void toggleTheme() {
    debugPrint('Cambiando tema. Actual: ${isDarkMode.value}');
    isDarkMode.value = !isDarkMode.value;
  }

  void _initializeUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        uid.value = currentUser.uid;
        email.value = currentUser.email ?? '';
        name.value = currentUser.displayName ?? '';
        photoUrl.value = currentUser.photoURL ?? '';

        // Cargar preferencias del usuario desde Firestore
        final userDoc =
            await _firestore.collection('users').doc(uid.value).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          // Cargar el modo oscuro si existe
          if (userData.containsKey('darkMode')) {
            isDarkMode.value = userData['darkMode'];
          }
        }
      }
    } catch (e) {
      debugPrint('Error al inicializar usuario: $e');
    }
  }

  Future<String> userName() async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid.value).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        name.value = userData['name'] ?? '';

        if (name.value.isEmpty) {
          // Actualizar en Firestore si el nombre está vacío
          await _firestore
              .collection('users')
              .doc(uid.value)
              .update({'name': 'Usuario'});

          name.value = 'Usuario';
        }
      }
      return name.value;
    } catch (e) {
      debugPrint('Error al obtener nombre de usuario: $e');
      return 'Usuario';
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      isLoading.value = true;
      debugPrint('Iniciando actualización de imagen de perfil...');

      if (uid.value.isEmpty) {
        throw Exception('No hay usuario autenticado');
      }

      // Crear referencia al storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${uid.value}_$timestamp.jpg';
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      debugPrint('Subiendo imagen: $fileName');

      // Comprimir y subir imagen
      final File imageFile = File(imagePath);

      // Verificar tamaño del archivo
      final fileSize = await imageFile.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('La imagen no puede ser mayor a 5MB');
      }

      try {
        final uploadTask = await storageRef.putFile(
          imageFile,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedBy': uid.value,
              'timestamp': timestamp.toString(),
            },
          ),
        );

        // Obtener URL de descarga
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        debugPrint('URL de descarga obtenida: $downloadUrl');

        // Eliminar imagen anterior si existe
        if (photoUrl.value.isNotEmpty) {
          try {
            final oldImageRef = _storage.refFromURL(photoUrl.value);
            await oldImageRef.delete();
            debugPrint('Imagen anterior eliminada');
          } catch (e) {
            debugPrint('Error al eliminar imagen anterior: $e');
          }
        }

        // Actualizar Firestore
        await _firestore.collection('users').doc(uid.value).update({
          'photoUrl': downloadUrl,
        });

        // Actualizar estado local
        photoUrl.value = downloadUrl;

        // Actualizar perfil de Firebase Auth
        await _auth.currentUser?.updatePhotoURL(downloadUrl);

        Get.snackbar(
          'Éxito',
          'Imagen de perfil actualizada',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        debugPrint('Imagen de perfil actualizada exitosamente');
      } catch (e) {
        debugPrint('Error al actualizar imagen de perfil: $e');
        Get.snackbar(
          'Error',
          'No se pudo actualizar la imagen de perfil',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar imagen de perfil: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar la imagen de perfil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      isLoading.value = true;

      if (photoUrl.value.isEmpty) return;

      // Eliminar imagen de Storage
      final imageRef = _storage.refFromURL(photoUrl.value);
      await imageRef.delete();

      // Actualizar Firestore
      await _firestore.collection('users').doc(uid.value).update({
        'photoUrl': '',
      });

      // Actualizar perfil de Firebase Auth
      await _auth.currentUser?.updatePhotoURL('');

      // Actualizar estado local
      photoUrl.value = '';

      Get.snackbar(
        'Éxito',
        'Imagen de perfil eliminada',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error al eliminar imagen de perfil: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar la imagen de perfil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
