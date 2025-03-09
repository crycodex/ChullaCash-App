import 'dart:async';
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
  final RxBool isLoading = false.obs;

  final FinanceController _financeController = Get.put(FinanceController());
  StreamSubscription? _movementsSubscription;

  @override
  void onInit() {
    super.onInit();
    try {
      final now = DateTime.now();
      setupMovementsStream(now.year, now.month);
    } catch (e) {
      print('Error en onInit: $e');
    }
  }

  void setupMovementsStream(int year, int month) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Usuario no autenticado');
        return;
      }

      _movementsSubscription?.cancel();
      isLoading.value = true;

      final collectionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month');

      // Verificar si la colección existe
      final collectionSnapshot = await collectionRef.get();
      if (collectionSnapshot.docs.isEmpty) {
        // Crear documento inicial si no existe
        await collectionRef.doc('info').set({
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      _movementsSubscription = collectionRef
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
        (snapshot) async {
          try {
            currentMonthMovements.value = snapshot.docs
                .where((doc) => doc.id != 'info')
                .map((doc) => {
                      'id': doc.id,
                      ...doc.data(),
                    })
                .toList();

            await _financeController.getTotalBalance();
            await _financeController.updateBalance();
          } catch (e) {
            print('Error procesando datos: $e');
            Get.snackbar(
              'Error',
              'Error al procesar los movimientos',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        onError: (error) {
          print('Error en stream: $error');
          Get.snackbar(
            'Error',
            'Error al obtener los movimientos',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error configurando stream: $e');
      Get.snackbar(
        'Error',
        'Error al configurar la sincronización',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    try {
      _movementsSubscription?.cancel();
    } catch (e) {
      print('Error en onClose: $e');
    }
    super.onClose();
  }

  String getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
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
    } catch (e) {
      print('Error en getTimeAgo: $e');
      return '';
    }
  }

  Future<void> deleteMovement(String id) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Obtener el documento antes de eliminarlo para verificar que existe
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .doc(id);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('El movimiento no existe');
      }

      await docRef.delete();

      // Actualizar la lista local
      currentMonthMovements.removeWhere((movement) => movement['id'] == id);
      await _financeController.getTotalBalance();

      Get.snackbar(
        'Éxito',
        'Movimiento eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error en deleteMovement: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el movimiento',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
