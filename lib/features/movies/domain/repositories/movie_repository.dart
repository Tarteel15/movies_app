import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<MovieEntity>>> getHomeMovies();
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query);
  Future<Either<Failure, List<MovieEntity>>> getMoviesByGenre(int genreId);
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId);
}
