import 'package:conference_app/core/log/log_utils.dart';
import 'package:conference_app/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import 'register_screen.dart';
import '../../core/network/api_service.dart';

final log = LogUtils();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? captchaId;
  String? captchaImage;
  final TextEditingController _captchaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // 等待获取验证码完成
    await _getCaptcha();
    // 弹出一个对话框，显示验证码图片和输入框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('验证码'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (captchaImage != null) Image.network(captchaImage!),
              const SizedBox(height: 16),
              TextField(
                controller: _captchaController,
                decoration: const InputDecoration(
                  labelText: '输入验证码',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _verifyCaptchaAndLogin();
              },
              child: const Text('确定'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }
    final authProvider = Provider.of<AuthProvider>(context,
        listen: false); // 使用单例模式的AuthProvider实例
    // final success = await authProvider.login(
    //   _emailController.text.trim(),
    //   _passwordController.text,
    // );
    // if (success && mounted) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (ctx) => const HomeScreen()),
    //   );
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getCaptcha() async {
    try {
      final apiService = ApiService();
      final response = await apiService.getCaptcha();
      log.i('getCaptcha response: $response');
      if (response['code'] == 0) {
        setState(() {
          captchaId = response['data']['captchaId'];
          captchaImage = response['data']['picPath'];
        });
      } else {
        // 处理错误
      }
    } catch (e) {
      // 处理异常
    }
  }

// ... existing code ...

  Future<void> _verifyCaptchaAndLogin() async {
    final captcha = _captchaController.text;
    if (captcha.isNotEmpty && captchaId != null) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // 调用 authProvider 中的 login 方法
        final success = await authProvider.login(
          captcha,
          captchaId!,
          _passwordController.text,
          _emailController.text.trim(),
        );
        if (success && mounted) {
          // 登录成功处理
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const HomeScreen()),
          );
        } else {
          // 登录失败处理
        }
      } catch (e) {
        // 处理异常
        log.e('登录过程中出现异常: $e');
      }
    }
  }

// ... existing code ...

  @override
  Widget build(BuildContext context) {
    final authProvider =
        Provider.of<AuthProvider>(context); // 使用单例模式的AuthProvider实例

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon(
                //   Icons.event_seat,
                //   size: 64,
                //   color: Theme.of(context).primaryColor,
                // ),

                Image.asset(
                  'assets/images/logo.png',
                  height: 90,
                ),

                const SizedBox(height: 16),
                Text(
                  '欢迎回来',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '会议活动票务预定与签到管理系统',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '用户登录',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          // if (!value.contains('@')) {
                          //   return 'Please enter a valid email';
                          // }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      // Align(
                      //   alignment: Alignment.centerRight,
                      //   child: TextButton(
                      //     onPressed: () {
                      //       // Forgot password functionality
                      //     },
                      //     child: const Text('Forgot Password?'),
                      //   ),
                      // ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          // onPressed: authProvider.isLoading ? null : _login,
                          onPressed: _login,
                          child: authProvider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("还没有账号?"),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text('注册'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Demo Accounts:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Attendee: user@example.com / password\nStaff: staff@example.com / password',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
