import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:saucify/services/DatabaseService.dart';
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
  late String userId;
  DatabaseService dbService = DatabaseService();

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
    userId = "";
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

    final response1 = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response1.body.isNotEmpty){
      final body = json.decode(response1.body);
      userId = body['id'];
      Map<String, dynamic> topTracks = await getTopTracks();
      Map<String, dynamic> topArtists = await getTopArtists();

      Object obj = {
        'username': body['display_name'],
        'imageUrl': null,
        'followers': [],
        'topTracks': topTracks,
        'topArtist': topArtists,
      };
      dbService.login(body['id'], obj);
    }
  }

  getTopTracks() async {
    List topTracksShort = await getTopItems('tracks', 'short_term');
    List topTracksMedium = await getTopItems('tracks', 'medium_term');
    List topTracksLong = await getTopItems('tracks', 'long_term');
    List topTracksIds = [];

    Map<String, dynamic> topTracks = {
      'short': [],
      'medium': [],
      'long': []
    };

    topTracksShort.forEach((element) {
      topTracksIds.add(element['id']);
    });
    topTracks['short'] = topTracksIds;

    topTracksIds = [];
    topTracksMedium.forEach((element) {
      topTracksIds.add(element['id']);
    });
    topTracks['medium'] = topTracksIds;

    topTracksIds = [];
    topTracksLong.forEach((element) {
      topTracksIds.add(element['id']);
    });
    topTracks['long'] = topTracksIds;

    return topTracks;
  }

  getTopArtists() async {
    List topArtistsShort = await getTopItems('artists', 'short_term');
    List topArtistsMedium = await getTopItems('artists', 'medium_term');
    List topArtistsLong = await getTopItems('artists', 'long_term');
    List topArtistsIds = [];

    Map<String, dynamic> topArtists = {
      'short': [],
      'medium': [],
      'long': []
    };

    topArtistsShort.forEach((element) {
      topArtistsIds.add(element['id']);
    });
    topArtists['short'] = topArtistsIds;

    topArtistsIds = [];
    topArtistsMedium.forEach((element) {
      topArtistsIds.add(element['id']);
    });
    topArtists['medium'] = topArtistsIds;

    topArtistsIds = [];
    topArtistsLong.forEach((element) {
      topArtistsIds.add(element['id']);
    });
    topArtists['long'] = topArtistsIds;

    return topArtists;
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

  getTop3Items(String itemType) async {
    if (itemType != 'artists' && itemType != 'tracks') {
      return [];
    }

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/$itemType?time_range=long_term&limit=3'),
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

  Future<Tuple2<dynamic, List>> getTopItems1(String itemType, String timeRange, [String uri = '']) async {
    dynamic body;
    List items = [];
    if (itemType != 'artists' && itemType != 'tracks') {
      return Tuple2<dynamic, List>(null, items);
    }

    final response = await http.get(
      Uri.parse(uri != '' ? uri : 'https://api.spotify.com/v1/me/top/$itemType?time_range=$timeRange'),
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

  Future<List> searchItems(String searchString, String itemType) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$searchString&type=$itemType&limit=5'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      if (body[itemType+'s'] != null) {
        return body[itemType+'s']['items'];
      }
    }

    return [];
  }

  Future<void> createPlaylist1(List ids, String name) async {
    final response1 = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );
    
    if (response1.body.isNotEmpty){
      final body = json.decode(response1.body);
      final response2 = await http.post(
        Uri.parse('https://api.spotify.com/v1/users/${body['id']}/playlists'),
        body: jsonEncode({'name': name}),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json'
        }
      );

      final body1 = json.decode(response2.body);
      List items = await getTracks(ids);
      List uris = [];
      items.forEach((item) async {
        uris.add(item['uri']);
      });

      final response3 = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/${body1['uri'].split(':')[2]}/tracks'),
        body: jsonEncode({'uris': uris}),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json'
        }
      );
    }
  }

  Future<void> createPlaylist(String timeRange) async {
    final response1 = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    String name = '';
    if (timeRange == 'short_term'){
      name = 'Top Songs Last Month';
    } else if (timeRange == 'medium_term'){
      name = 'Top Songs Last 6 Months';
    } else if (timeRange == 'long_term'){
      name = 'Top Songs All Time';
    }

    if (response1.body.isNotEmpty){
      final body = json.decode(response1.body);
      final response2 = await http.post(
        Uri.parse('https://api.spotify.com/v1/users/${body['id']}/playlists'),
        body: jsonEncode({'name': name}),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json'
        }
      );

      final body1 = json.decode(response2.body);
      List items = await getTopItems('tracks', timeRange);
      List uris = [];
      items.forEach((item) async {
        uris.add(item['uri']);
      });

      final response3 = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/${body1['uri'].split(':')[2]}/tracks'),
        body: jsonEncode({'uris': uris}),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json'
        }
      );
    }
  }

  getTracks(List tracksIds) async {
    String ids = '';
    int index = 0;
    tracksIds.forEach((element) {
      if (index == tracksIds.length - 1) {
        ids += element;
      } else {
        ids += element + ',';
      }
      index++;
    });

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/tracks?ids=$ids'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      return body['tracks'];
    }

    return [];
  }

  getArtists(List artistsIds) async {
    String ids = '';
    artistsIds.forEach((element) {
      if (element == artistsIds[artistsIds.length - 1]) {
        ids += element;
      } else {
        ids += element + ',';
      }
    });

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists?ids=$ids'),
      headers: {
        'Authorization': 'Bearer $access_token',
        'Content-Type': 'application/json'
      }
    );

    if (response.body.isNotEmpty){
      final body = json.decode(response.body);
      return body['artists'];
    }

    return [];
  }
}

