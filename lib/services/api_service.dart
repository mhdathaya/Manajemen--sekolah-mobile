import 'package:dio/dio.dart';
import '../core/app_constants.dart';
import 'storage_service.dart';

/// Service untuk HTTP request menggunakan Dio
class ApiService {
  late final Dio _dio;
  final StorageService _storageService;

  ApiService(this._storageService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Tambahkan Authorization token jika tersedia
          final token = _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );

    // Log interceptor untuk debugging (non-production)
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Parse error message dari DioException
  static String parseError(Object e) {
    if (e is DioException) {
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map) {
          // Laravel ValidationException (422): ambil pesan dari `errors` dulu
          if (e.response?.statusCode == 422) {
            final errors = data['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstField = errors.values.first;
              if (firstField is List && firstField.isNotEmpty) {
                return firstField.first.toString();
              }
            }
          }
          // Fallback ke field `message`
          if (data.containsKey('message') &&
              data['message'] != null &&
              data['message'].toString().isNotEmpty) {
            return data['message'].toString();
          }
        }
        switch (e.response?.statusCode) {
          case 400:
            return 'Permintaan tidak valid.';
          case 401:
            return 'Sesi telah berakhir. Silakan login kembali.';
          case 403:
            return 'Anda tidak memiliki akses.';
          case 404:
            return 'Data tidak ditemukan.';
          case 422:
            return 'Email/NIS atau password yang dimasukkan salah.';
          case 500:
            return 'Terjadi kesalahan pada server.';
          default:
            return 'Terjadi kesalahan. Coba lagi.';
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Koneksi timeout. Periksa jaringan Anda.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      }
    }
    return 'Terjadi kesalahan tidak terduga.';
  }
}
