import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Avatar và Tên
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    // backgroundImage: AssetImage('assets/avatar.png'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 20),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hoamuathu",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "hoamuathu@example.com",
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
                  _buildSettingItem(Icons.person, "Account", () {}),
                  _buildSettingItem(Icons.notifications, "Notifications", () {}),
                  _buildSettingItem(Icons.lock, "Privacy", () {}),
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
                  // Xử lý đăng xuất
                },
                child: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
            ),

            // Phiên bản ứng dụng
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  "App Version 1.0.0",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          ],
        ),
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
            color: Colors.grey.withOpacity(0.1),
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
