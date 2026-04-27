import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

class DiscoverRepository {
  final Dio _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> fetchFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get('${ApiEndpoints.discoverFeed}?page=$page&limit=$limit');
      return List<Map<String, dynamic>>.from(response.data['data']['profiles']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendInterest(String targetUserId, {bool isSuperInterest = false}) async {
    try {
      await _dio.post(ApiEndpoints.sendInterest, data: {
        'target_user_id': targetUserId,
        'type': isSuperInterest ? 'super_interest' : 'interest'
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> passProfile(String targetUserId) async {
    try {
      await _dio.post(ApiEndpoints.sendInterest, data: {
        'target_user_id': targetUserId,
        'type': 'pass'
      });
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
