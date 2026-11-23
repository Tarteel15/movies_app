import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/movie_entity.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetailsUseCase {
  final MovieRepository repository;

  const GetMovieDetailsUseCase(this.repository);

  Future<Either<Failure, MovieEntity>> call(int movieId) {
    return repository.getMovieDetails(movieId);
  }
}
