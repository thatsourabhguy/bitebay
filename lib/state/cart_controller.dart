import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/menu_item.dart';
import '../data/models/price_breakdown.dart';
import '../data/models/restaurant.dart';

/// What happened when the user tried to apply a coupon code.
@immutable
class CouponResult {
  const CouponResult({required this.success, required this.message});
  final bool success;
  final String message;
}

/// Holds the cart for the whole app and tells the screens when it changes.
///
/// `ChangeNotifier` is Flutter's built-in "something changed, redraw"
/// mechanism. Any screen that listens to this object updates itself
/// automatically the moment an item is added or removed.
class CartController extends ChangeNotifier {
  /// Dish id -> line in the cart. A Map keeps lookups fast.
  final Map<String, CartItem> _lines = <String, CartItem>{};

  Restaurant? _restaurant;
  String? _appliedCoupon;

  // ---------------------------------------------------------------- reading

  List<CartItem> get items => List<CartItem>.unmodifiable(_lines.values);

  /// The restaurant the current cart belongs to (null when the cart is empty).
  Restaurant? get restaurant => _restaurant;

  String? get appliedCoupon => _appliedCoupon;

  bool get isEmpty => _lines.isEmpty;

  bool get isNotEmpty => _lines.isNotEmpty;

  /// Total number of dishes, counting quantities (2 naan + 1 dal = 3).
  int get totalQuantity =>
      _lines.values.fold(0, (int sum, CartItem line) => sum + line.quantity);

  /// How many of a particular dish are in the cart right now.
  int quantityOf(String menuItemId) => _lines[menuItemId]?.quantity ?? 0;

  // --------------------------------------------------------------- the bill

  int get itemTotal =>
      _lines.values.fold(0, (int sum, CartItem line) => sum + line.lineTotal);

  /// Delivery fee grows a little with distance, and is waived on big orders.
  int get _baseDeliveryFee {
    final Restaurant? r = _restaurant;
    if (r == null || isEmpty) return 0;
    return (20 + r.distanceKm * 6).round().clamp(25, 79);
  }

  static const int _freeDeliveryThreshold = 499;
  static const int _platformFee = 6;

  int get deliveryFee {
    if (isEmpty) return 0;
    if (itemTotal >= _freeDeliveryThreshold) return 0;
    if (_appliedCoupon == 'FREEDEL' && itemTotal >= 299) return 0;
    return _baseDeliveryFee;
  }

  int get platformFee => isEmpty ? 0 : _platformFee;

  /// GST and restaurant charges, 5% of the food value.
  int get taxesAndCharges => isEmpty ? 0 : (itemTotal * 0.05).round();

  int get discount {
    if (isEmpty) return 0;
    switch (_appliedCoupon) {
      case 'BITE50':
        if (itemTotal < 199) return 0;
        return (itemTotal * 0.5).round().clamp(0, 100);
      case 'FEAST125':
        return itemTotal >= 399 ? 125 : 0;
      default:
        return 0;
    }
  }

  /// The complete bill, always recalculated from what is in the cart.
  PriceBreakdown get breakdown => PriceBreakdown(
    itemTotal: itemTotal,
    deliveryFee: deliveryFee,
    platformFee: platformFee,
    taxesAndCharges: taxesAndCharges,
    discount: discount,
  );

  int get grandTotal => breakdown.grandTotal;

  /// How much more the user must add to unlock free delivery.
  int get amountToFreeDelivery {
    if (isEmpty || itemTotal >= _freeDeliveryThreshold) return 0;
    return _freeDeliveryThreshold - itemTotal;
  }

  // -------------------------------------------------------------- modifying

  /// True when adding this dish would mix two different restaurants.
  ///
  /// Food delivery apps only allow one restaurant per order, so the UI asks
  /// the user before throwing the old cart away.
  bool wouldReplaceCart(Restaurant restaurant) =>
      isNotEmpty && _restaurant != null && _restaurant!.id != restaurant.id;

  /// Adds one of [item]. Pass [replaceCart] to wipe a cart that belongs to a
  /// different restaurant first.
  void addItem(
    MenuItem item,
    Restaurant restaurant, {
    bool replaceCart = false,
  }) {
    if (wouldReplaceCart(restaurant)) {
      if (!replaceCart) return;
      _lines.clear();
      _appliedCoupon = null;
    }

    _restaurant = restaurant;
    final CartItem? existing = _lines[item.id];
    _lines[item.id] = existing == null
        ? CartItem(menuItem: item, quantity: 1)
        : existing.copyWith(quantity: existing.quantity + 1);

    notifyListeners();
  }

  /// Removes one of [menuItemId]; drops the line entirely when it hits zero.
  void decrementItem(String menuItemId) {
    final CartItem? existing = _lines[menuItemId];
    if (existing == null) return;

    if (existing.quantity <= 1) {
      _lines.remove(menuItemId);
    } else {
      _lines[menuItemId] = existing.copyWith(quantity: existing.quantity - 1);
    }

    if (_lines.isEmpty) _resetCartMeta();
    notifyListeners();
  }

  /// Removes a whole line no matter its quantity (the "delete" button).
  void removeItem(String menuItemId) {
    if (_lines.remove(menuItemId) == null) return;
    if (_lines.isEmpty) _resetCartMeta();
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _resetCartMeta();
    notifyListeners();
  }

  void _resetCartMeta() {
    _restaurant = null;
    _appliedCoupon = null;
  }

  // ---------------------------------------------------------------- coupons

  static const Map<String, String> _couponRules = <String, String>{
    'BITE50': 'Minimum order ₹199 required for BITE50.',
    'FEAST125': 'Minimum order ₹399 required for FEAST125.',
    'FREEDEL': 'Minimum order ₹299 required for FREEDEL.',
  };

  CouponResult applyCoupon(String rawCode) {
    final String code = rawCode.trim().toUpperCase();

    if (isEmpty) {
      return const CouponResult(
        success: false,
        message: 'Add something to your cart first.',
      );
    }
    if (!_couponRules.containsKey(code)) {
      return CouponResult(success: false, message: '"$code" is not a valid code.');
    }

    final bool meetsMinimum = switch (code) {
      'BITE50' => itemTotal >= 199,
      'FEAST125' => itemTotal >= 399,
      'FREEDEL' => itemTotal >= 299,
      _ => false,
    };

    if (!meetsMinimum) {
      return CouponResult(success: false, message: _couponRules[code]!);
    }

    _appliedCoupon = code;
    notifyListeners();
    return CouponResult(success: true, message: '$code applied successfully!');
  }

  void removeCoupon() {
    if (_appliedCoupon == null) return;
    _appliedCoupon = null;
    notifyListeners();
  }
}
