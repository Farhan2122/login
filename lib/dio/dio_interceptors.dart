import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  Future<String?>? _refreshFuture;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get valid token (will refresh if needed)

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    print('[AUTH_INTERCEPTOR] Response received: ${response.data}');

    // Check if the response contains an error even though HTTP status is 200
    if (response.data is Map) {
      final data = response.data as Map;
      if (data['status'] == 'error' &&
          (data['message'] == 'INVALID' ||
              data['message']?.toString().contains('Invalid JWT') == true ||
              data['message']?.toString().contains('expired') == true ||
              data['message']?.toString().contains('Token') == true)) {
        print('[AUTH_INTERCEPTOR] Detected token error in response body');

        // Convert this to a DioException so it gets handled by onError
        final error = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Token authentication failed',
        );

        return handler.reject(error);
      }
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final response = error.response;

    print('[AUTH_INTERCEPTOR] Error occurred: ${error.message}');
    print('[AUTH_INTERCEPTOR] Response status: ${response?.statusCode}');
    print('[AUTH_INTERCEPTOR] Response data: ${response?.data}');

    // Check for 401 or token expiration errors
    bool isAuthError = response?.statusCode == 401;
    bool isInvalidToken = false;

    if (response?.data is Map) {
      final data = response?.data as Map;
      isInvalidToken =
          data['message']?.toString().contains('Invalid JWT') == true ||
          data['message']?.toString().contains('INVALID') == true ||
          data['message']?.toString().contains('expired') == true ||
          data['message']?.toString().contains('Token') == true ||
          (data['status'] == 'error' && data['message'] == 'INVALID');
    }

    print(
      '[AUTH_INTERCEPTOR] Is auth error: $isAuthError, Is invalid token: $isInvalidToken',
    );

    if (isAuthError || isInvalidToken) {
      try {
        final newToken = await _refreshFuture;
        _refreshFuture = null;

        if (newToken != null) {
          // Retry the original request with new token
          final opts = error.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';

          try {
            final dio = Dio();
            dio.interceptors.add(
              AuthInterceptor(),
            ); // Add interceptor to new instance
            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          } catch (retryError) {
            return handler.next(retryError as DioException);
          }
        } else {
          // Refresh failed, clear tokens and redirect to login

          // You might want to trigger a logout event here
        }
      } catch (refreshError) {
        _refreshFuture = null;
        print('Token refresh failed: $refreshError');
      }
    }

    handler.next(error);
  }
}
