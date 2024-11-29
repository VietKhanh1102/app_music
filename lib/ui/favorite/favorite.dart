import 'package:flutter/material.dart';
import '../../data/model/model_favorite.dart';
import '../../data/source/db_helper.dart';

class FavoriteTab extends StatefulWidget {
  final int userId; // Biến để lưu id người dùng

  const FavoriteTab({super.key, required this.userId}); // Constructor nhận id người dùng

  @override
  _FavoriteTabState createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  late List<Favorite> favoriteSongs = []; // Danh sách bài hát yêu thích
  late DatabaseHelper dbHelper; // Đối tượng DbHelper để truy vấn cơ sở dữ liệu

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper(); // Khởi tạo đối tượng DbHelper
    _loadFavoriteSongs(); // Tải danh sách bài hát yêu thích khi màn hình được tạo
  }

  // Hàm tải danh sách bài hát yêu thích từ cơ sở dữ liệu
  Future<void> _loadFavoriteSongs() async {
    List<Favorite> favorites = await dbHelper.getFavorites(widget.userId); // Lấy danh sách bài hát yêu thích từ DB
    setState(() {
      favoriteSongs = favorites; // Cập nhật danh sách yêu thích trong state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Yêu Thích'),
        backgroundColor: Colors.lightGreenAccent,
        centerTitle: true,
      ),
      body: favoriteSongs.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading nếu chưa có dữ liệu
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: favoriteSongs.length, // Số lượng bài hát yêu thích
          itemBuilder: (context, index) {
            final favorite = favoriteSongs[index]; // Lấy bài hát yêu thích tại index
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(

                title: Text(
                  favorite.songName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'ID: ${favorite.songId}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.play_circle_fill,
                    color: Colors.teal,
                    size: 30,
                  ),
                  onPressed: () {
                    // Thực hiện phát bài hát khi người dùng nhấn
                    print('Phát bài hát: ${favorite.songName}');
                  },
                ),
                onTap: () {
                  // Xử lý khi người dùng nhấn vào bài hát yêu thích
                  print('Xem chi tiết bài hát: ${favorite.songName}');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
