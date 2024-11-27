import 'package:flutter/material.dart';
import '../../data/repository/user_manager.dart';
import '../data/model/user.dart';

class EditProfileScreen extends StatefulWidget {
  final User user; // Nhận thông tin người dùng để chỉnh sửa

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController avatarController =
      TextEditingController(); // URL ảnh đại diện

  @override
  void initState() {
    super.initState();
    // Khởi tạo các trường với thông tin người dùng hiện tại
    usernameController.text = widget.user.userName ?? '';
    emailController.text = widget.user.email ?? '';
    phoneController.text = widget.user.phoneNumber ?? '';
    cityController.text = widget.user.city ?? '';
    avatarController.text = widget.user.avatar ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh Sửa Thông Tin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trường nhập tên người dùng
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người dùng',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên người dùng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Trường nhập email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Trường nhập số điện thoại
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Trường nhập thành phố
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Thành phố',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Trường nhập URL avatar
                TextFormField(
                  controller: avatarController,
                  decoration: const InputDecoration(
                    labelText: 'Avatar (URL hoặc file ảnh)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                // Nút lưu thay đổi
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Tạo đối tượng User với dữ liệu cập nhật
                      User updatedUser = User(
                        id: widget.user.id,
                        // Lấy ID từ người dùng hiện tại
                        userName: usernameController.text,
                        email: emailController.text,
                        phoneNumber: phoneController.text.isEmpty
                            ? null
                            : phoneController.text,
                        city: cityController.text.isEmpty
                            ? null
                            : cityController.text,
                        avatar: avatarController.text.isEmpty
                            ? null
                            : avatarController.text,
                        password: widget.user.password, // Giữ nguyên mật khẩu
                      );

                      // Gọi UserManager để cập nhật thông tin
                      bool success =
                          await UserManager().updateUser(updatedUser);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cập nhật thông tin thành công!')),
                        );

                        // Quay lại màn hình tài khoản sau khi chỉnh sửa
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Cập nhật thông tin thất bại!')),
                        );
                      }
                    }
                  },
                  child: const Text('Lưu Thay Đổi'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
