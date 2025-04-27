import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_control/screens/profile/profile_screen.dart';

import '../../common_widget/custom_dialog.dart';
import '../../data/provider/user_provider.dart';
import '../start/start_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Avatar và Tên
          Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(vertical: 30),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Text(
                    '${userProvider.user?.name[0]}',
                    style: TextStyle(color: Colors.blue, fontSize: 30),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${userProvider.user?.name}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${userProvider.user?.email}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Danh sách cài đặt
          Expanded(
            child: ListView(
              children: [
                _buildSettingItem(Icons.person, "Profile", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                }),
                _buildSettingItem(Icons.notifications, "Notifications", () {}),
                _buildSettingItem(Icons.language, "Language", () {}),
                _buildSettingItem(Icons.help, "Help & Support", () {}),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Nút đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                _showConfirmDialog(context);
              },
              child: const Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          // Phiên bản ứng dụng
          Center(
            child: Text(
              "App Version 1.0.0",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((255.0 * 0.1).round()),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

void _showConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => CustomDialog(
          message: 'Are you sure you want to sign out?',
          isError: false,
          onConfirm: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => StartScreen()),
            );
          },
        ),
  );
}
