import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/user_service.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final ApiService _apiService = ApiService();
  String userName = "Kullanıcı";

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final name = await _apiService.getUserName();
      if (mounted && name != null) {
        setState(() {
          userName = name;
        });
      }
    } catch (e) {
      // Hata olursa default "Kullanıcı" kalır
    }
  }

  void _logout() async {
    await _apiService.deleteToken();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb && MediaQuery.of(context).size.width > 800;

    if (!isWeb) {
      // Mobilde navbar yok, sadece child'ı göster
      return widget.child;
    }

    // Web'de navbar ile göster
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          _buildWebSidebar(),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildWebSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF1A1D29),
      child: Column(
        children: [
          // LOGO
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Finans Takip",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // USER INFO
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Kullanıcı",
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // NAVIGATION ITEMS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _sidebarNavItem(
                  icon: Icons.home_outlined,
                  label: "Ana Sayfa",
                  isActive: widget.currentRoute == '/home',
                  onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                ),
                _sidebarNavItem(
                  icon: Icons.receipt_long_outlined,
                  label: "İşlemler",
                  isActive: widget.currentRoute == '/transactions',
                  onTap: () => Navigator.pushReplacementNamed(context, '/transactions'),
                ),
                _sidebarNavItem(
                  icon: Icons.subscriptions_outlined,
                  label: "Abonelikler",
                  isActive: widget.currentRoute == '/subscriptions',
                  onTap: () => Navigator.pushReplacementNamed(context, '/subscriptions'),
                ),
                _sidebarNavItem(
                  icon: Icons.flag_outlined,
                  label: "Hedefler",
                  isActive: widget.currentRoute == '/goals',
                  onTap: () => Navigator.pushReplacementNamed(context, '/goals'),
                ),
                _sidebarNavItem(
                  icon: Icons.monetization_on_outlined,
                  label: "Currency",
                  isActive: widget.currentRoute == '/currency',
                  onTap: () => Navigator.pushReplacementNamed(context, '/currency'),
                ),
              ],
            ),
          ),

          // LOGOUT BUTTON
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _logout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout_outlined, size: 20, color: Colors.white70),
                    SizedBox(width: 12),
                    Text(
                      "Çıkış",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepPurple.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.deepPurple : Colors.white70,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.deepPurple : Colors.white70,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}