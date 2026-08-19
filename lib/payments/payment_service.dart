import 'payment_service_stub.dart'
    if (dart.library.js_interop) 'razorpay_web_impl.dart'
    if (dart.library.io) 'razorpay_mobile_impl.dart';

/// What happened when the user went through the payment window.
sealed class PaymentOutcome {
  const PaymentOutcome();
}

/// Razorpay reported a successful payment.
///
/// Note: nothing has *verified* that claim yet. See the warning in
/// `RazorpayConfig` — a server must check Razorpay's signature before this can
/// be trusted for real money.
class PaymentSucceeded extends PaymentOutcome {
  const PaymentSucceeded({
    required this.paymentId,
    this.orderId,
    this.signature,
  });

  final String paymentId;
  final String? orderId;
  final String? signature;
}

/// The payment was attempted but did not go through.
class PaymentFailed extends PaymentOutcome {
  const PaymentFailed({required this.message, this.code});

  final String message;
  final int? code;
}

/// The user closed the payment window without paying.
class PaymentCancelled extends PaymentOutcome {
  const PaymentCancelled();
}

/// No payment was taken because no Razorpay key has been set up yet.
class PaymentSkipped extends PaymentOutcome {
  const PaymentSkipped();
}

/// The app's view of "take a payment".
///
/// Screens depend on this, never on Razorpay directly, so the payment provider
/// can be swapped later without touching a single screen — the same idea as
/// `RestaurantRepository` for data.
abstract class PaymentService {
  /// Opens the payment window and completes once the user is finished.
  Future<PaymentOutcome> payForOrder({
    required int amountInRupees,
    required String description,
    String? contact,
    String? email,
  });

  void dispose();
}

/// Builds the right payment service for whatever the app is running on.
///
/// Android and iOS get Razorpay's official Flutter package; the web gets
/// Razorpay's checkout.js script. Which file supplies this function is decided
/// at compile time by the conditional import at the top of this file, so the
/// mobile code is never even included in the web build, and vice versa.
PaymentService createPaymentService() => createPlatformPaymentService();
