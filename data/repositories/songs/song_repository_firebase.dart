import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  // final Uri songsUri = Uri.https(
  //   'test-a2a77-default-rtdb.asia-southeast1.firebasedatabase.app',
  //   '/songs.json',
  // );
  final Uri songsUri = Uri.https(
    'g4-food-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  List<Song>? _cachedSongs;

  @override
  Future<List<Song>> getSongs({bool forceFetch = false}) async {
    if (!forceFetch && _cachedSongs != null) {
      return _cachedSongs!;
    }

    final songs = await fetchSongs();

    _cachedSongs = songs;

    return songs;
  }

  @override
  Future<List<Song>> fetchSongs() async {
    final http.Response response = await http.get(songsUri);

    print(response.body);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song> likeSong(String id, int currentLike) async {
    final Uri songUri = songsUri.replace(path: '/songs/$id.json');
    //in the doc i said the HTTP verb would be PUT but now
    //i use PATCH instead because we don't need to replace the entire object,
    //we only need to update the like field
    final response = await http.patch(
      songUri,
      body: json.encode({SongDto.likeKey: currentLike + 1}),
    );

    if (response.statusCode == 200) {
      final Song? updatedSong = await fetchSongById(id);
      if (updatedSong != null) {
        return updatedSong;
      } else {
        throw Exception('Song not found after update');
      }
    } else {
      throw Exception('Failed to update likes for song $id');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    final Uri songUri = songsUri.replace(path: '/songs/$id.json');

    final http.Response response = await http.get(songUri);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? songJson = json.decode(response.body);
      if (songJson == null) return null;
      return SongDto.fromJson(id, songJson);
    } else {
      throw Exception('Failed to fetch song with id $id');
    }
  }
}
