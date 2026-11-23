import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetMoviesByGenreUseCase {
  final MovieRepository repository;

  const GetMoviesByGenreUseCase(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call(int genreId) {
    return repository.getMoviesByGenre(genreId);
  }
}
