import 'package:flutter/material.dart';
import '../../data/repository/user_manager.dart';
import '../edit_profile_screen.dart';
import '../login_screen.dart';

class AccountTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userManager = UserManager();
    final user = userManager.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thông Tin Tài Khoản',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(
          child: Text(
            'Chưa đăng nhập',
            style: TextStyle(fontSize: 18),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị tên người dùng
            Text(
              'Tên người dùng: ${user.userName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Hiển thị email người dùng
            Text(
              'Email: ${user.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Hiển thị số điện thoại (nếu có)
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              Text(
                'Số điện thoại: ${user.phoneNumber}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 8),

            // Hiển thị thành phố (nếu có)
            if (user.city != null && user.city!.isNotEmpty)
              Text(
                'Thành phố: ${user.city}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 8),

            // Hiển thị ảnh đại diện
            if (user.avatar != null && user.avatar!.isNotEmpty)
              Column(
                children: [
                  const Text('Ảnh đại diện:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(user.avatar!),
                      onBackgroundImageError: (_, __) {
                        debugPrint("Không tải được ảnh đại diện.");
                      },
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Nút chỉnh sửa thông tin
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: user),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Chỉnh Sửa Thông Tin'),
            ),
            const SizedBox(height: 16),

            // Nút đăng xuất
            ElevatedButton.icon(
              onPressed: () async {
                await userManager.logout(); // Đăng xuất người dùng
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Đăng Xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
