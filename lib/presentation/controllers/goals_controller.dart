import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import './finance_controller.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GoalsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FinanceController _financeController = Get.find<FinanceController>();

  // Controlador para el confeti
  late ConfettiController confettiControllerCenter;

  final RxList<Map<String, dynamic>> goals = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCelebrating = false.obs;

  // Getter para obtener el balance actual
  double get currentBalance => _financeController.allTimeBalance.value;

  @override
  void onInit() {
    super.onInit();
    // _initAudioPlayer(); // Comentado temporalmente
    _initConfettiControllers();
    loadGoals();
    // Escuchar cambios en el balance total
    ever(_financeController.allTimeBalance, (_) => _checkGoalsProgress());
  }

  void _initConfettiControllers() {
    confettiControllerCenter =
        ConfettiController(duration: const Duration(seconds: 5));
  }

  // Future<void> _initAudioPlayer() async {
  //   try {
  //     _audioPlayer = AudioPlayer();
  //     await _audioPlayer?.setSource(AssetSource('sounds/success.mp3'));
  //   } catch (e) {
  //     print('Error inicializando audio player: $e');
  //   }
  // }

  // Método simplificado para verificar el progreso de los objetivos
  Future<void> _checkGoalsProgress() async {
    if (goals.isEmpty) return;

    try {
      // Crear una copia inmutable de los objetivos actuales
      final currentGoals = List<Map<String, dynamic>>.from(goals);
      final updatedGoals = <Map<String, dynamic>>[];
      final goalsToUpdate = <String, Map<String, dynamic>>{};

      for (final goal in currentGoals) {
        if (goal['isCompleted'] == true) {
          updatedGoals.add(Map<String, dynamic>.from(goal));
          continue;
        }

        final targetAmount = goal['targetAmount'] as double;
        final progress = currentBalance / targetAmount;
        final isCompleted = progress >= 1.0;

        final updatedGoal = Map<String, dynamic>.from(goal)
          ..addAll({
            'currentAmount': currentBalance > 0 ? currentBalance : 0.0,
            'progress': progress > 0 ? progress : 0.0,
            'isCompleted': isCompleted,
          });

        if (isCompleted && !goal['isCompleted']) {
          // Manejar la celebración
          startCelebration();
          Get.snackbar(
            '¡Felicitaciones! 🎉',
            'Has alcanzado tu objetivo: ${goal['title']}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );

          // Eliminar el objetivo completado
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('goals')
              .doc(goal['id'])
              .delete();

          await Future.delayed(const Duration(seconds: 3));
          stopCelebration();
        } else {
          updatedGoals.add(updatedGoal);
          goalsToUpdate[goal['id']] = updatedGoal;
        }
      }

      // Actualizar objetivos en Firestore
      for (final entry in goalsToUpdate.entries) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .collection('goals')
            .doc(entry.key)
            .update({
          'currentAmount': entry.value['currentAmount'],
          'progress': entry.value['progress'],
          'isCompleted': entry.value['isCompleted'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Actualizar la lista local solo al final
      goals.value = updatedGoals;
    } catch (e) {
      debugPrint('Error en _checkGoalsProgress: $e');
    }
  }

  void startCelebration() {
    isCelebrating.value = true;
    confettiControllerCenter.play();
  }

  void stopCelebration() {
    isCelebrating.value = false;
    confettiControllerCenter.stop();
  }

  Future<void> loadGoals() async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .orderBy('createdAt', descending: true)
          .get();

      goals.value = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      // Verificar progreso después de cargar los objetivos
      _checkGoalsProgress();
    } catch (e) {
      debugPrint('Error al cargar objetivos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Asegurarse de tener el balance más reciente
      await _financeController.getTotalBalance();
      final currentAmount = currentBalance > 0 ? currentBalance : 0.0;
      final initialProgress = currentAmount / targetAmount;

      final goalData = {
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isCompleted': initialProgress >= 1.0,
        'progress': initialProgress > 0 ? initialProgress : 0.0,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .add(goalData);

      await loadGoals();
    } catch (e) {
      debugPrint('Error al agregar objetivo: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .delete();

      // Eliminar el objetivo de la lista local
      goals.removeWhere((goal) => goal['id'] == goalId);
      goals.refresh();

      // Si era el último objetivo, mostrar mensaje
      if (goals.isEmpty) {
        Get.snackbar(
          'Información',
          'No tienes objetivos activos. ¡Crea uno nuevo!',
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('Error al eliminar objetivo: $e');
      Get.snackbar(
        'Error',
        'No se pudo eliminar el objetivo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateGoal({
    required String goalId,
    required String title,
    required double targetAmount,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Asegurarse de tener el balance más reciente
      await _financeController.getTotalBalance();
      final currentAmount = currentBalance > 0 ? currentBalance : 0.0;
      final progress = currentAmount / targetAmount;

      final goalData = {
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
        'progress': progress > 0 ? progress : 0.0,
        'isCompleted': progress >= 1.0,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('goals')
          .doc(goalId)
          .update(goalData);

      await loadGoals();
    } catch (e) {
      debugPrint('Error al actualizar objetivo: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar el objetivo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    confettiControllerCenter.dispose();
    super.onClose();
  }
}
