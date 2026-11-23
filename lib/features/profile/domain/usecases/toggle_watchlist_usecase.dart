import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../repositories/profile_repository.dart';

class ToggleWatchlistUseCase {
  final ProfileRepository repository;

  const ToggleWatchlistUseCase(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call(MovieEntity movie) {
    return repository.toggleWatchlist(movie);
  }
}