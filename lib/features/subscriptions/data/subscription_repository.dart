import '../../../core/network/dio_client.dart';
import '../../../core/di/injection.dart';

class SubscriptionRepository {
  final _dio = sl<DioClient>().dio;

  Future<List<Map<String, dynamic>>> fetchPlans() async {
    final response = await _dio.get('/subscription/plans');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> createOrder(int planId) async {
    final response = await _dio.post('/subscription/razorpay/order', data: {'plan_id': planId});
    return Map<String, dynamic>.from(response.data['data']);
  }
}
