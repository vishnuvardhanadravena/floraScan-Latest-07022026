import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/main.dart';
import 'package:aiplantidentifier/utils/app_Toast.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:aiplantidentifier/views/aichatbot/aidietcoach.dart';
import 'package:aiplantidentifier/views/login_Screen.dart';
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

class _DrawerConfig {
  static const double headerHeight = 140;
  static const double borderRadius = 16;
  static const double menuItemHeight = 56;

  static const double defaultPadding = 16.0;
  static const double contentPadding = 20.0;
}

class _DrawerColors {
  static const Color primaryGradientStart = Color(0xFF2D5016);
  static const Color primaryGradientEnd = Color(0xFF4A7C2C);
  static const Color accentColor = Color(0xFF2D5016);
  static const Color accentLight = Color(0xFF5FB34F);
  static const Color hoverBackground = Color(0xFFF0F7E8);
  static const Color dividerColor = Color(0xFFE0E0E0);
}

class DrawerMenuItem {
  final int index;
  final IconData icon;
  final String label;
  final String? routeName;
  final VoidCallback? onTap;
  final bool isDividerAbove;

  const DrawerMenuItem({
    required this.index,
    required this.icon,
    required this.label,
    this.routeName,
    this.onTap,
    this.isDividerAbove = false,
  });
}

class AnimatedAppDrawer extends StatelessWidget {
  final BuildContext rootContext;

  const AnimatedAppDrawer({super.key, required this.rootContext});

  void _initializeMenuItems(BuildContext context) {
    // Menu items initialization
  }

  Future<void> _handleLogout() async {
    _showLoadingDialog(rootContext);

    try {
      await Future.wait([
        _logoutLogic(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

      // Navigator.of(rootContext, rootNavigator: true).pop();
      appNavigatorKey.currentState!.popUntil((route) => route.isFirst);
      appNavigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      appNavigatorKey.currentState!.pop();
      AppToast.error('Logout failed. Please try again.');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
    );
  }

  Future<void> _logoutLogic() async {
    printRed("calling log out.......");
    await AppSettings.saveData(
      'USER_ISLOGIN',
      false,
      SharedPreferenceIOType.BOOL,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      DrawerMenuItem(
        index: 0,
        icon: Icons.home_rounded,
        label: 'Home',
        routeName: '/home',
      ),
      DrawerMenuItem(
        index: 1,
        icon: Icons.person_rounded,
        label: 'Profile',
        routeName: '/profile',
      ),
      DrawerMenuItem(
        index: 2,
        icon: Icons.settings_rounded,
        label: 'Settings',
        routeName: '/settings',
      ),
      DrawerMenuItem(
        index: 3,
        icon: Icons.logout_rounded,
        label: 'Logout',
        isDividerAbove: true,
        onTap: () => _handleLogout(),
      ),
    ];

    return Drawer(
      elevation: 16,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: _DrawerConfig.defaultPadding),
              Expanded(child: _buildMenuItems(context, menuItems)),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_DrawerConfig.defaultPadding),
      decoration: _buildHeaderDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Vishnuvardhan',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'VishnuVardhanadravena02@gmail.com',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildHeaderDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          _DrawerColors.primaryGradientStart,
          _DrawerColors.primaryGradientEnd,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomRight: Radius.circular(_DrawerConfig.borderRadius),
      ),
      boxShadow: [
        BoxShadow(
          color: _DrawerColors.primaryGradientStart.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildMenuItems(BuildContext context, List<DrawerMenuItem> menuItems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Column(
          children: [
            if (item.isDividerAbove)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Divider(color: _DrawerColors.dividerColor, thickness: 1),
              ),
            _buildMenuItemTile(context, item),
          ],
        );
      },
    );
  }

  Widget _buildMenuItemTile(BuildContext context, DrawerMenuItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_DrawerConfig.borderRadius),
        border: Border.all(color: Colors.transparent, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_DrawerConfig.borderRadius),
          onTap: () => _handleMenuItemTap(context, item),
          hoverColor: _DrawerColors.hoverBackground,
          splashColor: _DrawerColors.accentColor.withOpacity(0.2),
          highlightColor: _DrawerColors.accentColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _DrawerConfig.contentPadding,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildMenuIcon(item.icon),
                const SizedBox(width: 16),
                Expanded(child: _buildMenuLabel(item.label)),
                _buildMenuTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _DrawerColors.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _DrawerColors.accentColor, size: 24),
    );
  }

  Widget _buildMenuLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2C2C2C),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildMenuTrailing() {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 14,
      color: Colors.grey.shade400,
    );
  }

  void _handleMenuItemTap(BuildContext context, DrawerMenuItem item) {
    Navigator.pop(context);

    if (item.onTap != null) {
      item.onTap!();
    } else if (item.routeName != null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        switch (item.routeName) {
          case '/home':
            printRed("calling home... ");
            // Navigator.pushNamed(context, '/home');
            break;

          case '/profile':
            printRed("calling profile... ");
            break;

          case '/settings':
            printRed("calling settings... ");
            break;

          case '/logout':
            _handleLogout();
            break;

          default:
            debugPrint('Unknown route: ${item.routeName}');
        }
      });
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(_DrawerConfig.defaultPadding),
      child: Column(
        children: [
          const Divider(color: _DrawerColors.dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterIcon(Icons.info_outline_rounded),
              const SizedBox(width: 8),
              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(IconData icon) {
    return Icon(icon, size: 16, color: Colors.grey.shade400);
  }
}
