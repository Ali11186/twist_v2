import 'package:http/http.dart' as http;
import 'dart:convert';

class TwistService {
  static const String baseUrl = 'https://api.twistmena.com';
  String? _authToken;
  String? _accessToken;
  String? _tgToken;
  String? _tgRefreshToken;
  String? _tgDeviceId;

  final http.Client _httpClient = http.Client();

  Map<String, String> _buildHeaders() {
    return {
      'user-agent': 'Twist-Mobile/11.2.10 (Android; 12; SM-A217F; music; ar-AE)',
      'app_version': '11.2.10',
      'appversion': '11.2.10',
      'channel': 'mobileapp',
      'content-type': 'application/json',
      'platform': 'android',
      'accept': 'application/json',
      'accept-language': 'ar',
      'host': 'api.twistmena.com',
      'device_id': 'SP1A.210812.016',
      'tgdeviceid': _tgDeviceId ?? '22821093',
      'device_token': '',
      'tg-token': _tgToken ?? '',
      'tg-refresh-token': _tgRefreshToken ?? '',
      'access-token': _accessToken ?? '',
      'sessionid': DateTime.now().millisecondsSinceEpoch.toString(),
      'accept-encoding': 'gzip',
      'connection': 'keep-alive',
      if (_authToken != null) 'authorization': 'Bearer $_authToken',
    };
  }

  Future<bool> sendOTP(String phone) async {
    try {
      String formattedPhone = phone;
      if (phone.startsWith('01')) {
        formattedPhone = '2' + phone;
      } else if (!phone.startsWith('2')) {
        formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
        if (!formattedPhone.startsWith('2')) {
          formattedPhone = '2' + formattedPhone;
        }
      }

      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/music/Dlogin/sendCode'),
            headers: _buildHeaders(),
            body: jsonEncode({'dial': formattedPhone}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('SendOTP Error: $e');
      return false;
    }
  }

  Future<bool> verifyOTP(String phone, String code) async {
    try {
      String formattedPhone = phone;
      if (phone.startsWith('01')) {
        formattedPhone = '2' + phone;
      } else if (!phone.startsWith('2')) {
        formattedPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
        if (!formattedPhone.startsWith('2')) {
          formattedPhone = '2' + formattedPhone;
        }
      }

      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/music/Dlogin/verify'),
            headers: _buildHeaders(),
            body: jsonEncode({
              'dial': formattedPhone,
              'verifyCode': code,
              'socialServiceName': '',
              'socialServiceToken': '',
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map) {
          _authToken = data['token'] ??
              data['authorization'] ??
              response.headers['authorization']?.replaceAll('Bearer ', '');
          _accessToken = data['accessToken'] ?? data['access_token'] ?? '';
          _tgToken = data['tgToken'] ?? data['tg_token'] ?? '';
          _tgRefreshToken =
              data['tgRefreshToken'] ?? data['tg_refresh_token'] ?? '';
          _tgDeviceId = data['tgDeviceId'] ?? data['tg_device_id'] ?? '22821093';
        }

        return _authToken != null;
      }
      return false;
    } catch (e) {
      print('VerifyOTP Error: $e');
      return false;
    }
  }

  Future<int> getBalance() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$baseUrl/music/user/loyalty/balance/details'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map) {
          return int.parse(data['balance']?.toString() ?? '0');
        } else if (data is List && data.isNotEmpty) {
          return int.parse(data[0]['balance']?.toString() ?? '0');
        }
      }
      return 0;
    } catch (e) {
      print('GetBalance Error: $e');
      return 0;
    }
  }

  Future<int> completeAchievements() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('$baseUrl/music/user/loyalty/achievements/v2'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return 0;

      final data = jsonDecode(response.body);
      if (data is! Map || !data.containsKey('badges')) return 0;

      int completedCount = 0;
      final categories = data['badges'] as List;

      for (var category in categories) {
        if (category is! Map) continue;

        final tasks = category['badges'] as List? ?? [];

        for (var task in tasks) {
          if (task is! Map) continue;
          if (task['rewarded'] == true) continue;

          final taskId = task['id'];
          if (taskId == null) continue;

          try {
            final taskRes = await _httpClient
                .post(
                  Uri.parse('$baseUrl/music/loyalty/action/$taskId'),
                  headers: _buildHeaders(),
                )
                .timeout(const Duration(seconds: 10));

            if (taskRes.statusCode == 200) {
              completedCount++;
            }
          } catch (e) {
            print('Task Error: $e');
          }

          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      return completedCount;
    } catch (e) {
      print('CompleteAchievements Error: $e');
      return 0;
    }
  }

  Future<bool> redeemUnits(String redeemCode) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$baseUrl/music/loyalty/redeem/$redeemCode'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('RedeemUnits Error: $e');
      return false;
    }
  }

  void logout() {
    _authToken = null;
    _accessToken = null;
    _tgToken = null;
    _tgRefreshToken = null;
    _tgDeviceId = null;
  }

  bool get isLoggedIn => _authToken != null;
}
