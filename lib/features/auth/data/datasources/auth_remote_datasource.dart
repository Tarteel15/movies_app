import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login({required String email, required String password});

  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? avatarPath,
  });

  Future<void> forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  Future<UserEntity> _mapFirebaseUser(
    User user, {
    String? fallbackName,
    String? fallbackAvatar,
  }) async {
    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      return UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        name:
            (data?['name'] as String?) ??
            user.displayName ??
            fallbackName ??
            'User',
        avatarPath: (data?['avatarPath'] as String?) ?? fallbackAvatar,
      );
    } catch (_) {
      return UserEntity(
        uid: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? fallbackName ?? 'User',
        avatarPath: fallbackAvatar,
      );
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw ServerException('User account was not found');
      }
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
    String? avatarPath,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw ServerException('Failed to create user account');
      }

      final trimmedName = name.trim();
      await user.updateDisplayName(trimmedName);

      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': trimmedName,
        'email': email.trim(),
        'avatarPath': avatarPath,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return UserEntity(
        uid: user.uid,
        email: user.email ?? email.trim(),
        name: trimmedName,
        avatarPath: avatarPath,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Registration failed');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
