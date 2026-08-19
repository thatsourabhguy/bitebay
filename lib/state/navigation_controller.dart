import 'package:flutter/foundation.dart';

/// Remembers which bottom-navigation tab is showing.
///
/// Living outside the screens means any screen can say "take me to the Cart
/// tab" without needing a reference to the navigation bar itself.
class NavigationController extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  static const int homeTab = 0;
  static const int searchTab = 1;
  static const int cartTab = 2;
  static const int accountTab = 3;

  void goToTab(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}
