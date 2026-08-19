/// Razorpay settings.
///
/// ---------------------------------------------------------------------------
/// HOW TO SWITCH PAYMENTS ON
/// ---------------------------------------------------------------------------
/// 1. Sign in at https://dashboard.razorpay.com
/// 2. Make sure the dashboard is in **Test Mode** (there is a toggle at the
///    top of the page).
/// 3. Go to: Account & Settings -> API Keys -> Generate Test Key
/// 4. Copy the **Key Id**. It looks like `rzp_test_AbCdEf1234567`.
/// 5. Paste it between the quotes on the `_keyIdWrittenInCode` line below.
///
/// Until you do that, the app keeps working exactly as before, with the
/// pretend "Place Order" flow and no payment window.
///
/// ---------------------------------------------------------------------------
/// IMPORTANT, PLEASE READ
/// ---------------------------------------------------------------------------
/// Razorpay gives you TWO values: a **Key Id** and a **Key Secret**.
///
///   * The Key Id is safe to put here. It is designed to be visible inside
///     apps and web pages.
///
///   * The Key Secret must NEVER be put in this file, or anywhere else in this
///     project. Anyone can pull files apart from an installed app or a web
///     page and read it. The secret belongs only on a server you control.
///
/// This build is TEST MODE only. No real money can move, and payments are not
/// verified by a server yet, which means the app trusts the phone when it says
/// "payment succeeded". That is fine for testing and demos. Before taking real
/// money you need a small server that creates each order and checks Razorpay's
/// signature, otherwise a determined user can fake a successful payment.
class RazorpayConfig {
  const RazorpayConfig._();

  /// Paste your Razorpay **Test** Key Id between these quotes.
  ///
  /// This is the Key **Id**, not the Key Secret. It is safe here and safe in
  /// the public repository — Razorpay designed it to be visible inside apps
  /// and web pages. The Key Secret must never appear in this project.
  static const String _keyIdWrittenInCode = 'rzp_test_TRZZitjVxaKIEp';

  /// The key actually used. A key passed at build time with
  /// `--dart-define=RAZORPAY_KEY_ID=rzp_test_xxx` wins; otherwise the one
  /// written above is used.
  static const String keyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: _keyIdWrittenInCode,
  );

  /// True once a key has been provided, so the app knows whether to open the
  /// real payment window or fall back to the demo flow.
  static bool get isConfigured => keyId.trim().isNotEmpty;

  /// Whether the key is a test key. Used to show the "TEST MODE" notice.
  static bool get isTestKey => keyId.startsWith('rzp_test_');

  /// Business name shown at the top of the Razorpay payment window.
  static const String businessName = 'BiteBay';

  /// Razorpay counts money in paise, not rupees: 197 rupees = 19700 paise.
  static int rupeesToPaise(int rupees) => rupees * 100;

  /// Sample contact details pre-filled in the payment window. Replace these
  /// with the signed-in customer's details once the app has accounts.
  static const String prefillContact = '9999999999';
  static const String prefillEmail = 'test@bitebay.example';

  /// The settings handed to Razorpay when the payment window opens.
  ///
  /// Kept here so the phone version and the web version ask for exactly the
  /// same thing and cannot drift apart.
  static Map<String, dynamic> checkoutOptions({
    required int amountInRupees,
    required String description,
    String? contact,
    String? email,
  }) {
    return <String, dynamic>{
      'key': keyId,
      'amount': rupeesToPaise(amountInRupees),
      'currency': 'INR',
      'name': businessName,
      'description': description,
      'prefill': <String, dynamic>{
        'contact': contact ?? prefillContact,
        'email': email ?? prefillEmail,
      },
      'theme': <String, dynamic>{'color': '#FF5A1F'},
      'retry': <String, dynamic>{'enabled': true, 'max_count': 1},
    };
  }
}
