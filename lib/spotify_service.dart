import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class SpotifyService {
  final String _clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;
  final String _clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
  final String _redirectUri = dotenv.env['SPOTIFY_REDIRECT_URI']!;
  String? _accessToken;

//デバッグプリントを追加
  SpotifyService() {
    print('Client ID: $_clientId');
    print('Client Secret: $_clientSecret');
    print('Redirect URI: $_redirectUri');
  }

  Future<void> authenticate() async {
    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': 'playlist-read-private',
    });

    print('Auth URL: $authUrl');

    final result = await FlutterWebAuth.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'Hackathonteam21://callback',
    );

    print('Authentication result: $result');

    final code = Uri.parse(result).queryParameters['code'];

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:$_clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code!,
        'redirect_uri': _redirectUri,
      },
    );
  print('Token response: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate with Spotify');
    }
  }

  Future<Map<String, dynamic>> getUserPlaylists() async {
    if (_accessToken == null) {
      await authenticate();
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch playlists');
    }
  }
}