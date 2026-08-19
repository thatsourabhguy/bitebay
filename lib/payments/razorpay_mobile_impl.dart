import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'payment_service.dart';
import 'razorpay_config.dart';

/// Used on Android and iOS. Wraps Razorpay's official Flutter package.
PaymentService createPlatformPaymentService() => RazorpayMobilePaymentService();

/// Razorpay reports its result through three separate callbacks. This class
/// hides that: it wraps them in a [Completer] so callers can simply
/// `await payForOrder(...)` and get one answer back.
class RazorpayMobilePaymentService implements PaymentService {
  RazorpayMobilePaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  late final Razorpay _razorpay;

  /// Completes when the current payment attempt finishes. Null when no
  /// payment window is open.
  Completer<PaymentOutcome>? _pending;

  bool _disposed = false;

  @override
  Future<PaymentOutcome> payForOrder({
    required int amountInRupees,
    required String description,
    String? contact,
    String? email,
  }) {
    if (!RazorpayConfig.isConfigured) {
      return Future<PaymentOutcome>.value(const PaymentSkipped());
    }

    // Guard against a second window opening over the first.
    final Completer<PaymentOutcome>? inFlight = _pending;
    if (inFlight != null && !inFlight.isCompleted) return inFlight.future;

    final Completer<PaymentOutcome> completer = Completer<PaymentOutcome>();
    _pending = completer;

    try {
      _razorpay.open(
        RazorpayConfig.checkoutOptions(
          amountInRupees: amountInRupees,
          description: description,
          contact: contact,
          email: email,
        ),
      );
    } catch (error) {
      _complete(
        PaymentFailed(message: 'Could not open the payment window: $error'),
      );
    }

    return completer.future;
  }

  void _onSuccess(PaymentSuccessResponse response) {
    _complete(
      PaymentSucceeded(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId,
        signature: response.signature,
      ),
    );
  }

  void _onError(PaymentFailureResponse response) {
    // Razorpay uses this same callback when the user just closes the window.
    final String message = response.message ?? 'Payment was not completed.';
    final bool looksCancelled =
        response.code == Razorpay.PAYMENT_CANCELLED ||
        message.toLowerCase().contains('cancel');

    _complete(
      looksCancelled
          ? const PaymentCancelled()
          : PaymentFailed(message: message, code: response.code),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    // Razorpay hands control to the wallet app and never reports back, so
    // there is no result to confirm here.
    _complete(
      PaymentFailed(
        message:
            'Payment continues in ${response.walletName ?? 'the wallet app'}. '
            'Please finish it there and try again.',
      ),
    );
  }

  void _complete(PaymentOutcome outcome) {
    final Completer<PaymentOutcome>? completer = _pending;
    _pending = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete(outcome);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    // Release anyone still waiting if the screen goes away mid-payment.
    _complete(const PaymentCancelled());

    try {
      _razorpay.clear();
    } catch (error) {
      debugPrint('Razorpay cleanup failed: $error');
    }
  }
}
