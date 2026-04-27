import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/subscription_repository.dart';

// ─── Events ──────────────────────────────────────────────────
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class FetchPlansEvent extends SubscriptionEvent {}

class InitiatePaymentEvent extends SubscriptionEvent {
  final Map<String, dynamic> plan;
  const InitiatePaymentEvent(this.plan);
}

class PaymentSuccessEvent extends SubscriptionEvent {
  final PaymentSuccessResponse response;
  const PaymentSuccessEvent(this.response);
}

class PaymentErrorEvent extends SubscriptionEvent {
  final PaymentFailureResponse response;
  const PaymentErrorEvent(this.response);
}

// ─── States ──────────────────────────────────────────────────
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}
class SubscriptionLoading extends SubscriptionState {}
class PlansLoaded extends SubscriptionState {
  final List<Map<String, dynamic>> plans;
  const PlansLoaded(this.plans);
}
class PaymentPending extends SubscriptionState {}
class PaymentProcessed extends SubscriptionState {
  final bool success;
  final String? message;
  const PaymentProcessed({required this.success, this.message});
}
class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
}

// ─── BLoC ────────────────────────────────────────────────────
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository _repository;
  final Razorpay _razorpay = Razorpay();

  SubscriptionBloc(this._repository) : super(SubscriptionInitial()) {
    on<FetchPlansEvent>(_onFetchPlans);
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<PaymentSuccessEvent>(_onPaymentSuccess);
    on<PaymentErrorEvent>(_onPaymentError);

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _onFetchPlans(FetchPlansEvent event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final plans = await _repository.fetchPlans();
      emit(PlansLoaded(plans));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> _onInitiatePayment(InitiatePaymentEvent event, Emitter<SubscriptionState> emit) async {
    emit(PaymentPending());
    try {
      final orderData = await _repository.createOrder(event.plan['id']);
      
      var options = {
        'key': orderData['key'],
        'amount': orderData['amount'] * 100,
        'name': 'GraceMatch Premium',
        'order_id': orderData['order_id'],
        'description': event.plan['name'],
        'timeout': 300, // in seconds
        'prefill': {
          'contact': '9100000000', // Should come from User Profile
          'email': 'user@example.com'
        }
      };

      _razorpay.open(options);
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  void _onPaymentSuccess(PaymentSuccessEvent event, Emitter<SubscriptionState> emit) {
    emit(const PaymentProcessed(success: true, message: 'Payment Successful! Subscription activating...'));
  }

  void _onPaymentError(PaymentErrorEvent event, Emitter<SubscriptionState> emit) {
    emit(PaymentProcessed(success: false, message: 'Payment Failed: ${event.response.message}'));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    add(PaymentSuccessEvent(response));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    add(PaymentErrorEvent(response));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet if needed
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
