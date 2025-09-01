import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'interceptors.dart';

/// 请求操作封装
class ApiClient {
  late final Dio _dio;
  static ApiClient? _instance;
  static String baseUrl = '';

  // 私有命名构造函数
  ApiClient._internal(this._dio) {
    // 添加通用的默认拦截器
    _dio.interceptors.add(DefaultInterceptorsWrapper());
    if (kDebugMode) {
      // 添加请求日志拦截器，控制台可以看到请求日志
      _dio.interceptors
          .add(LogInterceptor(responseBody: true, requestBody: true));
      // 启用本地抓包代理，使用Charles等抓包工具可以抓包
      // _dio.httpClientAdapter =
      //     IOHttpClientAdapter(createHttpClient: localProxyHttpClient);
    }
  }

  /// ！！！单例初始化方法，需要在实例化前调用
  /// [baseUrl] 接口基地址
  /// [requestHeaders] 请求头
  static Future<void> init(String url) async {
    baseUrl = url;
    _instance ??= ApiClient._internal(
      Dio(
        BaseOptions(
          baseUrl: baseUrl,
          responseType: ResponseType.json,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: await _defaultRequestHeaders,
          // 请求是否成功的判断，返回false，会抛出DioError异常，类型为 DioErrorType.RESPONSE
          // 默认接收200-300间的状态码作为成功的请求，不想抛出异常，直接返回true
          validateStatus: (status) => true,
        ),
      ),
    );
  }

  // 暴露实例供外部访问
  static ApiClient get instance {
    if (_instance == null) {
      throw Exception('APIService is not initialized, call init() first');
    }
    return _instance!;
  }

  /// 构造默认请求头
  static Future<Map<String, dynamic>?> get _defaultRequestHeaders async {
    Map<String, dynamic> headers = {};
    return headers;
  }

  /// 更新请求头
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// 执行GET请求
  ///
  /// [endpoint] 接口地址 例如：/api/v1/user
  /// [queryParameters] 请求参数
  /// [options] 请求配置
  /// [cancelToken] 取消请求的token
  Future<Response<T>> get<T>(String endpoint,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) {
    return _dio.get(endpoint,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  /// 执行POST请求
  /// [endpoint] 接口地址
  /// [data] 请求数据
  /// [queryParameters] 请求参数
  /// [options] 请求配置
  Future<Response<T>> post<T>(String endpoint,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) {
    return _dio.post<T>(endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  /// 执行PUT请求
  /// [endpoint] 接口地址
  /// [data] 请求数据
  /// [queryParameters] 请求参数
  /// [options] 请求配置
  /// [cancelToken] 取消请求的token
  Future<Response<T>> put<T>(String endpoint,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken}) {
    return _dio.put<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
