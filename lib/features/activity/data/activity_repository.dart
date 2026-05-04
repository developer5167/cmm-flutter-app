import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';

class ActivityRepository {
  final Dio _dio = DioClient.instance;

  // ── Summary (badge counts) ──────────────────────────────────
  Future<Map<String, dynamic>> fetchSummary() async {
    try {
      final res = await _dio.get(ApiEndpoints.activitySummary);
      return Map<String, dynamic>.from(res.data['data'] ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Notifications ───────────────────────────────────────────
  Future<Map<String, dynamic>> fetchNotifications({int page = 1}) async {
    try {
      final res = await _dio.get(ApiEndpoints.notifications, queryParameters: {'page': page});
      return Map<String, dynamic>.from(res.data['data'] ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.put(ApiEndpoints.notificationsReadAll);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markOneRead(String id) async {
    try {
      await _dio.put(ApiEndpoints.notificationRead(id));
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Views (who viewed me) ───────────────────────────────────
  Future<Map<String, dynamic>> fetchViews({int page = 1}) async {
    try {
      final res = await _dio.get(ApiEndpoints.activityViews, queryParameters: {'page': page});
      return Map<String, dynamic>.from(res.data['data'] ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Shortlists ──────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchShortlists({int page = 1}) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.activityShortlists, queryParameters: {'page': page});
      return Map<String, dynamic>.from(res.data['data'] ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> toggleShortlist(String targetUserId) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.activityShortlists,
        data: {'target_user_id': targetUserId},
      );
      return res.data['data']['is_shortlisted'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> checkShortlisted(String targetUserId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.activityShortlistsCheck,
        queryParameters: {'target_user_id': targetUserId},
      );
      return res.data['data']['is_shortlisted'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'An error occurred';
    }
    return 'Network error. Please try again.';
  }
}
