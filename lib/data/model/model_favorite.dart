class Favorite {
  final int id;
  final int userId;
  final String songId;
  final String songName;
  final String createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.songId,
    required this.songName,
    required this.createdAt,
  });

  // Hàm chuyển từ Map sang Favorite
  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      userId: map['user_id'],
      songId: map['song_id'],
      songName: map['song_name'],
      createdAt: map['created_at'],
    );
  }

  // Hàm chuyển từ Favorite sang Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'song_id': songId,
      'song_name': songName,
      'created_at': createdAt,
    };
  }

  // Thuộc tính getter để kiểm tra bài hát có phải là yêu thích không
  bool get isFavorite => true; // Ví dụ trả về true, có thể thay đổi logic tùy vào cách kiểm tra
}
