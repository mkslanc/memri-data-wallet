import 'package:dio/dio.dart';

class ErrorService {
  static isConnectionError(Exception e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return true;
      }
    }
    return false;
  }
}
