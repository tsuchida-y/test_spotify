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
      home: const MyHomePage(title: 'Spotify Playlists'),
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
  List<dynamic> _playlists = [];

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

   Future<void> _fetchPlaylists() async {
     final data = await _spotifyService.getUserPlaylists();
     setState(() {
       _playlists = data['items'];
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
        child: _playlists.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: _playlists.length,
                itemBuilder: (context, index) {
                  final playlist = _playlists[index];
                  return ListTile(
                    leading: playlist['images'].isNotEmpty
                        ? Image.network(playlist['images'][0]['url'])
                        : const Icon(Icons.music_note),
                    title: Text(playlist['name']),
                    subtitle: Text('Tracks: ${playlist['tracks']['total']}'),
                  );
                },
              ),
      ),
    );
  }
}