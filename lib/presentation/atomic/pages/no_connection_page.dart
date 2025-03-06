import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../presentation/controllers/connectivity_controller.dart';
import '../../../presentation/theme/app_colors.dart';

class NoConnectionPage extends StatelessWidget {
  final VoidCallback onRetry;

  const NoConnectionPage({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityController = Get.find<ConnectivityController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animación de Lottie para WiFi
                Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_uu0x8lqv.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback a un icono si la animación falla
                    return const Icon(
                      Icons.wifi_off_rounded,
                      size: 100,
                      color: AppColors.primaryGreen,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  '¡Sin conexión a Internet!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Parece que no tienes conexión a Internet. Por favor, verifica tu conexión WiFi o datos móviles e intenta nuevamente.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Obx(
                  () => connectivityController.isInitialCheck.value
                      ? Column(
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Verificando conexión...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
