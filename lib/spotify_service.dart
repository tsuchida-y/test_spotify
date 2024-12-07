import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

class SpotifyService {
  final String _clientId = dotenv.env['SPOTIFY_CLIENT_ID']!;//.envファイルから取得
  final String _clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;
  final String _redirectUri = dotenv.env['SPOTIFY_REDIRECT_URI']!;
  String? _accessToken;

  SpotifyService() {
    print('Client ID: $_clientId');
    print('Client Secret: $_clientSecret');
    print('Redirect URI: $_redirectUri');
  }

  Future<void> authenticate() async {//認証
    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {//Spotifyの認証URL
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': 'user-top-read', // トップトラックの読み取り権限
    });

    print('Auth URL: $authUrl'); 

    try {
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'http', // 有効なスキームを指定
      );

      print('Authentication result: $result');

    final code = Uri.parse(result).queryParameters['code'];
      print('Authorization code: $code');

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
        } catch (e) {
      print('Error during authentication: $e');
      rethrow;
    }
  }

  //Future<Map<String, dynamic>> getUserPlaylists() async {
  Future<Map<String, dynamic>> getTopTracks() async {
    if (_accessToken == null) {
      await authenticate();
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/tracks'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );
    print('Top tracks response: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch playlists');
    }
  }
}