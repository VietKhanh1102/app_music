import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/song.dart';
import '../../data/repository/user_manager.dart';

class FavoriteTab extends StatefulWidget {
  const FavoriteTab({super.key});

  @override
  State<FavoriteTab> createState() => _FavoriteTabState();
}

class _FavoriteTabState extends State<FavoriteTab> {
  List<Song> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteSongs();
  }

  Future<void> _loadFavoriteSongs() async {
    final userManager = UserManager();

    // Gọi init() để khởi tạo UserManager
    await userManager.init();

    final currentUser = userManager.currentUser;

    if (currentUser == null) {
      print("No current user found.");
      return;
    }

    // Lấy danh sách bài hát yêu thích theo userId
    final prefs = await SharedPreferences.getInstance();
    final savedSongs = prefs.getStringList('favorite_songs_${currentUser.id}') ?? [];

    if (savedSongs.isEmpty) {
      print("No favorite songs found in SharedPreferences.");
    }

    // In ra dữ liệu để kiểm tra
    print("Saved songs: $savedSongs");

    setState(() {
      favoriteSongs = savedSongs
          .map((songJson) => Song.fromJson(jsonDecode(songJson)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
        backgroundColor: Colors.lightGreenAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: favoriteSongs.isEmpty
          ? const Center(
        child: Text(
          'No favorite songs yet.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.separated(
          itemCount: favoriteSongs.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final song = favoriteSongs[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/hinhnen.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    _removeFromFavorites(song);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _removeFromFavorites(Song song) async {
    setState(() {
      favoriteSongs.removeWhere((s) => s.id == song.id);
    });

    final userManager = UserManager();
    final currentUser = userManager.currentUser;

    if (currentUser == null) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final songStrings = favoriteSongs.map((s) => jsonEncode(s.toJson())).toList();

    // Lưu lại danh sách bài hát yêu thích của người dùng vào SharedPreferences
    await prefs.setStringList('favorite_songs_${currentUser.id}', songStrings);
  }
}

