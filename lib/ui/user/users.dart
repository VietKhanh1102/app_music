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
        title: const Text('Thông Tin Tài Khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kiểm tra xem người dùng đã đăng nhập chưa
            if (userManager.isLoggedIn && user != null) ...[
              // Hiển thị tên người dùng
              Text('Tên người dùng: ${user.userName}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              // Hiển thị email người dùng
              Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              // Hiển thị số điện thoại người dùng (nếu có)
              if (user.phoneNumber != null)
                Text('Số điện thoại: ${user.phoneNumber}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              // Hiển thị thành phố của người dùng (nếu có)
              if (user.city != null)
                Text('Thành phố: ${user.city}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              // Hiển thị ảnh đại diện (nếu có)
              if (user.avatar != null)
                Text('Ảnh đại diện: ${user.avatar}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),

              // Nút chỉnh sửa thông tin người dùng
              ElevatedButton(
                onPressed: () {
                  // Chuyển đến màn hình chỉnh sửa thông tin người dùng
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen(user: user)),
                  );
                },
                child: const Text('Chỉnh Sửa Thông Tin'),
              ),
              const SizedBox(height: 16),

              // Nút đăng xuất
              ElevatedButton(
                onPressed: () async {
                  await userManager.logout(); // Đăng xuất người dùng
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  ); // Điều hướng về màn hình đăng nhập
                },
                child: const Text('Đăng Xuất'),
              ),
            ] else
            // Nếu người dùng chưa đăng nhập
              const Center(
                child: Text('Chưa có thông tin tài khoản', style: TextStyle(fontSize: 18)),
              ),
          ],
        ),
      ),
    );
  }
}
