import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getHomeMovies();
  Future<List<MovieModel>> searchMovies(String query);
  Future<List<MovieModel>> getMoviesByGenre(int genreId);
  Future<MovieModel> getMovieDetails(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  const MovieRemoteDataSourceImpl(this.dioClient);

  Future<List<MovieModel>> _fetchMovieList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dioClient.dio.get(
        path,
        queryParameters: queryParameters,
      );
      final results = response.data['results'] as List<dynamic>? ?? [];
      return results
          .map((item) => MovieModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error while fetching movies');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MovieModel>> getHomeMovies() {
    return _fetchMovieList('/movie/popular');
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) {
    return _fetchMovieList('/search/movie', queryParameters: {'query': query});
  }

  @override
  Future<List<MovieModel>> getMoviesByGenre(int genreId) {
    return _fetchMovieList(
      '/discover/movie',
      queryParameters: {'with_genres': genreId},
    );
  }

  @override
  Future<MovieModel> getMovieDetails(int movieId) async {
    try {
      final response = await dioClient.dio.get('/movie/$movieId');
      return MovieModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error while fetching movie details',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
