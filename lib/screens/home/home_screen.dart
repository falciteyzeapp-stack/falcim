import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reading_provider.dart';
import '../../theme/app_theme.dart';
import '../coffee/coffee_screen.dart';
import '../tarot/tarot_screen.dart';
import '../history/history_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    CoffeeScreen(),
    TarotScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ReadingProvider>().loadReadings(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF200A0A),
        border: Border(
          top: BorderSide(
            color: AppTheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: const Color(0xFF7A5050),
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Text('☕', style: TextStyle(fontSize: 22)),
            activeIcon: Text('☕', style: TextStyle(fontSize: 24)),
            label: 'Kahve',
          ),
          BottomNavigationBarItem(
            icon: Text('🃏', style: TextStyle(fontSize: 22)),
            activeIcon: Text('🃏', style: TextStyle(fontSize: 24)),
            label: 'Tarot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 24),
            activeIcon: Icon(Icons.history_rounded, size: 26),
            label: 'Geçmiş',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 24),
            activeIcon: Icon(Icons.settings_rounded, size: 26),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}
