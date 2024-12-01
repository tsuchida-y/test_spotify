import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';//flutter_dotenv パッケージを使用して環境変数を読み込んでいます。

class SpotifyService {

  final String _clientId 
  = dotenv.env['SPOTIFY_CLIENT_ID']!;//envのSPOTIFY_CLIENT_IDを_clientId変数に代入。! は非nullアサーション。
  final String _clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!;//パッケージを使用して環境変数を読み込んでる。
  String? _accessToken;//_accessToken変数を宣言。?はnull許容型。

  Future<void> authenticate() async {//非同期処理のメソッド
    final response = await http.post(//リクエストが完了するまで待つ
      Uri.parse('https://accounts.spotify.com/api/token'),//リクエスト先のURL
      headers: {//リクエストヘッダー
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:$_clientSecret')),//クライアントIDとクライアントシークレットをBase64エンコードし、Basic認証の形式に変換
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},//リクエストボディ
    );


    //Spotify APIからの認証リクエストのレスポンスを処理する
    if (response.statusCode == 200) {//リクエストが成功すると200が返ってくる
      final data = jsonDecode(response.body);//レスポンスボディをJSON形式からDartのマップにデコード
      _accessToken = data['access_token'];//デコードされたJSONデータからアクセストークンを取得
    } else {
      throw Exception('Failed to authenticate with Spotify');//例外処理
    }
  }

  Future<Map<String, dynamic>> getNewReleases() async {
    if (_accessToken == null) {//アクセストークンがnullの場合
      await authenticate();//認証メソッドを呼び出す
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/browse/new-releases'),//リクエスト先のURL
      headers: {
        'Authorization': 'Bearer $_accessToken',//アクセストークンをリクエストヘッダーに追加
      },
    );

    if (response.statusCode == 200) { 
      return jsonDecode(response.body);//レスポンスボディをJSON形式からDartのマップにデコードを戻り値として返す
    } else {
      throw Exception('Failed to fetch new releases');//例外処理
    }
  }
}