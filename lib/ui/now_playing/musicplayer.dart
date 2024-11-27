import 'package:audioplayers/audioplayers.dart';

class MusicPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Stream cho việc thay đổi vị trí và độ dài bài hát
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;

  // Sự kiện khi bài hát kết thúc
  Stream<void> get onPlayerComplete => _audioPlayer.onPlayerComplete;

  // Phương thức để phát nhạc từ một URL
  Future<void> playMusic(String url) async {
    try {
      await _audioPlayer.setSourceUrl(url); // Đặt nguồn phát từ URL
      await _audioPlayer.resume(); // Tiếp tục phát nhạc
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  // Phương thức tạm dừng nhạc
  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
  }

  // Phương thức tiếp tục phát nhạc
  Future<void> resumeMusic() async {
    await _audioPlayer.resume();
  }

  // Phương thức dừng nhạc
  Future<void> stopMusic() async {
    await _audioPlayer.stop();
  }

  // Phương thức chuyển đến một vị trí khác trong bài hát
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Phương thức hủy các tài nguyên khi không sử dụng
  void dispose() {
    _audioPlayer.dispose();
  }
}

