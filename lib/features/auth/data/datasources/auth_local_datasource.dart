import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/prefs_keys.dart';

abstract class AuthLocalDataSource {
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool value);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  const AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<bool> isOnboardingCompleted() async {
    try {
      return sharedPreferences.getBool(PrefsKeys.onboardingCompleted) ?? false;
    } catch (e) {
      throw CacheException('Failed to read onboarding status');
    }
  }

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    try {
      await sharedPreferences.setBool(PrefsKeys.onboardingCompleted, value);
    } catch (e) {
      throw CacheException('Failed to save onboarding status');
    }
  }
}
