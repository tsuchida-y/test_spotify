import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpotifyService {
  final String _clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
  final String _clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
  String? _accessToken;

  Future<void> authenticate() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:$_clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate with Spotify');
    }
  }

  Future<Map<String, dynamic>> getNewReleases() async {
    if (_accessToken == null) {
      await authenticate();
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/browse/new-releases'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch new releases');
    }
  }
}