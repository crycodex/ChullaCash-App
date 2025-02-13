import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FinanceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxDouble totalBalance = 0.0.obs;
  final RxList transactions = [].obs;
  final RxDouble allTimeBalance = 0.0.obs;
  final RxList<Map<String, double>> yearSummary = <Map<String, double>>[].obs;
  final RxList<Map<String, double>> monthSummary = <Map<String, double>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
    getTotalBalance();
    // Escuchar cambios en tiempo real
    _listenToTransactions();
  }

  void _listenToTransactions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc('${now.year}')
        .collection('${now.month}')
        .snapshots()
        .listen((snapshot) async {
      await loadTransactions();
      await getTotalBalance();
      await updateBalance();
    });
  }

  //comprobar si el año y el mes existen
  Future<void> _ensureYearMonthExists(
      String userId, int year, int month) async {
    final yearRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc('$year');

    final yearDoc = await yearRef.get();
    if (!yearDoc.exists) {
      await yearRef.set({
        'created_at': DateTime.now(),
        'year': year,
      });
    }

    final monthRef = yearRef.collection('$month');
    final monthQuery = await monthRef.limit(1).get();
    if (monthQuery.docs.isEmpty) {
      await monthRef.doc('info').set({
        'created_at': DateTime.now(),
        'month': month,
        'year': year,
      });
    }
  }

  //agregar ingreso
  Future<void> addIncome(double amount, String description) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Aseguramos que existan los documentos de año y mes
      await _ensureYearMonthExists(userId, year, month);

      // Primero guardamos la transacción
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .add({
        'type': 'income',
        'amount': amount,
        'description': description,
        'timestamp': now,
        'created_at': now,
        'updated_at': now,
      });

      // Luego actualizamos los balances en orden
      await loadTransactions();
      await updateBalance();
      await getTotalBalance();
    } catch (e) {
      print('Error al agregar ingreso: $e');
      rethrow;
    }
  }

  //agregar egreso
  Future<void> addExpense(double amount, String description) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Aseguramos que existan los documentos de año y mes
      await _ensureYearMonthExists(userId, year, month);

      // Primero guardamos la transacción
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .add({
        'type': 'expense',
        'amount': amount,
        'description': description,
        'timestamp': now,
        'created_at': now,
        'updated_at': now,
      });

      // Luego actualizamos los balances en orden
      await loadTransactions();
      await updateBalance();
      await getTotalBalance();
    } catch (e) {
      print('Error al agregar egreso: $e');
      rethrow;
    }
  }

  //cargar transacciones
  Future<void> loadTransactions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // Aseguramos que existan los documentos de año y mes antes de cargar
      await _ensureYearMonthExists(userId, year, month);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .orderBy('timestamp', descending: true)
          .get();

      transactions.value = snapshot.docs
          .where((doc) => doc.id != 'info') // Excluimos el documento info
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      await updateBalance();
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las transacciones: $e');
    }
  }

  //actualizar balance
  Future<void> updateBalance() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month')
          .get();

      double balance = 0.0;
      for (var doc in snapshot.docs) {
        if (doc.id == 'info') continue; // Saltamos el documento info
        final data = doc.data();
        if (data['type'] == 'income') {
          balance += (data['amount'] as num).toDouble();
        } else if (data['type'] == 'expense') {
          balance -= (data['amount'] as num).toDouble();
        }
      }

      totalBalance.value = balance;
    } catch (e) {
      print('Error al actualizar balance: $e');
      Get.snackbar('Error', 'No se pudo actualizar el balance: $e');
    }
  }

  //obtener balance total
  Future<void> getTotalBalance() async {
    if (isLoading.value) return; // Evitar múltiples llamadas simultáneas

    try {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      double total = 0.0;

      // Obtener todos los años
      final yearsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      // Recorrer cada año
      for (var yearDoc in yearsSnapshot.docs) {
        // Recorrer los meses del 1 al 12
        for (int month = 1; month <= 12; month++) {
          final monthTransactions = await _firestore
              .collection('users')
              .doc(userId)
              .collection('transactions')
              .doc(yearDoc.id)
              .collection(month.toString())
              .get();

          // Recorrer cada transacción del mes
          for (var doc in monthTransactions.docs) {
            if (doc.id == 'info') continue;

            final data = doc.data();
            if (data['type'] == 'income') {
              total += (data['amount'] as num).toDouble();
            } else if (data['type'] == 'expense') {
              total -= (data['amount'] as num).toDouble();
            }
          }
        }
      }

      // Actualizar el balance total observable
      allTimeBalance.value = total;
    } catch (e) {
      print('Error al calcular balance total: $e');
      Get.snackbar(
        'Error',
        'No se pudo calcular el balance total: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Obtener resumen por año
  Future<Map<String, double>> getYearSummary(int year) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final yearRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year');

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      // Recorrer los meses del 1 al 12
      for (int month = 1; month <= 12; month++) {
        final monthTransactions =
            await yearRef.collection(month.toString()).get();

        // Recorrer cada transacción del mes
        for (var doc in monthTransactions.docs) {
          if (doc.id == 'info') continue;

          final data = doc.data();
          if (data['type'] == 'income') {
            totalIncome += data['amount'] as double;
          } else if (data['type'] == 'expense') {
            totalExpense += data['amount'] as double;
          }
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo obtener el resumen del año: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return {};
    }
  }

  // Obtener resumen por mes
  Future<Map<String, double>> getMonthSummary(int year, int month) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return {};

      final monthRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc('$year')
          .collection('$month');

      final transactionsSnapshot = await monthRef.get();

      double totalIncome = 0.0;
      double totalExpense = 0.0;

      for (var doc in transactionsSnapshot.docs) {
        if (doc.id == 'info') continue;

        final data = doc.data();
        if (data['type'] == 'income') {
          totalIncome += data['amount'] as double;
        } else if (data['type'] == 'expense') {
          totalExpense += data['amount'] as double;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo obtener el resumen del mes: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return {};
    }
  }
}
