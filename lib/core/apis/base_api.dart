import 'dart:io';
import 'dart:io' as io;

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class BaseAPI {
  late final String baseUrl;

  BaseAPI(String apiUrl, {bool isPodUrl = true}) {
    baseUrl = isPodUrl ? app.settings.defaultPodURL + apiUrl : apiUrl;
  }

  Dio get dio {
    Dio _dio = Dio();
    _dio.interceptors.clear();
    _dio.options = BaseOptions(
      baseUrl: app.settings.defaultPodURL,
      connectTimeout: app.settings.dioConnectTimeout,
      receiveTimeout: app.settings.dioReceiveTimeout,
    );
    _dio.interceptors.addAll([
      if (!app.settings.dioLoggerEnabled)
        LogInterceptor(
          logPrint: AppLogger.info,
          request: app.settings.dioLogInterceptorRequest,
          requestHeader: app.settings.dioLogInterceptorRequestHeader,
          requestBody: app.settings.dioLogInterceptorRequestBody,
          responseHeader: app.settings.dioLogInterceptorResponseHeader,
          responseBody: app.settings.dioLogInterceptorResponseBody,
        )
    ]);

    if (!kIsWeb) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (io.HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    return _dio;
  }

  void checkResponseError(Response response){
    if (response.statusCode != 200) {
      throw "ERROR: ${response.statusCode} ${response.statusMessage}";
    }
  }
}
