import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'spotify_service.dart';

void main() async {
  await dotenv.load(fileName: '.env');
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
      home: const MyHomePage(title: 'Spotify New Releases'),
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
  List<dynamic> _newReleases = [];

  @override
  void initState() {
    super.initState();
    _fetchNewReleases();
  }

  Future<void> _fetchNewReleases() async {
    final data = await _spotifyService.getNewReleases();
    setState(() {
      _newReleases = data['albums']['items'];
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
        child: _newReleases.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: _newReleases.length,
                itemBuilder: (context, index) {
                  final album = _newReleases[index];
                  return ListTile(
                    leading: Image.network(album['images'][0]['url']),
                    title: Text(album['name']),
                    subtitle: Text(album['artists'][0]['name']),
                  );
                },
              ),
      ),
    );
  }
}