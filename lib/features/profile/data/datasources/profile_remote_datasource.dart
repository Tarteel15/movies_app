import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({
    required String name,
    String? avatarPath,
  });
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const ProfileRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserEntity> getProfile() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('No logged-in user found');
      }

      final doc = await firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      return UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        name: (data?['name'] as String?) ?? user.displayName ?? 'User',
        avatarPath: data?['avatarPath'] as String?,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    String? avatarPath,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException('No logged-in user found');
      }

      final trimmedName = name.trim();
      await user.updateDisplayName(trimmedName);

      final updates = <String, dynamic>{
        'name': trimmedName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (avatarPath != null) {
        updates['avatarPath'] = avatarPath;
      }

      await firestore
          .collection('users')
          .doc(user.uid)
          .set(updates, SetOptions(merge: true));

      final doc = await firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      return UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        name: (data?['name'] as String?) ?? trimmedName,
        avatarPath: (data?['avatarPath'] as String?) ?? avatarPath,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}