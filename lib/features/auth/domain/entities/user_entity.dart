import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? avatarPath;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [uid, email, name, avatarPath];
}
