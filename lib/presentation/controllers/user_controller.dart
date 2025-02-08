import 'package:get/get.dart';
//firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isDarkMode = false.obs;
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
          .then((_) => print('Tema actualizado en Firestore'))
          .catchError((error) => print('Error updating theme: $error'));
    }
  }

  void toggleTheme() {
    print('Cambiando tema. Actual: ${isDarkMode.value}');
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
      print('Error al inicializar usuario: $e');
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
      print('Error al obtener nombre de usuario: $e');
      return 'Usuario';
    }
  }
}
