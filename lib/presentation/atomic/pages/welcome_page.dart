import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'dart:math' as math;
import '../../../services/ad_service.dart';

//controllers
import 'package:get/get.dart';
import '../../controllers/Login/auth_controller.dart';
import '../organisms/auth/login_content.dart';
import '../organisms/auth/register_content.dart';
import '../organisms/auth/forgot_password_content.dart';
import '../molecules/Login/bottom_sheet/custom_bottom_sheet.dart';

// Curva personalizada animada
class AnimatedWavePainter extends CustomPainter {
  final Animation<double> animation;

  AnimatedWavePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.65);

    // Animación de la curva
    final animValue = math.sin(animation.value * 2 * math.pi) * 0.01;

    // Primera curva (superior)
    path.quadraticBezierTo(
      size.width * (0.25 + animValue),
      size.height * (0.45 - animValue),
      size.width * 0.5,
      size.height * 0.65,
    );

    // Segunda curva (inferior)
    path.quadraticBezierTo(
      size.width * (0.75 - animValue),
      size.height * (0.85 + animValue),
      size.width,
      size.height * 0.65,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class AnimatedWave extends StatefulWidget {
  final double height;

  const AnimatedWave({super.key, required this.height});

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AnimatedWavePainter(_controller),
      size: Size(double.infinity, widget.height),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _initAds();
  }

  void _initAds() async {
    try {
      debugPrint('👋 Iniciando configuración de anuncios en WelcomePage...');
      await Future.delayed(const Duration(seconds: 1));
      _adService.loadInterstitialAd();

      // Mostrar el anuncio después de un breve retraso
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('⏰ Mostrando anuncio en WelcomePage...');
      _adService.showInterstitialAd();
    } catch (e) {
      debugPrint('❌ Error al inicializar anuncios en WelcomePage: $e');
    }
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authController = Get.put(AuthController());

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreenDark,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Curva superior animada
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedWave(height: size.height * 0.4),
                ),

                // Logo sobre la curva
                Positioned(
                  top: 50,
                  left: (size.width - 120) / 2,
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Image.asset(
                      'lib/assets/icons/icon_removebg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: size.height * 0.35),
                        Text(
                          'Lleva el control de tu dinero sin esfuerzo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Gestiona tus finanzas fácilmente con nuestra interfaz intuitiva y amigable. Establece metas financieras, controla tu presupuesto y haz un seguimiento de tus gastos en un solo lugar.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 120),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => authController.toggleLogin(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Iniciar sesión',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No tienes una cuenta?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () => authController.toggleRegister(),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Registrarse',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Cards flotantes
          Obx(() {
            if (authController.showLogin.value) {
              return CustomBottomSheet(
                onClose: authController.closeAll,
                child: LoginContent(onClose: authController.closeAll),
              );
            }
            if (authController.showRegister.value) {
              return CustomBottomSheet(
                onClose: authController.closeAll,
                child: RegisterContent(onClose: authController.closeAll),
              );
            }
            if (authController.showForgotPassword.value) {
              return CustomBottomSheet(
                onClose: authController.closeAll,
                child: ForgotPasswordContent(onClose: authController.closeAll),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
