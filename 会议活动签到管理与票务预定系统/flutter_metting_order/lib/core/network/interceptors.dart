import 'dart:io';
import 'package:dio/dio.dart';

/// 默认拦截器
class DefaultInterceptorsWrapper extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 如果是POST请求且请求体为null，设置一个空的json字符串避免后端解析异常
    if (options.method.toUpperCase() == "POST" && options.data == null) {
      options.data = "{}";
      options.headers['content-type'] = "application/json";
    }
    handler.next(options);
  }
}

/// 本地代理抓包拦截器
HttpClient localProxyHttpClient() {
  return HttpClient()
    // 将请求代理到 本机IP:8888，是抓包电脑的IP！！！不要直接用localhost，会报错:
    // SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 47972
    ..findProxy = (uri) {
      return 'PROXY 192.168.102.117:8888';
    }
    // 抓包工具一般会提供一个自签名的证书，会通不过证书校验，这里需要禁用下，直接返回true
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
}
