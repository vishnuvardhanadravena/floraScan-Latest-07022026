import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class PremiumAnimatedDrawer extends StatefulWidget {
  final Widget child;
  final List<DrawerItem> items;
  final String userName;
  final String userEmail;
  final String avatarUrl;

  const PremiumAnimatedDrawer({
    super.key,
    required this.child,
    required this.items,
    required this.userName,
    required this.userEmail,
    required this.avatarUrl,
  });

  @override
  State<PremiumAnimatedDrawer> createState() => _PremiumAnimatedDrawerState();
}

class _PremiumAnimatedDrawerState extends State<PremiumAnimatedDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  int _activeIndex = 0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 0.0,
    );

    _slideAnimation = CurvedAnimation(
      parent: _drawerController,
      curve: const Cubic(0.64, 0, 0.36, 1), // Elastic ease-out
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawerController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    if (_drawerController.isDismissed) {
      _drawerController.forward();
      setState(() => _isExpanded = true);
    } else {
      _drawerController.reverse().then((_) {
        setState(() => _isExpanded = false);
      });
    }
  }

  void _onItemTap(int index) {
    setState(() => _activeIndex = index);
    
    // Spring animation for active item
    final spring = SpringSimulation(
      const SpringDescription(mass: 0.5, stiffness: 200, damping: 15),
      1.0,
      0.95,
      0.0,
    );
    
    // Optional: Navigate to screen here
    _drawerController.reverse().then((_) {
      setState(() => _isExpanded = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          _drawerController.reverse();
        } else if (details.primaryVelocity! < -300) {
          _drawerController.forward();
        }
      },
      child: Stack(
        children: [
          // Main content with scale animation
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: _isExpanded ? _toggleDrawer : null,
              child: widget.child,
            ),
          ),
          
          // Drawer overlay
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(_slideAnimation),
            child: _buildDrawer(),
          ),
          
          // Dim overlay when drawer open
          if (_isExpanded)
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6B46C1),
            Color(0xFF44337A),
            Color(0xFF2D2A4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 40,
            spreadRadius: 10,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: ClipPath(
        clipper: _DrawerClipper(),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withOpacity(0.08),
            child: Column(
              children: [
                // Header with profile
                _buildHeader(),
                
                // Menu items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) => _buildMenuItem(
                      item: widget.items[index],
                      index: index,
                      isActive: _activeIndex == index,
                      onTap: () => _onItemTap(index),
                    ),
                  ),
                ),
                
                // Bottom actions
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 28),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.25),
            backgroundImage: NetworkImage(widget.avatarUrl),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF80AB), Color(0xFF8C9EFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF80AB).withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: Color(0x88000000), offset: Offset(0, 2), blurRadius: 4)
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.userEmail,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
            onPressed: _toggleDrawer,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required DrawerItem item,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutExpo,
      margin: EdgeInsets.only(
        left: isActive ? 16 : 24,
        right: 16,
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(isActive ? 18 : 16),
        border: Border(
  left: BorderSide(
    color: isActive ? const Color(0xFFFF80AB) : Colors.transparent,
    width: isActive ? 3 : 0,
  ),
),

        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFFF80AB).withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFF80AB).withOpacity(0.15)
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: isActive ? const Color(0xFFFF80AB) : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                shadows: isActive
                    ? const [
                        Shadow(
                          color: Color(0x44000000),
                          offset: Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const Spacer(),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.15),
          ],
        ),
      ),
      child: Row(
        children: [
          _buildActionCard(
            icon: Icons.settings,
            title: 'Settings',
            color: const Color(0xFF4FC3F7),
          ),
          const SizedBox(width: 16),
          _buildActionCard(
            icon: Icons.logout,
            title: 'Logout',
            color: const Color(0xFFFF6B6B),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    
    // Create curved top edge
    path.quadraticBezierTo(
      size.width * 0.2,
      60,
      size.width * 0.5,
      80,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      60,
      size.width,
      0,
    );
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DrawerItem {
  final String title;
  final IconData icon;
  final int? badgeCount;
  
  const DrawerItem({
    required this.title,
    required this.icon,
    this.badgeCount,
  });
}

