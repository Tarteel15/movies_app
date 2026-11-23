import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../repositories/profile_repository.dart';

class GetWatchlistUseCase {
  final ProfileRepository repository;

  const GetWatchlistUseCase(this.repository);

  Future<Either<Failure, List<MovieEntity>>> call() {
    return repository.getWatchlist();
  }
}