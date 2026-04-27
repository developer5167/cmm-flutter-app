import '../../../core/network/dio_client.dart';
import '../../../core/constants/app_constants.dart';

class SubscriptionRepository {
  final _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> fetchPlans() async {
    final response = await _dio.get(ApiEndpoints.plans);
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> createOrder(int planId) async {
    final response = await _dio.post(ApiEndpoints.razorpayOrder, data: {'plan_id': planId});
    return Map<String, dynamic>.from(response.data['data']);
  }
}
