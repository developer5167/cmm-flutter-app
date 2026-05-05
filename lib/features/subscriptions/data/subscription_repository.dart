import '../../../core/network/dio_client.dart';
import '../../../core/constants/app_constants.dart';

class SubscriptionRepository {
  final _dio = DioClient.instance;

  Future<List<Map<String, dynamic>>> fetchPlans() async {
    final response = await _dio.get(ApiEndpoints.plans);
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<Map<String, dynamic>> createOrder(dynamic planId) async {
    final id = planId.toString().trim();
    final response = await _dio.post(ApiEndpoints.razorpayOrder, data: {'plan_id': id});
    return Map<String, dynamic>.from(response.data['data']);
  }

  /// Verifies the payment signature server-side and activates the subscription.
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.razorpayVerify, data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      });
      return response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
