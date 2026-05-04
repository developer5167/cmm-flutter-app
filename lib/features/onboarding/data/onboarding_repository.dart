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

  /// Upload one or more new photo files to step 8.
  /// Called when the user taps Continue on the photos step.
  Future<void> uploadPhotos(List<String> filePaths) async {
    try {
      if (filePaths.isEmpty) {
        // No new files — just advance the step (existing photos still count)
        await _dio.post(ApiEndpoints.onboardingStep(8), data: FormData());
        return;
      }

      final files = await Future.wait(
        filePaths.map((path) => MultipartFile.fromFile(
          path,
          contentType: DioMediaType('image', 'jpeg'),
        )),
      );

      final formData = FormData.fromMap({'photos': files});
      await _dio.post(ApiEndpoints.onboardingStep(8), data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete an already-uploaded photo by its DB id.
  Future<void> deletePhoto(String photoId) async {
    try {
      await _dio.delete('/onboarding/photos/$photoId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload identity verification video. Called when user taps Continue on step 9.
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
    return 'Network error. Please try again.';
  }
}
