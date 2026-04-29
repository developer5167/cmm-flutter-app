import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

class OnboardingRepository {
  final Dio _dio = DioClient.instance;

  Future<void> saveStep(int step, Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiEndpoints.onboardingStep(step), data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await _dio.get(ApiEndpoints.onboardingStatus);
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadPhoto(String filePath, int index) async {
    try {
      final formData = FormData.fromMap({
        'photos': await MultipartFile.fromFile(filePath),
        'index': index,
      });
      await _dio.post(ApiEndpoints.onboardingStep(8), data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> submitIdentityVerification(String videoFilePath) async {
    try {
      final formData = FormData.fromMap({
        'video': await MultipartFile.fromFile(videoFilePath),
      });
      await _dio.post(ApiEndpoints.verifyIdentity, data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['errors'] != null && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.map((err) => '• ${err['message']}').join('\n');
          }
        }
        return data['message'] ?? 'An error occurred';
      }
    }
    return 'Detailed network error. Please try again.';
  }
}
