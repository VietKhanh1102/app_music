import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  // Getter để lấy cơ sở dữ liệu
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Khởi tạo cơ sở dữ liệu và tạo bảng nếu cần
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_database.db'); // Tạo file database

    return openDatabase(
      path,
      version: 2, // Cập nhật phiên bản lên 2
      onCreate: (db, version) {
        // Tạo bảng khi cơ sở dữ liệu mới
        db.execute(''' 
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL,
          password TEXT NOT NULL,
          user_name TEXT,
          city TEXT,
          phone_number TEXT,
          avatar TEXT  // Thêm cột avatar
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          // Thêm cột avatar vào bảng nếu không có
          db.execute('ALTER TABLE users ADD COLUMN avatar TEXT');
        }
      },
    );
  }


  // Thêm người dùng vào cơ sở dữ liệu
  Future<int> insertUser(
      String email,
      String password,
      String? userName,
      String? city,
      String? phoneNumber,
      String? avatar,
      ) async {
    final db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'user_name': userName,
      'city': city,
      'phone_number': phoneNumber,
      'avatar': avatar, // Avatar có thể là null
    });
  }

  // Lấy thông tin người dùng bằng email và mật khẩu
  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Cập nhật avatar cho người dùng
  Future<int> updateAvatar(int userId, String avatar) async {
    final db = await database;
    return await db.update(
      'users',
      {'avatar': avatar},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Lấy thông tin người dùng bằng ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
