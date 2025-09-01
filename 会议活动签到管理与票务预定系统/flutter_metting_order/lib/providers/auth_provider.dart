import 'package:conference_app/core/storage/local_storage.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isStaff => _currentUser?.isStaff ?? false;

  Future<bool> login(String captcha, String captchaId, String password,
      String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // 使用实际的network请求
      final apiService = ApiService(); // 使用单例模式获取实例
      final response =
          await apiService.login(captcha, captchaId, password, username);
      if (response['code'] == 0) {
        final userData = response['data']['user'];
        final token = response['data']['token'];
        // 保存user基本信息和token到storage
        LocalStorage.saveData('userId', userData['ID'].toString());
        LocalStorage.saveData('userName', userData['userName']);
        LocalStorage.saveData('phone', userData['phone']);
        LocalStorage.saveData('headerImg', userData['headerImg']);
        LocalStorage.saveData('token', token);
        _currentUser = User(
          id: userData['ID'].toString(),
          name: userData['userName'],
          email: userData['email'],
          role: UserRole.attendee,
          ticketIds: [],
        );
      } else {
        _error = '登录失败: ${response['msg']}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
      // 保留mock数据
      // await Future.delayed(const Duration(seconds: 1));
      // if (email == 'user@example.com' && password == 'password') {
      //   _currentUser = User(
      //     id: '1',
      //     name: 'John Doe',
      //     email: email,
      //     role: UserRole.attendee,
      //     ticketIds: ['ticket1', 'ticket2'],
      //   );
      // } else if (email == 'staff@example.com' && password == 'password') {
      //   _currentUser = User(
      //     id: '2',
      //     name: 'Staff User',
      //     email: email,
      //     role: UserRole.staff,
      //     ticketIds: [],
      //   );
      // } else {
      //   _error = 'Invalid email or password';
      //   _isLoading = false;
      //   notifyListeners();
      //   return false;
      // }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String nickName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(
        username: username,
        password: password,
        email: email,
        phone: phone,
        nickName: nickName,
      );

      if (response['code'] == 0) {
        final userData = response['data']['user'];
        final token = response['data']['token'];

        // Save user data and token to storage
        LocalStorage.saveData('userId', userData['ID'].toString());
        LocalStorage.saveData('userName', userData['userName']);
        LocalStorage.saveData('phone', userData['phone']);
        LocalStorage.saveData('headerImg', userData['headerImg']);
        LocalStorage.saveData('token', token);

        _currentUser = User(
          id: userData['ID'].toString(),
          name: userData['userName'],
          email: userData['email'],
          role: UserRole.attendee,
          ticketIds: [],
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed: ${response['msg']}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
