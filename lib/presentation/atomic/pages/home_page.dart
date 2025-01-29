import 'package:flutter/material.dart';
import '../molecules/navigation/bottom_nav_bar.dart';
import 'home_content.dart';
import 'wallet_content.dart';
import 'transfer_content.dart';
import 'profile_content.dart';
import 'register_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const WalletContent(),
    const RegisterContent(),
    const TransferContent(),
    const ProfileContent(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
