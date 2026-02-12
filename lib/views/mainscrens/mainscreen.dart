import 'package:aiplantidentifier/core/app_settings.dart';
import 'package:aiplantidentifier/main.dart';
import 'package:aiplantidentifier/providers/profile_provider.dart';
import 'package:aiplantidentifier/utils/app_Toast.dart';
import 'package:aiplantidentifier/utils/helper_methodes.dart';
import 'package:aiplantidentifier/views/aichatbot/aidietcoach.dart';
import 'package:aiplantidentifier/views/forgot_pass.dart';
import 'package:aiplantidentifier/views/login_Screen.dart';
import 'package:aiplantidentifier/views/plantsdiary/dairy_list_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aiplantidentifier/utils/app_colors.dart';
import 'package:provider/provider.dart';

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
        // backgroundColor: Colors.white70,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'images/app_background.png',
                fit: BoxFit.cover,
              ),
            ),

            _buildBody(),
          ],
        ),
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
  static const double headerHeight = 200;
  static const double borderRadius = 20;
  static const double menuItemHeight = 56;
  static const double defaultPadding = 16.0;
  static const double contentPadding = 6.0;
  static const double animationDuration = 300;
}

class _DrawerColors {
  static const Color primaryGradientStart = Color(0xFF2D5016);
  static const Color primaryGradientEnd = Color(0xFF4A7C2C);

  static const Color accentColor = Color(0xFF2D5016);
  static const Color accentLight = Color(0xFF5FB34F);
  static const Color accentExtraLight = Color(0xFFF0F7E8);

  static const Color dividerColor = Color(0xFFE8E8E8);
  static const Color hoverBackground = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF8A8A8A);

  static const Color dangerColor = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF34C759);
}

class _DrawerTypography {
  static const headerNameStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -0.5,
  );

  static const headerEmailStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFFE8E8E8),
    letterSpacing: 0.1,
  );

  static const menuLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: _DrawerColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const menuLabelSecondaryStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: _DrawerColors.textSecondary,
    letterSpacing: 0.1,
  );

  static const footerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _DrawerColors.textSecondary,
    letterSpacing: 0.2,
  );
}

enum MenuItemType { navigation, divider, settings, danger }

class DrawerMenuItem {
  final int index;
  final IconData icon;
  final String label;
  final String? description;
  final String? routeName;
  final VoidCallback? onTap;
  final MenuItemType type;
  final bool showBadge;
  final int? badgeCount;
  final Widget? trailing;

  const DrawerMenuItem({
    required this.index,
    required this.icon,
    required this.label,
    this.description,
    this.routeName,
    this.onTap,
    this.type = MenuItemType.navigation,
    this.showBadge = false,
    this.badgeCount,
    this.trailing,
  });
}

class _ProfileAnimationNotifier extends ChangeNotifier {
  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  void toggle() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }

  void reset() {
    _isExpanded = false;
    notifyListeners();
  }
}

class TelegramStyleDrawer extends StatefulWidget {
  final BuildContext rootContext;
  final String? userName;
  final String? userEmail;
  final String? userPhoneNumber;
  final String? userAvatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLogout;

  const TelegramStyleDrawer({
    super.key,
    required this.rootContext,
    this.userName,
    this.userEmail,
    this.userPhoneNumber,
    this.userAvatarUrl,
    this.onProfileTap,
    this.onSettingsTap,
    this.onLogout,
  });

  @override
  State<TelegramStyleDrawer> createState() => _TelegramStyleDrawerState();
}

