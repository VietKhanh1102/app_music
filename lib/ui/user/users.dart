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
              buildUserInfoRow('Tên người dùng', user.userName),
              const SizedBox(height: 8),
              // Hiển thị email
              buildUserInfoRow('Email', user.email),
              const SizedBox(height: 8),
              // Hiển thị số điện thoại
              buildUserInfoRow('Số điện thoại', user.phoneNumber),
              const SizedBox(height: 8),
              // Hiển thị thành phố
              buildUserInfoRow('Thành phố', user.city),
              const SizedBox(height: 8),
              // Hiển thị avatar
              buildUserInfoRow('Avatar', user.avatar),
              const SizedBox(height: 24),

              // Nút chỉnh sửa thông tin người dùng
              ElevatedButton(
                onPressed: () {
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
                  await userManager.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text('Đăng Xuất'),
              ),
            ] else
            // Nếu người dùng chưa đăng nhập
              const Center(
                child: Text(
                  'Chưa có thông tin tài khoản',
                  style: TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Hàm tiện ích để xây dựng các hàng thông tin người dùng
  Widget buildUserInfoRow(String label, String? value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Text(
            value ?? 'Không có dữ liệu',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
