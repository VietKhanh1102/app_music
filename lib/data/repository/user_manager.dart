import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
import '../source/db_helper.dart';
class UserManager {
  static final UserManager _instance = UserManager._internal();
  SharedPreferences? _prefs;
  User? _currentUser;
  bool _isLoggedIn = false;

  UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  // Khởi tạo SharedPreferences và kiểm tra trạng thái đăng nhập
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    String? userJson = _prefs?.getString('user');
    _isLoggedIn = _prefs?.getBool('isLoggedIn') ?? false;

    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      _currentUser = User.fromMap(userMap);
    }
  }

  bool get isLoggedIn => _isLoggedIn;

  User? get currentUser => _currentUser;

  // Lưu trạng thái đăng nhập vào SharedPreferences
  Future<void> setLoggedIn(bool loggedIn) async {
    _isLoggedIn = loggedIn;
    await _prefs?.setBool('isLoggedIn', loggedIn);
  }

  // Lưu thông tin người dùng vào SharedPreferences và cập nhật _currentUser
  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    String userJson = jsonEncode(user.toMap());
    await _prefs?.setString('user', userJson);
    await setLoggedIn(true); // Đánh dấu người dùng đã đăng nhập
  }

  // Đăng xuất và xóa thông tin người dùng
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    await _prefs?.remove('user');
    await _prefs?.setBool('isLoggedIn', false); // Cập nhật trạng thái đăng xuất
  }

  // Cập nhật thông tin người dùng trong cơ sở dữ liệu
  Future<void> updateUserInDatabase(int userId, User updatedUser) async {
    await DatabaseHelper().updateUser(
      userId,
      updatedUser.userName,
      updatedUser.email,
      updatedUser.phoneNumber,
      updatedUser.city,
      updatedUser.avatar,
    );
  }
  Future<bool> updateUser(User updatedUser) async {
    if (updatedUser.id == null) {
      // Trường hợp không có ID, không thể cập nhật
      return false;
    }

    try {
      // Cập nhật trong cơ sở dữ liệu
      await updateUserInDatabase(
        updatedUser.id!,
        updatedUser,
      );

      // Lưu lại thông tin mới vào SharedPreferences
      await setCurrentUser(updatedUser);
      return true;
    } catch (e) {
      print('Lỗi khi cập nhật thông tin người dùng: $e');
      return false;
    }
  }
}