class _TelegramStyleDrawerState extends State<TelegramStyleDrawer>
    with TickerProviderStateMixin {
  late AnimationController _drawerAnimationController;
  late AnimationController _itemsAnimationController;
  late Animation<Offset> _drawerSlideAnimation;
  late Animation<double> _itemsFadeAnimation;
  String? userName = "UserName";
  String? userEmail;
  @override
  void initState() {
    super.initState();
    userName = AppSettings.userLoginDetails.display_name;
    userEmail = AppSettings.userLoginDetails.display_name;
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _drawerSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _drawerAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _itemsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _itemsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _itemsAnimationController, curve: Curves.easeOut),
    );

    _drawerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _itemsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    _itemsAnimationController.dispose();
    super.dispose();
  }

  List<DrawerMenuItem> _getMenuItems() {
    return [
      DrawerMenuItem(
        index: 1,
        icon: Icons.lock_rounded,
        label: 'Change Password',
        description: 'Update your security',
        routeName: '/change-password',
        onTap: () {
          appNavigatorKey.currentState!.popUntil((route) => route.isFirst);
          appNavigatorKey.currentState!.push(
            MaterialPageRoute(
              builder: (_) => ForgotPasswordPage(username: "email"),
            ),
          );
        },
      ),

      DrawerMenuItem(
        index: 7,
        icon: Icons.logout_rounded,
        label: '',
        type: MenuItemType.divider,
      ),

      // Logout
      DrawerMenuItem(
        index: 8,
        icon: Icons.logout_rounded,
        label: 'Logout',
        description: 'Sign out from account',
        type: MenuItemType.danger,
        onTap: () => _handleLogout(),
      ),
    ];
  }

  Future<void> _logoutLogic() async {
    printRed("calling log out.......");
    await AppSettings.saveData(
      'USER_ISLOGIN',
      false,
      SharedPreferenceIOType.BOOL,
    );

    await AppSettings.saveData('USER_TOKEN', "", SharedPreferenceIOType.STRING);
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

  Future<void> _handleLogout() async {
    _showLoadingDialog(widget.rootContext);

    try {
      await Future.wait([
        _logoutLogic(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

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

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();

    return SlideTransition(
      position: _drawerSlideAnimation,
      child: Drawer(
        elevation: 0,
        backgroundColor: Colors.white,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildMenuItems(menuItems)),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      padding: const EdgeInsets.all(_DrawerConfig.defaultPadding),
      decoration: _buildHeaderDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(child: _buildUserInfo()),
              _buildHeaderActionButton(),
            ],
          ),
          if (widget.userPhoneNumber != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.userPhoneNumber!,
              style: _DrawerTypography.headerEmailStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: _DrawerColors.primaryGradientStart.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            _DrawerColors.accentLight.withOpacity(0.3),
            _DrawerColors.accentColor.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white30, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          widget.userAvatarUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  widget.userAvatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildAvatarPlaceholder(),
                ),
              )
              : _buildAvatarPlaceholder(),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final initials =
        (userName ?? 'U')
            .split(' ')
            .where((e) => e.isNotEmpty)
            .take(2)
            .map((e) => e[0].toUpperCase())
            .join();

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          userName ?? 'User',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _DrawerTypography.headerNameStyle,
        ),
        const SizedBox(height: 6),
        Text(
          userEmail ?? 'email@example.com',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _DrawerTypography.headerEmailStyle,
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onSettingsTap ?? () => Navigator.pop(context),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.settings_rounded,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems(List<DrawerMenuItem> items) {
    return FadeTransition(
      opacity: _itemsFadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (item.type == MenuItemType.divider) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: _DrawerConfig.defaultPadding,
              ),
              child: Divider(
                height: 1,
                color: _DrawerColors.dividerColor,
                thickness: 1,
              ),
            );
          }

          return _AnimatedMenuItem(
            delay: Duration(milliseconds: 50 + (index * 40)),
            child: _buildMenuItemTile(context, item),
          );
        },
      ),
    );
  }

  Widget _buildMenuItemTile(BuildContext context, DrawerMenuItem item) {
    final isDanger = item.type == MenuItemType.danger;
    final isSettings = item.type == MenuItemType.settings;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _DrawerConfig.defaultPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_DrawerConfig.borderRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            item.onTap?.call();
          },
          borderRadius: BorderRadius.circular(_DrawerConfig.borderRadius),
          hoverColor:
              isDanger
                  ? _DrawerColors.dangerColor.withOpacity(0.05)
                  : _DrawerColors.hoverBackground,
          splashColor:
              isDanger
                  ? _DrawerColors.dangerColor.withOpacity(0.1)
                  : _DrawerColors.accentColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _DrawerConfig.contentPadding,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildMenuIcon(item.icon, isDanger, isSettings),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isDanger
                                  ? _DrawerColors.dangerColor
                                  : _DrawerColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: _DrawerColors.textSecondary.withOpacity(0.7),
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.showBadge && item.badgeCount != null)
                  _buildBadge(item.badgeCount!),
                if (item.trailing != null) item.trailing!,
                if (!isDanger && item.description != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, bool isDanger, bool isSettings) {
    final bgColor =
        isDanger
            ? _DrawerColors.dangerColor.withOpacity(0.1)
            : isSettings
            ? _DrawerColors.accentLight.withOpacity(0.15)
            : _DrawerColors.accentColor.withOpacity(0.08);

    final iconColor =
        isDanger
            ? _DrawerColors.dangerColor
            : isSettings
            ? _DrawerColors.accentLight
            : _DrawerColors.accentColor;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 18),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _DrawerColors.dangerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(_DrawerConfig.defaultPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _DrawerColors.dividerColor, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: _DrawerColors.textSecondary.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text('App Version 1.0.0', style: _DrawerTypography.footerStyle),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Your Company',
            style: _DrawerTypography.footerStyle.copyWith(
              fontSize: 10,
              color: _DrawerColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMenuItem extends StatefulWidget {
  final Duration delay;
  final Widget child;

  const _AnimatedMenuItem({required this.delay, required this.child});

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}
