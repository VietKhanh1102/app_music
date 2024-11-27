class User {
  final int? id;
  final String email;
  final String password;
  final String? userName;  // Thêm userName
  final String? city;  // Thêm city
  final String? phoneNumber;  // Thêm phoneNumber
  final String? avatar;  // Thêm avatar (để lưu URL hoặc đường dẫn hình ảnh)

  User({
    this.id,
    required this.email,
    required this.password,
    this.userName,
    this.city,
    this.phoneNumber,
    this.avatar,
  });

  // Chuyển từ Map sang đối tượng User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      userName: map['user_name'],  // Đọc từ Map
      city: map['city'],  // Đọc từ Map
      phoneNumber: map['phone_number'],  // Đọc từ Map
      avatar: map['avatar'],  // Đọc từ Map
    );
  }

  // Chuyển từ đối tượng User sang Map để lưu vào cơ sở dữ liệu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'user_name': userName,  // Lưu vào Map
      'city': city,  // Lưu vào Map
      'phone_number': phoneNumber,  // Lưu vào Map
      'avatar': avatar,  // Lưu vào Map
    };
  }


}
