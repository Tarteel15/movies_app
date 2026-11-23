import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/hive_boxes.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/domain/entities/movie_entity.dart';

abstract class ProfileLocalDataSource {
  Future<List<MovieEntity>> getWatchlist();
  Future<List<MovieEntity>> toggleWatchlist(MovieEntity movie);
  Future<void> clearCurrentUserWatchlist();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  static const String _lastScopeKey = '_last_watchlist_scope_';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(HiveBoxes.moviesBox)) {
      return Hive.box(HiveBoxes.moviesBox);
    }
    return Hive.openBox(HiveBoxes.moviesBox);
  }

  String _currentUserScope() {
    String? rawId;
    try {
      rawId = FirebaseAuth.instance.currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.email;
    } catch (_) {}
    final cleaned = (rawId == null || rawId.trim().isEmpty)
        ? 'guest'
        : rawId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return cleaned;
  }

  String _scopedKey(String scope, int movieId) => 'watchlist_${scope}_$movieId';

  Future<void> _migrateLegacyKeysIfNeeded(Box<dynamic> box, String scope) async {
    final lastScope = box.get(_lastScopeKey)?.toString();
    if (lastScope == null) {
      // أول مرة بعد التعديل: انقل المفاتيح القديمة غير المربوطة (اللي اسمها أرقام بس) للحساب الحالي
      final legacyEntries = <int, dynamic>{};
      for (final entry in box.toMap().entries) {
        final keyStr = entry.key.toString();
        if (RegExp(r'^\d+$').hasMatch(keyStr) && entry.value is Map) {
          legacyEntries[int.parse(keyStr)] = entry.value;
        }
      }
      for (final item in legacyEntries.entries) {
        await box.put(_scopedKey(scope, item.key), item.value);
        await box.delete(item.key.toString());
      }
    }
    await box.put(_lastScopeKey, scope);
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
      final scope = _currentUserScope();
      await _migrateLegacyKeysIfNeeded(box, scope);

      final prefix = 'watchlist_${scope}_';
      final items = <MovieEntity>[];

      for (final entry in box.toMap().entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (key.startsWith(prefix) && value is Map) {
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
      final scope = _currentUserScope();
      await _migrateLegacyKeysIfNeeded(box, scope);

      final key = _scopedKey(scope, movie.id);
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

  @override
  Future<void> clearCurrentUserWatchlist() async {
    try {
      final box = await _openBox();
      final scope = _currentUserScope();
      final prefix = 'watchlist_${scope}_';
      final keysToDelete = box.keys
          .where((k) => k.toString().startsWith(prefix))
          .toList();
      await box.deleteAll(keysToDelete);
    } catch (_) {}
  }
}