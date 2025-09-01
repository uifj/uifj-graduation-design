import 'package:conference_app/core/log/log_utils.dart';
import 'package:conference_app/core/network/api_client.dart';
import 'package:conference_app/core/storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'dart:math';

import '../../models/meeting_model.dart';
import '../../models/ticket_model.dart';
import '../../models/announcement_model.dart';

class ApiService {
  // final Dio _dio = Dio();
  // final String _baseUrl = 'http://127.0.0.1:8888';

  // 封装请求方法
  // Future<Map<String, dynamic>> _request(String method, String path,
  //     {Map<String, dynamic>? data,
  //     Map<String, dynamic>? queryParameters}) async {
  //   try {
  //     final response = await _dio.request(
  //       '$_baseUrl$path',
  //       options: Options(
  //         method: method,
  //         headers: {'accept': 'application/json'},
  //       ),
  //       data: data,
  //       queryParameters: queryParameters,
  //     );

  //     if (response.statusCode == 200) {
  //       return response.data;
  //     } else {
  //       throw Exception('请求失败: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('请求发生错误: $e');
  //   }
  // }

  // 使用封装的请求方法重构getCaptcha方法
  Future<Map<String, dynamic>> getCaptcha() async {
    final response = await ApiClient.instance.post('/base/captcha');

    LogUtils().i('message');
    LogUtils().i(response);
    return response.data;
    // return _request('POST', '/base/captcha');
  }

  // 使用封装的请求方法重构login方法
  Future<Map<String, dynamic>> login(String captcha, String captchaId,
      String password, String username) async {
    final response = await ApiClient.instance.post('/base/login', data: {
      "captcha": captcha,
      "captchaId": captchaId,
      "password": password,
      "username": username
    });
    LogUtils().i('login');
    LogUtils().i(response);
    return response.data;
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String nickName,
  }) async {
    try {
      final token = await LocalStorage.getData('token');
      final response = await ApiClient.instance.post(
        '/user/admin_register',
        data: {
          "authorityId": "9529", // 默认为9529，代表普通用户
          "email": email,
          "enable": "1", // 默认为1，代表启用
          "headerImg":
              "https://img2.baidu.com/it/u=3666490114,2864345600&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=500",
          "nickName": nickName,
          "passWord": password,
          "phone": phone,
          "userName": username,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'X-Token': token,
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      LogUtils().e('Registration failed: $e');
      throw Exception('Registration failed: $e');
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await LocalStorage.getData('token');
    try {
      final response = await ApiClient.instance.post(
        '/user/changePassword',
        data: {
          "newPassword": newPassword,
          "password": currentPassword,
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'X-Token': token,
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      LogUtils().e('Password change failed: $e');
      throw Exception('Password change failed: $e');
    }
  }

  // 使用封装的请求方法重构getMeetingList方法
  // Future<Map<String, dynamic>> getMeetingsList() async {
  //   return _request('GET', '/meetings/getMettingList');
  // }

  static Future<AnnouncementResponse> getAnnouncementsList() async {
    final token = await LocalStorage.getData('token');
    try {
      final response = await ApiClient.instance.get(
        '/info/getInfoList',
        options: Options(
          headers: {
            'accept': 'application/json',
            'X-Token': token,
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return AnnouncementResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      LogUtils().e('Failed to fetch announcements: $e');
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  static Future<MeetingResponse> getMeetingsList() async {
    final token = await LocalStorage.getData('token');
    try {
      final response = await ApiClient.instance.get('/meetings/getMeetingsList',
          options: Options(
            headers: {'accept': 'application/json', 'X-Token': token},
          ));

      // Check if the response data is a Map
      if (response.data is Map<String, dynamic>) {
        // Parse the response data into MeetingResponse object
        return MeetingResponse.fromJson(response.data);
      } else {
        // Handle unexpected response format
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      throw Exception('请求出错: $e');
    }
  }

  static Future<Map<String, dynamic>> getMeetingById() async {
    final token = await LocalStorage.getData('token');
    try {
      final response = await ApiClient.instance.get('/meetings/getMeetingsList',
          options: Options(
            headers: {'accept': 'application/json', 'X-Token': token},
          ));
      // if (response.statusCode == 0) {
      LogUtils().w(response);
      // return response.data;
      return {'data': response.data};
      // } else {
      //   throw Exception('请求失败，状态码: ${response.statusCode}');
      // }
    } catch (e) {
      throw Exception('请求出错: $e');
    }
  }

  static Future<TicketResponse> getTicketsList({
    required int userId,
    int? meetingId,
    String? status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final token = await LocalStorage.getData('token');
    try {
      final response = await ApiClient.instance.get('/tickets/getTicketsList',
          queryParameters: {
            'page': page,
            'pageSize': pageSize,
            'user_id': userId,
            if (meetingId != null) 'meeting_id': meetingId,
            if (status != null) 'status': status,
          },
          options: Options(
            headers: {'accept': 'application/json', 'X-Token': token},
          ));

      if (response.data is Map<String, dynamic>) {
        return TicketResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      throw Exception('请求出错: $e');
    }
  }

  // 当管理员身份的用户扫描用户的ticket二维码后，自动修改当前ticket的状态，确保用户的ticket被核销。
  static Future<TicketResponse> checksTicket({
    required String ticketId,
    required int meetingId,
    required int userId,
    required String checkinData,
  }) async {
    final token = await LocalStorage.getData('token');
    try {
      final response = await ApiClient.instance.put(
        '/tickets/updateTickets',
        data: {
          "metting_id": meetingId,
          "ticket_id": ticketId,
          "user_id": userId,
          "checkin_data": checkinData,
          "status": "2", // 2 代表已核销
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'X-Token': token,
          },
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return TicketResponse.fromJson(response.data);
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      LogUtils().e('Ticket verification failed: $e');
      throw Exception('Ticket verification failed: $e');
    }
  }

  static Future<Map<String, dynamic>> reserveTicket({
    required int meetingId,
    required double price,
    required String userId,
  }) async {
    final token = await LocalStorage.getData('token');
    try {
      final now = DateTime.now();
      // 使用 ISO 8601 格式化并添加时区（例如 UTC）
      final formattedTime = now.toUtc().toIso8601String(); // ✅ 规范格式

      final response = await ApiClient.instance.post('/tickets/createTickets',
          data: {
            "metting_id": meetingId,
            "price": price,
            "purchase": formattedTime,
            "qr_data": _generateQrData(),
            "status": '1',
            "ticket_id": "T${DateTime.now().millisecondsSinceEpoch}U$userId",
            "user_id": int.parse(userId)
          },
          options: Options(
            headers: {'accept': 'application/json', 'X-Token': token},
            contentType: 'application/json',
          ));

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        throw Exception('Invalid response format: ${response.data}');
      }
    } catch (e) {
      throw Exception('API Error: $e'); // 更清晰的错误提示
    }
  }

  // 生成唯一的qr_data
  static String _generateQrData() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
