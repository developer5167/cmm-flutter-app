import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_storage.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post(ApiEndpoints.sendOtp, data: {'phone': phone});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyOtp,
        data: {'phone': phone, 'otp': otp},
      );
      
      final data = response.data['data'];
      final String accessToken = data['access_token'];
      final String refreshToken = data['refresh_token'];
      final bool isNewUser = data['is_new_user'] ?? false;
      
      await AppStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      return {
        'is_new_user': isNewUser,
        'user': data['user'],
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.post(ApiEndpoints.updateFcmToken, data: {'fcm_token': fcmToken});
    } catch (_) {
      // Background fail-safe
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await AppStorage.clearAll();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'An error occurred';
    }
    return 'Detailed network error. Please try again.';
  }
}
