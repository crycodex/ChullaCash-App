import 'package:get/get.dart';
//firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  final RxBool isDarkMode = false.obs;

  final RxString uid = ''.obs;
  final RxString email = ''.obs;
  final RxString name = ''.obs;
  final RxString photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  void _initializeUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      uid.value = currentUser.uid;
      email.value = currentUser.email ?? '';
      name.value = currentUser.displayName ?? '';
      photoUrl.value = currentUser.photoURL ?? '';
    }
  }

  Future<String> userName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid.value)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      name.value = userData['name'];

      if (name.value.isEmpty) {
        // Actualizar en Firestore si el nombre está vacío
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid.value)
            .update({'name': 'Usuario'});

        name.value = 'Usuario';
      }
      return name.value;
    }
    return 'Usuario';
  }
}
