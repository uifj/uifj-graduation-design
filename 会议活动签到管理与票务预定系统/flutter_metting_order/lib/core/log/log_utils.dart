import 'package:logger/logger.dart';

class LogUtils {
  static final LogUtils _instance = LogUtils._internal();

  factory LogUtils() {
    return _instance;
  }

  LogUtils._internal();

  final Logger _logger = Logger();

  void d(dynamic message) {
    _logger.d(message);
  }

  void i(dynamic message) {
    _logger.i(message);
  }

  void w(dynamic message) {
    _logger.w(message);
  }

  void e(dynamic message) {
    _logger.e(message);
  }
}