import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class SearchMoviesUseCase {
  final MovieRepository repository;

  const SearchMoviesUseCase(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call(String query) {
    return repository.searchMovies(query);
  }
}
