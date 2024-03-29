import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'dart:math';

import 'package:tuple/tuple.dart';

class spotifyService {
  late String client_id; // Your client id
  late String client_secret; // Your secret
  late String redirect_uri; // Your redirect uri
  late String scope;
  late String stateKey;
  late String access_token;
  late bool isPlaying;
  late String deviceId;

  spotifyService(){
    client_id = 'ab34da279af84ac5a6573a70f14a1b0a'; // Your client id
    client_secret = '553e351479bf467ca2fdb0efd92c1cd6'; // Your secret
    redirect_uri = 'saucify:/'; // Your redirect uri
    scope = 'user-library-read ' 'user-modify-playback-state ' 'user-read-playback-state '
             'user-read-currently-playing ' 'user-follow-modify ' 'user-follow-read '
             'user-read-recently-played ' 'user-read-playback-position ' 'user-top-read '
             'playlist-read-collaborative ' 'playlist-modify-public ' 'playlist-read-private '
             'playlist-modify-private ' 'app-remote-control ' 'streaming ' 'user-read-email '
             'user-read-private ' 'user-library-modify ' 'user-library-read';
    stateKey = 'spotify_auth_state';
    access_token = '';
    isPlaying = false;
    deviceId = "";
  }
  
  Future<void> logIn() async {
    String state = generateRandomString(16);

    final url = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': client_id,
      'scope': scope,
      'redirect_uri': redirect_uri,
      'state': state
    });

    // Present the dialog to the user
    final result = await FlutterWebAuth.authenticate(url: url.toString(), callbackUrlScheme: "saucify");

    // Extract code from resulting url
    final code = Uri.parse(result).queryParameters['code'];
    // final state = Uri.parse(result).queryParameters['state'];
    // final storedState = Uri.parse(result).

    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      body: {
        'code': code,
        'redirect_uri': redirect_uri,
        'grant_type': 'authorization_code'
      },
      headers: {
        'Authorization': 'Basic ${base64.encode(utf8.encode('$client_id:$client_secret'))}'
      }
    );

    final body = json.decode(response.body);
    access_token = body['access_token'];
  }

  String generateRandomString(int length){
    String text = '';
    const String possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for (int i = 0; i < length; i++) {
      text += possible[Random().nextInt(possible.length-1)];
    }
    return text;
  }

  bool isLoggedIn(){
    return access_token != "";
  }

  Future<List> getTopItems(String itemType, String timeRange) async{
    if (itemType != 'artists' && itemType != 'tracks') {
      return [];
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/$itemType?time_range=$timeRange'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      return body['items'];
    }

    return [];
  }

  Future<Tuple2<dynamic, List>> getPlaylistTracks(String id, [String uri = '']) async {
    dynamic body;
    List items = [];
    final response = await http.get(
      Uri.parse(uri != '' ? uri : 'https://api.spotify.com/v1/playlists/$id/tracks?limit=50'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      body = json.decode(response.body);
      body['items'].forEach((item) => {
        items.add(item)
      });
    } else {
      return Tuple2<dynamic, List>(null, items);
    }

    return Tuple2<dynamic, List>(body['next'], items);
  }

  Future<List> getPlaylists() async{
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists?limit=50'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      return body['items'];
    }

    return [];
  }

  Future<List> getDevices() async{
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/player/devices'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );
    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      return body['devices'];
    }
    return [];
  }

  Future<void> playMusic(String musicUri) async {
    final response = await http.put(
      Uri.parse('https://api.spotify.com/v1/me/player/play?device_id=$deviceId'),
      body: jsonEncode({'uris': [musicUri]}),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    isPlaying = true;
  }

  Future<void> togglePlayer() async {
    String url;
    if (isPlaying) {
      url = 'https://api.spotify.com/v1/me/player/pause?device_id=$deviceId';
    } else {
      url = 'https://api.spotify.com/v1/me/player/play?device_id=$deviceId';
    }

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    isPlaying = !isPlaying;
  }

  Future<List> searchItems(String searchString) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$searchString&type=track'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      if (body['tracks'] != null) {
        return body['tracks']['items'];
      }
    }

    return [];
  }
}

