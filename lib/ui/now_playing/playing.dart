import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/song.dart';
import 'musicplayer.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({super.key, required this.playingSong, required this.songs});

  final Song playingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(
      {super.key, required this.songs, required this.playingSong});

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  late int currentSongIndex;
  bool isFavorite = false;
  bool isShuffle = false;
  bool isRepeat = false;
  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  late MusicPlayer _musicPlayer;
  List<Song> favoriteSongs = [];

  @override
  void initState() {
    super.initState();
    _musicPlayer = MusicPlayer();
    currentSongIndex =
        widget.songs.indexWhere((song) => song.id == widget.playingSong.id);

    _loadFavoriteSongs();

    // Lắng nghe sự thay đổi của vị trí bài hát
    _musicPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentPosition = position;
      });
    });

    // Lắng nghe sự thay đổi của tổng thời gian bài hát
    _musicPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
      });
    });

    // Lắng nghe sự kiện kết thúc bài hát
    _musicPlayer.onPlayerComplete.listen((event) {
      playNextSong();
    });
  }

  Future<void> _loadFavoriteSongs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSongs = prefs.getStringList('favorite_songs') ?? [];

    setState(() {
      favoriteSongs = savedSongs
          .map((songString) => Song.fromJson(jsonDecode(songString)))
          .toList();
      isFavorite = favoriteSongs.any((song) => song.id == widget.playingSong.id);
    });
  }

  void toggleFavorite() async {
    final currentSong = widget.songs[currentSongIndex];
    setState(() {
      if (isFavorite) {
        favoriteSongs.removeWhere((song) => song.id == currentSong.id);
      } else {
        favoriteSongs.add(currentSong);
      }
      isFavorite = !isFavorite;
    });

    final prefs = await SharedPreferences.getInstance();
    final songStrings =
    favoriteSongs.map((song) => jsonEncode(song.toJson())).toList();
    await prefs.setStringList('favorite_songs', songStrings);
  }

  void toggleShuffle() {
    setState(() {
      isShuffle = !isShuffle;
    });
  }

  void toggleRepeat() {
    setState(() {
      isRepeat = !isRepeat;
    });
  }

  void playNextSong() {
    setState(() {
      if (isShuffle) {
        currentSongIndex = (currentSongIndex + (widget.songs.length - 1)) %
            widget.songs.length;
      } else {
        currentSongIndex = (currentSongIndex + 1) % widget.songs.length;
      }

      if (isPlaying) {
        _musicPlayer.playMusic(widget.songs[currentSongIndex].source);
      } else {
        _musicPlayer.playMusic(widget.songs[currentSongIndex].source);
        isPlaying = true;
      }
    });
  }

  void playPreviousSong() {
    setState(() {
      if (isShuffle) {
        currentSongIndex =
            (currentSongIndex - 1 + widget.songs.length) % widget.songs.length;
      } else {
        currentSongIndex =
            (currentSongIndex - 1 + widget.songs.length) % widget.songs.length;
      }

      if (isPlaying) {
        _musicPlayer.playMusic(widget.songs[currentSongIndex].source);
      } else {
        _musicPlayer.playMusic(widget.songs[currentSongIndex].source);
        isPlaying = true;
      }
    });
  }

  void togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _musicPlayer.pauseMusic();
      } else {
        _musicPlayer.playMusic(widget.songs[currentSongIndex].source);
      }
      isPlaying = !isPlaying;
    });
  }

  void onSliderChanged(double value) {
    setState(() {
      currentPosition =
          Duration(seconds: value.toInt().clamp(0, totalDuration.inSeconds));
    });
    _musicPlayer.seekTo(currentPosition);
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.songs[currentSongIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.lightGreenAccent,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                currentSong.image,
                height: 250,
                width: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/hinhnen.jpg',
                    height: 250,
                    width: 250,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Column(
              children: [
                Text(
                  currentSong.title,
                  style: Theme.of(context).textTheme.headline6,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  currentSong.artist,
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
              children: [
                Slider(
                  value: currentPosition.inSeconds.toDouble(),
                  min: 0.0,
                  max: totalDuration.inSeconds.toDouble(),
                  onChanged: onSliderChanged,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(currentPosition),
                      style: Theme.of(context).textTheme.caption,
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: isShuffle ? Colors.green : null,
                  ),
                  onPressed: toggleShuffle,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 40),
                  onPressed: playPreviousSong,
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 60,
                  ),
                  onPressed: togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 40),
                  onPressed: playNextSong,
                ),
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: isRepeat ? Colors.green : null,
                  ),
                  onPressed: toggleRepeat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
