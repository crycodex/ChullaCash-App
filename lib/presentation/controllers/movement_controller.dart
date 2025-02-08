import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/finance_controller.dart';

class MovementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<Map<String, dynamic>> currentMonthMovements =
      <Map<String, dynamic>>[].obs;

  final FinanceController _financeController = Get.put(FinanceController());

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    loadMovementsForMonth(now.year, now.month);
  }

  Future<void> loadMovementsForMonth(int year, int month) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .orderBy('timestamp', descending: true)
          .get();

      currentMonthMovements.value = snapshot.docs
          .where((doc) => doc.id != 'info')
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los movimientos: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
    } else {
      return 'Hace un momento';
    }
  }

  Future<void> deleteMovement(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .doc(id)
          .delete();

      // Actualizar la lista local
      currentMonthMovements.removeWhere((movement) => movement['id'] == id);

      // Actualizar el balance total
      _financeController.getTotalBalance();

      Get.snackbar(
        'Éxito',
        'Movimiento eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el movimiento: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
