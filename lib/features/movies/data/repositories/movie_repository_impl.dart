import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_datasource.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  const MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<MovieEntity>>> getHomeMovies() async {
    try {
      final remoteMovies = await remoteDataSource.getHomeMovies();
      await localDataSource.cacheHomeMovies(remoteMovies);
      return Right(remoteMovies);
    } on ServerException catch (e) {
      try {
        final cachedMovies = await localDataSource.getCachedHomeMovies();
        return Right(cachedMovies);
      } on CacheException catch (cacheError) {
        return Left(ServerFailure('${e.message} | ${cacheError.message}'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> searchMovies(String query) async {
    try {
      final movies = await remoteDataSource.searchMovies(query);
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MovieEntity>>> getMoviesByGenre(
    int genreId,
  ) async {
    try {
      final movies = await remoteDataSource.getMoviesByGenre(genreId);
      return Right(movies);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MovieEntity>> getMovieDetails(int movieId) async {
    try {
      final movie = await remoteDataSource.getMovieDetails(movieId);
      return Right(movie);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
