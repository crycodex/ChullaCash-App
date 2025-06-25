import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../molecules/navigation/bottom_nav_bar.dart';
import '../organisms/home/home_content.dart';
import '../organisms/wallet/wallet_content.dart';
import '../organisms/goals/goals_content.dart';
import '../organisms/profile/profile_content.dart';
import '../organisms/register/register_content.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/goals_controller.dart';
import '../../../services/ad_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(keepPage: true);
  late final FinanceController financeController;
  late final GoalsController goalsController;
  final AdService _adService = AdService();

  final List<Widget> _pages = [
    const HomeContent(),
    const WalletContent(),
    const RegisterContent(),
    const GoalsContent(),
    const ProfileContent(),
  ];

  @override
  void initState() {
    super.initState();
    financeController = Get.put(FinanceController());
    goalsController = Get.put(GoalsController());
    Get.put(_pageController, permanent: true);
    _initializeControllers();
    _initAds();
  }

  void _initializeControllers() async {
    await financeController.loadTransactions();
    await financeController.getTotalBalance();
    await financeController.updateBalance();
  }

  void _initAds() async {
    try {
      debugPrint('🏠 Iniciando configuración de anuncios en HomePage...');
      // Solo cargar el anuncio, se mostrará automáticamente cuando esté listo
      await _adService.loadInterstitialAd();
    } catch (e) {
      debugPrint('❌ Error al inicializar anuncios en HomePage: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _adService.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) async {
    setState(() {
      _currentIndex = index;
    });
    // Actualizar datos al cambiar de página
    if (index == 0 || index == 1 || index == 3) {
      await financeController.loadTransactions();
      await financeController.getTotalBalance();
      await financeController.updateBalance();
    }
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _onNavItemTapped(0);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              children: _pages,
            ),
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavItemTapped,
            ),
            // Confeti desde arriba
            Obx(() => goalsController.isCelebrating.value
                ? Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController:
                          goalsController.confettiControllerCenter,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.3,
                      numberOfParticles: 100,
                      maxBlastForce: 20,
                      minBlastForce: 5,
                      gravity: 0.3,
                      shouldLoop: false,
                      colors: const [
                        Colors.green,
                        Colors.blue,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                        Colors.yellow,
                      ],
                    ),
                  )
                : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
