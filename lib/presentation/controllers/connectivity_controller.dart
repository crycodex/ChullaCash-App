import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker =
      InternetConnectionChecker();

  final RxBool isConnected = true.obs;
  final RxBool isInitialCheck = true.obs;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  Future<void> _initConnectivity() async {
    try {
      // Asumimos que hay conexión inicialmente para evitar falsos negativos
      isConnected.value = true;

      // Verificamos la conectividad del dispositivo
      final ConnectivityResult result = await _connectivity.checkConnectivity();

      // Solo si no hay ninguna conexión de red, marcamos como desconectado
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
      } else {
        // Si hay conexión de red, verificamos si hay acceso real a Internet
        isConnected.value = await _connectionChecker.hasConnection;

        // Imprimimos el estado para depuración
        debugPrint(
            'Estado de conexión inicial: ${isConnected.value ? 'Conectado' : 'Desconectado'}');
      }

      isInitialCheck.value = false;
    } catch (e) {
      debugPrint('Error al verificar la conectividad inicial: $e');
      // En caso de error, asumimos que hay conexión para evitar bloquear la app
      isConnected.value = true;
      isInitialCheck.value = false;
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    try {
      if (result == ConnectivityResult.none) {
        isConnected.value = false;
        debugPrint('Cambio de conexión: Sin conexión de red');
      } else {
        // Verificar si realmente hay conexión a Internet
        final bool hasConnection = await _connectionChecker.hasConnection;
        isConnected.value = hasConnection;
        debugPrint(
            'Cambio de conexión: ${hasConnection ? 'Conectado' : 'Desconectado'} (${result.name})');
      }
    } catch (e) {
      debugPrint('Error al actualizar estado de conexión: $e');
      // En caso de error, asumimos que hay conexión para evitar bloquear la app
      isConnected.value = true;
    }
  }

  Future<void> checkConnectivity() async {
    try {
      debugPrint('Verificando conectividad manualmente...');
      final ConnectivityResult result = await _connectivity.checkConnectivity();

      if (result == ConnectivityResult.none) {
        isConnected.value = false;
        debugPrint('Verificación manual: Sin conexión de red');
      } else {
        // Verificar si realmente hay conexión a Internet
        final bool hasConnection = await _connectionChecker.hasConnection;
        isConnected.value = hasConnection;
        debugPrint(
            'Verificación manual: ${hasConnection ? 'Conectado' : 'Desconectado'} (${result.name})');
      }
    } catch (e) {
      debugPrint('Error al verificar la conectividad manualmente: $e');
      // En caso de error, asumimos que hay conexión para evitar bloquear la app
      isConnected.value = true;
    }
  }
}
