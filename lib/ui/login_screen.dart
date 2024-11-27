import 'package:flutter/material.dart';
import 'package:app_music/ui/home/home.dart'; // Import màn hình chính sau đăng nhập
import 'package:app_music/ui/signup.dart'; // Import màn hình đăng ký
import '../data/model/user.dart';
import '../data/repository/user_manager.dart';
import '../data/source/db_helper.dart'; // Đảm bảo import đúng đường dẫn DatabaseHelper

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final dbHelper = DatabaseHelper(); // Khởi tạo đối tượng DatabaseHelper

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đăng Nhập'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Trường nhập email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Trường nhập mật khẩu
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Nút đăng nhập
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Kiểm tra thông tin đăng nhập từ cơ sở dữ liệu
                      final userMap = await dbHelper.getUser(
                        emailController.text,
                        passwordController.text,
                      );

                      if (userMap != null) {
                        // Chuyển Map thành đối tượng User
                        User user = User.fromMap(userMap);

                        // Đăng nhập thành công -> lưu thông tin vào UserManager
                        await UserManager().setCurrentUser(user);

                        // Chuyển sang MusicApp
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MusicApp()),
                        );
                      } else {
                        // Nếu thông tin không chính xác, hiển thị thông báo lỗi
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thông tin đăng nhập không chính xác')),
                        );
                      }
                    }
                  },
                  child: const Text('Đăng Nhập'),
                ),
                const SizedBox(height: 16),
                // Liên kết chuyển đến màn hình đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Chưa có tài khoản?'),
                    TextButton(
                      onPressed: () {
                        // Chuyển sang màn hình đăng ký
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: const Text('Đăng ký ngay'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
