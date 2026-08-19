import 'package:flutter/foundation.dart';

/// A saved delivery address. All addresses in this build are fake sample data.
@immutable
class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.city,
    required this.pincode,
    required this.phone,
  });

  final String id;

  /// "Home", "Work", "Other"
  final String label;
  final String line1;
  final String line2;
  final String city;
  final String pincode;
  final String phone;

  String get fullAddress => '$line1, $line2, $city - $pincode';
}
