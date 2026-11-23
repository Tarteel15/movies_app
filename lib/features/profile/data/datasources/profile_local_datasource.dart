import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/hive_boxes.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/domain/entities/movie_entity.dart';

abstract class ProfileLocalDataSource {
  Future<List<MovieEntity>> getWatchlist();
  Future<List<MovieEntity>> toggleWatchlist(MovieEntity movie);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(HiveBoxes.moviesBox)) {
      return Hive.box(HiveBoxes.moviesBox);
    }
    return Hive.openBox(HiveBoxes.moviesBox);
  }

  MovieEntity _fromMap(Map<dynamic, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    return MovieModel.fromJson(map);
  }

  Map<String, dynamic> _toMap(MovieEntity movie) {
    return {
      'id': movie.id,
      'title': movie.title,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'overview': movie.overview,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate,
    };
  }

  @override
  Future<List<MovieEntity>> getWatchlist() async {
    try {
      final box = await _openBox();
      final items = <MovieEntity>[];
      for (final value in box.values) {
        if (value is Map) {
          items.add(_fromMap(value));
        }
      }
      return items;
    } catch (e) {
      throw CacheException('Failed to load watchlist');
    }
  }

  @override
  Future<List<MovieEntity>> toggleWatchlist(MovieEntity movie) async {
    try {
      final box = await _openBox();
      final key = movie.id.toString();
      if (box.containsKey(key)) {
        await box.delete(key);
      } else {
        await box.put(key, _toMap(movie));
      }
      return getWatchlist();
    } catch (e) {
      throw CacheException('Failed to update watchlist');
    }
  }
}