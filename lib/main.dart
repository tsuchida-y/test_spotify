import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'spotify_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Top Tracks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SpotifyService _spotifyService = SpotifyService();
  List<dynamic> _topTracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTopTracks();
  }

  Future<void> _fetchTopTracks() async {
    final data = await _spotifyService.getTopTracks();
    setState(() {
      _topTracks = data['items'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: _topTracks.length,
                itemBuilder: (context, index) {
                  final track = _topTracks[index];
                  return ListTile(
                    leading: track['album']['images'].isNotEmpty
                        ? Image.network(track['album']['images'][0]['url'])
                        : const Icon(Icons.music_note),
                    title: Text(track['name']),
                    subtitle: Text('Artist: ${track['artists'][0]['name']}'),
                  );
                },
              ),
      ),
    );
  }
}