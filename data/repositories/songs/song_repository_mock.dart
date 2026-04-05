// song_repository_mock.dart

import '../../../model/songs/song.dart';
import 'song_repository.dart';

class SongRepositoryMock implements SongRepository {
  final List<Song> _songs = [  ];

  @override
  Future<List<Song>> fetchSongs() async {
    return Future.delayed(Duration(seconds: 4), () {
      throw _songs;
    });
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _songs.firstWhere(
        (song) => song.id == id,
        orElse: () => throw Exception("No song with id $id in the database"),
      );
    });
  }
  
  @override
  Future<Song> likeSong(String id, int currentLike) {
    // TODO: implement likeSong
    throw UnimplementedError();
  }
  
  @override
  Future<List<Song>> getSongs({bool forceFetch = false}) {
    // TODO: implement getSongs
    throw UnimplementedError();
  }
}
