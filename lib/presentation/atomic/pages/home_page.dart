import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../molecules/navigation/bottom_nav_bar.dart';
import '../organisms/home/home_content.dart';
import '../organisms/wallet/wallet_content.dart';
import '../organisms/history/history_content.dart';
import '../organisms/profile/profile_content.dart';
import '../organisms/register/register_content.dart';
import '../../controllers/finance_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  late final FinanceController financeController;

  @override
  void initState() {
    super.initState();
    financeController = Get.put(FinanceController(), permanent: true);
  }

  final List<Widget> _pages = [
    HomeContent(),
    const WalletContent(),
    const RegisterContent(),
    const HistoryContent(),
    const ProfileContent(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Actualizar datos al cambiar de página
    if (index == 0) {
      // Si vuelve a Home
      financeController.getTotalBalance();
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
    return Scaffold(
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
        ],
      ),
    );
  }
}
