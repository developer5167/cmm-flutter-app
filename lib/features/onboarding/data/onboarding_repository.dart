import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

class OnboardingRepository {
  final Dio _dio = DioClient.instance;

  Future<void> saveStep(int step, Map<String, dynamic> data) async {
    try {
      await _dio.post('${ApiEndpoints.onboarding}/$step', data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadPhoto(String filePath, int index) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
        'index': index,
      });
      await _dio.post('${ApiEndpoints.onboarding}/photo', data: formData);
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
      return e.response?.data['message'] ?? 'An error occurred';
    }
    return 'Detailed network error. Please try again.';
  }
}
