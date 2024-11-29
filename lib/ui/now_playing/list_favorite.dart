import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/song.dart';

class ListFavorite {
  final String userId;

  ListFavorite(this.userId);

  // Lấy danh sách yêu thích từ SharedPreferences
  Future<List<Song>> getFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(userId);
    if (favoritesJson != null) {
      final savedSongs = jsonDecode(favoritesJson) as List;
      return savedSongs.map((song) => Song.fromJson(song)).toList();
    }
    return [];
  }

  // Lưu danh sách yêu thích vào SharedPreferences
  Future<void> saveFavoriteSongs(List<Song> favoriteSongs) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson =
    favoriteSongs.map((song) => song.toJson()).toList();
    await prefs.setString(userId, jsonEncode(favoritesJson));
  }

  // Kiểm tra xem một bài hát có nằm trong danh sách yêu thích không
  Future<bool> isSongFavorite(Song song) async {
    final favoriteSongs = await getFavoriteSongs();
    return favoriteSongs.any((s) => s.id == song.id);
  }

  // Thêm bài hát vào danh sách yêu thích
  Future<void> addFavorite(Song song) async {
    final favoriteSongs = await getFavoriteSongs();
    if (!favoriteSongs.any((s) => s.id == song.id)) {
      favoriteSongs.add(song);
      await saveFavoriteSongs(favoriteSongs);
    }
  }

  // Xóa bài hát khỏi danh sách yêu thích
  Future<void> removeFavorite(Song song) async {
    final favoriteSongs = await getFavoriteSongs();
    favoriteSongs.removeWhere((s) => s.id == song.id);
    await saveFavoriteSongs(favoriteSongs);
  }
}
