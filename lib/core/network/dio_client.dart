import 'package:dio/dio.dart';

/// Dio HTTP client configuration
class DioClient {
  static const int _connectTimeout = 30000;
  static const int _receiveTimeout = 30000;

  late Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.mayegue.com', // TODO: Move to constants
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      // Auth interceptor
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TODO: Add auth token if available
          // final token = await _getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // TODO: Handle token refresh or logout
          }
          return handler.next(error);
        },
      ),

      // Logging interceptor
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  // TODO: Implement token management
  // Future<String?> _getAuthToken() async {
  //   // Get token from secure storage
  //   return null;
  // }
}
