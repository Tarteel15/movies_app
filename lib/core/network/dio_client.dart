import 'package:dio/dio.dart';
import 'api_constants.dart';

class DioClient {
  final Dio dio;

  DioClient()
      : dio = Dio(_buildBaseOptions());

  static BaseOptions _buildBaseOptions() {
    final hasBearer = ApiConstants.apiReadAccessToken.trim().isNotEmpty;
    final hasApiKey = ApiConstants.apiKey.trim().isNotEmpty &&
        ApiConstants.apiKey.trim() != 'PUT_YOUR_TMDB_API_KEY_HERE' &&
        ApiConstants.apiKey.trim() != 'TMDB_API_KEY';

    final headers = <String, dynamic>{
      'Accept': 'application/json',
    };
    if (hasBearer) {
      headers['Authorization'] = 'Bearer ${ApiConstants.apiReadAccessToken.trim()}';
    }

    final queryParams = <String, dynamic>{};
    if (!hasBearer && hasApiKey) {
      queryParams['api_key'] = ApiConstants.apiKey.trim();
    }

    return BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: headers,
      queryParameters: queryParams,
    );
  }
}