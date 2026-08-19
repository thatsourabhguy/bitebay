import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'payment_service.dart';
import 'razorpay_config.dart';

/// Used on the web. Talks to Razorpay's own `checkout.js`, which is loaded by
/// the script tag in `web/index.html`.
PaymentService createPlatformPaymentService() => RazorpayWebPaymentService();

/// The `Razorpay` object that checkout.js puts on the page.
@JS('Razorpay')
extension type _RazorpayJs._(JSObject _) implements JSObject {
  external factory _RazorpayJs(JSObject options);

  /// Opens the payment popup.
  external void open();

  /// Subscribes to an event, e.g. `payment.failed`.
  external void on(String event, JSFunction handler);
}

/// True when checkout.js finished loading. If the script is blocked (no
/// internet, an ad blocker, a strict company network) this stays false and we
/// report a clear message instead of doing nothing.
bool get _checkoutScriptLoaded =>
    globalContext.hasProperty('Razorpay'.toJS).toDart;

class RazorpayWebPaymentService implements PaymentService {
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

    if (!_checkoutScriptLoaded) {
      return Future<PaymentOutcome>.value(
        const PaymentFailed(
          message:
              'The payment window could not load. Check your internet '
              'connection or any ad blocker, then try again.',
        ),
      );
    }

    final Completer<PaymentOutcome>? inFlight = _pending;
    if (inFlight != null && !inFlight.isCompleted) return inFlight.future;

    final Completer<PaymentOutcome> completer = Completer<PaymentOutcome>();
    _pending = completer;

    try {
      final JSObject options = _buildOptions(
        amountInRupees: amountInRupees,
        description: description,
        contact: contact,
        email: email,
      );

      final _RazorpayJs razorpay = _RazorpayJs(options);

      // Razorpay reports a declined or failed payment through this event
      // rather than through the success handler.
      razorpay.on(
        'payment.failed',
        ((JSObject event) {
          final JSObject? error = event.getProperty('error'.toJS);
          final String? reason = error
              ?.getProperty<JSString?>('description'.toJS)
              ?.toDart;
          _complete(
            PaymentFailed(message: reason ?? 'The payment did not go through.'),
          );
        }).toJS,
      );

      razorpay.open();
    } catch (error) {
      _complete(
        PaymentFailed(message: 'Could not open the payment window: $error'),
      );
    }

    return completer.future;
  }

  /// Turns the shared settings into the JavaScript object checkout.js wants,
  /// and attaches the success and "window closed" callbacks.
  JSObject _buildOptions({
    required int amountInRupees,
    required String description,
    String? contact,
    String? email,
  }) {
    final Map<String, dynamic> base = RazorpayConfig.checkoutOptions(
      amountInRupees: amountInRupees,
      description: description,
      contact: contact,
      email: email,
    );

    final JSObject options = base.jsify()! as JSObject;

    // Called by Razorpay when the payment succeeds.
    options.setProperty(
      'handler'.toJS,
      ((JSObject response) {
        _complete(
          PaymentSucceeded(
            paymentId:
                response.getProperty<JSString?>('razorpay_payment_id'.toJS)
                    ?.toDart ??
                '',
            orderId: response
                .getProperty<JSString?>('razorpay_order_id'.toJS)
                ?.toDart,
            signature: response
                .getProperty<JSString?>('razorpay_signature'.toJS)
                ?.toDart,
          ),
        );
      }).toJS,
    );

    // Called when the user closes the popup without paying.
    final JSObject modal = JSObject();
    modal.setProperty(
      'ondismiss'.toJS,
      (() => _complete(const PaymentCancelled())).toJS,
    );
    options.setProperty('modal'.toJS, modal);

    return options;
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
  }
}
