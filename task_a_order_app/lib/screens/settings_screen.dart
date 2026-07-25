import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/order.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://digitalheroesco.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Very light soft background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF475569), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF6366F1)], // Blue to Indigo
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'SM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Store Manager',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'manager@digitalheroesco.com',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 32),
            
            // Statistics Card (Glassmorphism with blurred blobs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 110,
                  child: Stack(
                    children: [
                      // White base
                      Container(color: Colors.white),
                      // Blue Blob
                      Positioned(
                        top: -20,
                        left: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF93C5FD), // Light Blue
                          ),
                        ),
                      ),
                      // Orange Blob
                      Positioned(
                        bottom: -30,
                        right: -10,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFDBA74), // Light Orange
                          ),
                        ),
                      ),
                      // Blue center blob
                      Positioned(
                        bottom: -10,
                        left: 140,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFBAE6FD), // Light cyan
                          ),
                        ),
                      ),
                      // Blur Effect Overlay
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      // Content
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(context, ref, 'Total Orders', (orders) => orders.length.toString(), const Color(0xFF2563EB)),
                            _buildStatColumn(context, ref, 'Pending', (orders) => orders.where((o) => o.status.name == 'pending').length.toString(), const Color(0xFFF59E0B)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Menu Items List (Single Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListTile(Icons.notifications_none, 'Notifications', trailing: CupertinoSwitch(value: _notificationsEnabled, activeColor: const Color(0xFF3B82F6), onChanged: (val) => setState(() => _notificationsEnabled = val))),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
                    _buildListTile(Icons.dark_mode_outlined, 'Dark Mode', trailing: CupertinoSwitch(value: _darkModeEnabled, onChanged: (val) => setState(() => _darkModeEnabled = val))),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
                    _buildListTile(Icons.shield_outlined, 'Privacy & Security'),
                    const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9)),
                    _buildListTile(Icons.help_outline, 'Help & Support'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Footer Link
            SafeArea(
              child: InkWell(
                onTap: _launchUrl,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Built for Digital Heroes Training Task 🚀',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, WidgetRef ref, String label, String Function(List<OrderModel>) getStat, Color color) {
    final ordersState = ref.watch(ordersProvider);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ordersState.when(
          data: (orders) => Text(
            getStat(orders),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => const Text('-'),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF475569), size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
          fontSize: 15,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Color(0xFFCBD5E1), size: 14),
      onTap: trailing == null ? () {} : null,
    );
  }
}
