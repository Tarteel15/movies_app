import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    String? avatarPath,
  }) {
    return repository.updateProfile(name: name, avatarPath: avatarPath);
  }
}