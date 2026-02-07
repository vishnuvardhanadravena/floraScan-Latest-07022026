import 'package:aiplantidentifier/main.dart';
import 'package:aiplantidentifier/views/aichatbot/aidietcoach.dart';
import 'package:aiplantidentifier/views/plantsdiary/dairy_list_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';

import '../history/plant_history.dart';
import '../plantidentification/plant.dart';
import '../progress/growth_screen.dart';
import '../plantscareroutine/careroutine.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  static const String _tabRootRoute = 'tab_root';

  late final List<GlobalKey<NavigatorState>> _navigatorKeys;
  late final List<_TabConfig> _tabs;

  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initTabs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _initTabs() {
    _navigatorKeys = List.generate(5, (_) => GlobalKey<NavigatorState>());

    _tabs = const [
      _TabConfig(
        screen: PlantIdentificationScreen(),
        icon: 'images/icons/home.png',
        activeIcon: 'images/icons/home.png',
        label: 'Home',
      ),
      _TabConfig(
        screen: PlantHistoryScreen(),
        icon: 'images/icons/history.png',
        activeIcon: 'images/icons/history.png',
        label: 'History',
      ),
      _TabConfig(
        screen: GrowthScreen(),
        icon: 'images/icons/chart.png',
        activeIcon: 'images/icons/chart.png',
        label: 'Growth',
      ),
      _TabConfig(
        screen: RoutineScreen(),
        icon: 'images/icons/tabler_repeat.png',
        activeIcon: 'images/icons/tabler_repeat.png',
        label: 'Routine',
      ),
      _TabConfig(
        screen: PlantListScreen(),
        icon: 'images/icons/book.png',
        activeIcon: 'images/icons/book.png',
        label: 'Diary',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _buildBody(),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        IndexedStack(
          index: _currentIndex,
          children: List.generate(
            _tabs.length,
            (index) => _buildTabNavigator(index),
          ),
        ),

        if (_isChatOpen)
          Positioned.fill(
            child: AIPlantIdentifierScreen(
              onClose: () {
                setState(() => _isChatOpen = false);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTabNavigator(int index) {
    if (index == 3) {
      RoutineRefreshNotifier.refresh();
    }
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute:
          (_) => MaterialPageRoute(
            settings: const RouteSettings(name: _tabRootRoute),
            builder: (_) => _tabs[index].screen,
          ),
    );
  }

  Widget? _buildFAB() {
    return !_isChatOpen
        ? FloatingActionButton(
          heroTag: null,
          elevation: 10,
          shape: const CircleBorder(),
          backgroundColor: AppColors.primaryColor,
          onPressed: _openAIChat,
          child: Image.asset(
            'images/bot_icon.png',

            // width: 24,
            // height: 24,
            color: Colors.white,
          ),
        )
        : null;
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDarkGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            backgroundColor: AppColors.backgroundDarkGreen,
            elevation: 0, // Remove default elevation
            items:
                _tabs.map((tab) {
                  final isActive = _tabs.indexOf(tab) == _currentIndex;
                  return BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage(isActive ? tab.activeIcon : tab.icon),
                    ),
                    label: tab.label,
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil(
        (r) => r.settings.name == _tabRootRoute,
      );
      return;
    }
    setState(() {
      _isChatOpen = false;
    });

    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
  }

  void _openAIChat() {
    setState(() => _isChatOpen = !_isChatOpen);
    HapticFeedback.mediumImpact();
  }

  void _handleBack(bool didPop, dynamic result) async {
    if (didPop) return;

    // Close AI chat if open
    if (_isChatOpen) {
      setState(() => _isChatOpen = false);
      return;
    }

    final nav = _navigatorKeys[_currentIndex].currentState;

    if (nav?.canPop() ?? false) {
      nav!.pop();
      return;
    }

    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return;
    }

    final exit = await _confirmExit();
    if (exit && mounted) SystemNavigator.pop();
  }

  Future<bool> _confirmExit() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Do you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}

class _TabConfig {
  final Widget screen;
  final String icon;
  final String activeIcon;
  final String label;

  const _TabConfig({
    required this.screen,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
