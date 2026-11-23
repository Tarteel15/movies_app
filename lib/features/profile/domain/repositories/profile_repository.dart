import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../movies/domain/entities/movie_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> getProfile();

  Future<Either<Failure, UserEntity>> updateProfile({
    required String name,
    String? avatarPath,
  });

  Future<Either<Failure, List<MovieEntity>>> getWatchlist();

  Future<Either<Failure, List<MovieEntity>>> toggleWatchlist(MovieEntity movie);

  Future<Either<Failure, void>> logout();
}
