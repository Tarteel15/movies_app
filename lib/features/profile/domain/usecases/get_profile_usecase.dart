import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  const GetProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.getProfile();
  }
}