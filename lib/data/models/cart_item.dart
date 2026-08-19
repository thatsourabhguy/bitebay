import 'package:flutter/foundation.dart';
import 'menu_item.dart';

/// A dish in the cart together with how many of it the user wants.
@immutable
class CartItem {
  const CartItem({required this.menuItem, required this.quantity});

  final MenuItem menuItem;
  final int quantity;

  /// Price of this line: dish price × quantity.
  int get lineTotal => menuItem.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(menuItem: menuItem, quantity: quantity ?? this.quantity);
}
