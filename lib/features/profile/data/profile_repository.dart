import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

class ProfileRepository {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> fetchMyProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.myProfile);
      return response.data['data']['profile'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _dio.post(ApiEndpoints.updateSettings, data: settings);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'An error occurred';
    }
    return 'Detailed network error. Please try again.';
  }
}
