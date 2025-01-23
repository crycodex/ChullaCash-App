import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//idioma
import 'package:provider/provider.dart';
import '../../../change_notifier.dart';

//controllers
import 'package:get/get.dart';
import '../../controllers/Login/auth_controller.dart';
import './Login/content/login_content.dart';
import './Login/content/register_content.dart';

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

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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

                // Botón de idioma
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PopupMenuButton<Locale>(
                      icon: Icon(Icons.language,
                          color: AppColors.primaryBlue, size: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (Locale locale) {
                        final provider =
                            Provider.of<LocaleProvider>(context, listen: false);
                        provider.setLocale(locale);
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: const Locale('es'),
                          child: Row(
                            children: const [
                              Text('🇪🇸  Español',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: const Locale('en'),
                          child: Row(
                            children: const [
                              Text('🇺🇸  English',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ],
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
                          AppLocalizations.of(context)!.welcomeTitle,
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
                          AppLocalizations.of(context)!.welcomeDescription,
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
                                color: Colors.black.withOpacity(0.1),
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
                              AppLocalizations.of(context)!.welcomeButton,
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
                              AppLocalizations.of(context)!.welcomeNoAccount,
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
                                AppLocalizations.of(context)!.welcomeRegister,
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
              return _buildFloatingCard(
                context,
                child: LoginContent(onClose: authController.closeAll),
              );
            }
            if (authController.showRegister.value) {
              return _buildFloatingCard(
                context,
                child: RegisterContent(onClose: authController.closeAll),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFloatingCard(BuildContext context, {required Widget child}) {
    return GestureDetector(
      onTap: () => Get.find<AuthController>().closeAll(),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Evita que el tap se propague al fondo
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
