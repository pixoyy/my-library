import 'package:flutter/material.dart';
import 'package:my_library/core/theme/app_theme.dart';
import '../data/fake_db/auth_store.dart';

class AppDrawer extends StatelessWidget {
  final Function(int) onMenuTap;
  final int currentIndex;

  const AppDrawer({
    super.key,
    required this.onMenuTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthStore.currentUser!;

    return Drawer(
      backgroundColor: AppTheme.cream,
      child: Column(
        children: [
          // ================================
          // SECTION 1: PROFILE HEADER
          // ================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: AppTheme.brown,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cream,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: AppTheme.autumn,
                    child: Text(
                      user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ================================
          // SECTION 2: MENU
          // ================================
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _drawerItem(
                  Icons.home_outlined,
                  Icons.home,
                  'Home',
                  0,
                  context,
                ),
                _drawerItem(
                  Icons.category_outlined,
                  Icons.category,
                  'Category',
                  1,
                  context,
                ),
                _drawerItem(
                  Icons.bookmark_border,
                  Icons.bookmark,
                  'Bookmark',
                  2,
                  context,
                ),
                _drawerItem(
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                  3,
                  context,
                ),
              ],
            ),
          ),

          // ================================
          // SECTION 3: LOGOUT
          // ================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  AuthStore.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (_) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData iconOutlined,
    IconData iconFilled,
    String title,
    int index,
    BuildContext context,
  ) {
    final isActive = currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        selected: isActive,
        selectedTileColor: AppTheme.brown.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          isActive ? iconFilled : iconOutlined,
          color: isActive ? AppTheme.brown : Colors.grey[600],
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppTheme.brown : Colors.grey[800],
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          onMenuTap(index);
        },
      ),
    );
  }
}
