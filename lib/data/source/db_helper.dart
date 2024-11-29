import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../model/model_favorite.dart';

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
    final path = join(dbPath, 'user_database.db');

    return openDatabase(
      path,
      version: 4, // Cập nhật phiên bản lên 4
      onCreate: (db, version) async {
        // Tạo bảng users
        await db.execute(''' 
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            user_name TEXT,
            city TEXT,
            phone_number TEXT,
            avatar TEXT
          )
        ''');

        // Tạo bảng favorites với trường 'favorite' kiểu INTEGER (0 hoặc 1)
        await db.execute(''' 
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            song_id TEXT NOT NULL,
            song_name TEXT NOT NULL,
            created_at TEXT NOT NULL,
            favorite INTEGER NOT NULL,  -- Sử dụng kiểu INTEGER cho trường 'favorite'
            FOREIGN KEY (user_id) REFERENCES users(id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Thêm trường 'favorite' vào bảng favorites với kiểu INTEGER
          await db.execute(''' 
            ALTER TABLE favorites
            ADD COLUMN favorite INTEGER NOT NULL DEFAULT 0;  -- Mặc định là 0 (false)
          ''');
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

  // Cập nhật thông tin người dùng (bao gồm email, tên người dùng, số điện thoại, thành phố và avatar)
  Future<int> updateUser(
      int userId,
      String? userName,
      String? email,
      String? phoneNumber,
      String? city,
      String? avatar,
      ) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'user_name': userName,
        'email': email,
        'phone_number': phoneNumber,
        'city': city,
        'avatar': avatar,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
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

  // Lấy danh sách bài hát yêu thích dưới dạng List<Favorite>
  Future<List<Favorite>> getFavorites(int userId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND favorite = ?',
      whereArgs: [userId, 1],  // Lọc các bài hát yêu thích (favorite = 1)
      orderBy: 'created_at DESC',
    );

    // Chuyển danh sách kết quả từ Map sang List<Favorite>
    return List.generate(result.length, (i) {
      return Favorite.fromMap(result[i]);
    });
  }

  // Thêm bài hát yêu thích
  Future<int> addFavorite(int userId, String songId, String songName) async {
    final db = await database;
    return await db.insert('favorites', {
      'user_id': userId,
      'song_id': songId,
      'song_name': songName,
      'created_at': DateTime.now().toIso8601String(),
      'favorite': 1,  // Gán giá trị 1 (true) cho trường favorite
    });
  }

  // Xóa bài hát yêu thích
  Future<int> removeFavorite(int userId, String songId) async {
    final db = await database;
    return await db.update(
      'favorites',
      {'favorite': 0},  // Đặt trường favorite thành 0 (false)
      where: 'user_id = ? AND song_id = ?',
      whereArgs: [userId, songId],
    );
  }

  // Kiểm tra xem bài hát đã yêu thích hay chưa
  Future<bool> isFavorite(int userId, String songId) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND song_id = ? AND favorite = ?',
      whereArgs: [userId, songId, 1],  // Kiểm tra trường favorite = 1 (true)
    );
    return result.isNotEmpty;
  }
}
