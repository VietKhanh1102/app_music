import 'package:app_music/ui/discovery/discovery.dart';
import 'package:app_music/ui/favorite/favorite.dart';
import 'package:app_music/ui/home/viewmodel.dart';
import 'package:app_music/ui/settings/settings.dart';
import 'package:app_music/ui/signup.dart';
import 'package:app_music/ui/user/users.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../../data/repository/user_manager.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amberAccent),
      ),
      home: MusicHomePage(), // Chuyển sang MusicHomePage sau khi đăng nhập
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Hàm để lấy ID người dùng từ UserManager
  Future<void> _loadUserId() async {
    // Lấy thông tin người dùng từ UserManager
    await UserManager().init();  // Đảm bảo UserManager đã được khởi tạo
    int? userId = UserManager().currentUser?.id;

    // Kiểm tra xem userId có tồn tại không, rồi tạo các tab
    if (userId != null) {
      setState(() {
        _tabs.addAll([
          const HomeTab(),
          FavoriteTab(userId: userId),  // Truyền id vào FavoriteTab
          AccountTab(),
          const SettingTab(),
        ]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs.isEmpty ? const Center(child: CircularProgressIndicator()) : _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _viewModel.loadSong();
    observeData();
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  void observeData() {
    _viewModel.songStream.stream.listen((songList) {
      if (mounted) {
        setState(() {
          songs = songList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: songs.isEmpty ? _getProgressBar() : _getListView(),
    );
  }

  Widget _getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getListView() {
    return ListView.separated(
      itemCount: songs.length,
      shrinkWrap: true,
      separatorBuilder: (_, __) => const Divider(thickness: 1, height: 1),
      itemBuilder: (context, index) {
        return _SongItemSection(parent: this, song: songs[index]);
      },
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Xin chào!'),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  void navigate(Song song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NowPlayingPage(
          songs: songs,
          playingSong: song,
        ),
      ),
    );
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({
    required this.parent,
    required this.song,
  });

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/hinhnen.jpg',
          image: song.image,
          width: 50,
          height: 50,
          imageErrorBuilder: (_, __, ___) {
            return Image.asset(
              'assets/hinhnen.jpg',
              width: 50,
              height: 50,
            );
          },
        ),
      ),
      title: Text(song.title, style: const TextStyle(fontSize: 16)),
      subtitle: Text(song.artist, style: const TextStyle(fontSize: 14)),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () => parent.showBottomSheet(),
      ),
      onTap: () => parent.navigate(song),
    );
  }
}