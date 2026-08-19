import 'payment_service.dart';

/// Fallback used only on a platform that is neither mobile nor web (for
/// example Windows or Linux desktop, which this app does not target).
///
/// It never opens a payment window; it simply reports that no payment was
/// taken, so the app still works instead of crashing.
PaymentService createPlatformPaymentService() => const _UnsupportedPaymentService();

class _UnsupportedPaymentService implements PaymentService {
  const _UnsupportedPaymentService();

  @override
  Future<PaymentOutcome> payForOrder({
    required int amountInRupees,
    required String description,
    String? contact,
    String? email,
  }) async => const PaymentSkipped();

  @override
  void dispose() {}
}
