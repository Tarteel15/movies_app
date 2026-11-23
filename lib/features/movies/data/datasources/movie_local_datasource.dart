import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/hive_boxes.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<void> cacheHomeMovies(List<MovieModel> movies);
  Future<List<MovieModel>> getCachedHomeMovies();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  static const String _homeMoviesKey = 'cached_home_movies';

  Box get _box => Hive.box(HiveBoxes.moviesBox);

  @override
  Future<void> cacheHomeMovies(List<MovieModel> movies) async {
    try {
      final encoded = movies.map((movie) => movie.toJson()).toList();
      await _box.put(_homeMoviesKey, encoded);
    } catch (e) {
      throw CacheException('Failed to cache movies locally');
    }
  }

  @override
  Future<List<MovieModel>> getCachedHomeMovies() async {
    try {
      final rawList = _box.get(_homeMoviesKey) as List<dynamic>?;
      if (rawList == null) {
        throw CacheException('No cached movies found');
      }
      return rawList
          .map(
            (item) =>
                MovieModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException('Failed to read cached movies');
    }
  }
}
