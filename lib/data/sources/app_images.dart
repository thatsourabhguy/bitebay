/// Photo URLs used by the sample data.
///
/// These are free-to-use photographs served from a public image CDN, not
/// assets copied from any food-delivery company. If the device is offline
/// the app draws a styled placeholder instead (see `FoodImage`).
class AppImages {
  const AppImages._();

  /// Builds a correctly sized image URL so we never download a huge photo
  /// just to show it in a small card.
  static String photo(String id, {int width = 600}) =>
      'https://images.unsplash.com/photo-$id?w=$width&q=70&auto=format&fit=crop';

  static const String burger = '1568901346375-23c9450c58cd';
  static const String burgerAlt = '1571091718767-18b5b1457add';
  static const String pizza = '1565299624946-b28f40a0ae38';
  static const String pizzaAlt = '1513104890138-7c749659a591';
  static const String salad = '1512621776951-a57141f2eefd';
  static const String saladBowl = '1546069901-ba9599a7e63c';
  static const String indianSnack = '1585032226651-759b368d7246';
  static const String indianCurry = '1476224203421-9ac39bcb3327';
  static const String paneer = '1606491956689-2ea866880c84';
  static const String streetFood = '1626074353765-517a681e40be';
  static const String biryani = '1601050690597-df0568f70950';
  static const String noodles = '1563379091339-03b21ab4a4f8';
  static const String noodlesAlt = '1604908176997-125f25cc6f3d';
  static const String dosa = '1630383249896-424e482df921';
  static const String roll = '1626804475297-41608ea09aeb';
  static const String pasta = '1621996346565-e3dbc646d9a9';
  static const String coffee = '1495474472287-4d71bcdd2085';
  static const String coffeeAlt = '1509042239860-f550ce710b93';
  static const String dessert = '1551024506-0bccd828d307';
  static const String dessertAlt = '1488477181946-6428a0291777';
  static const String pancakes = '1567620905732-2d1ec7ab7445';
  static const String platedFood = '1504674900247-0877df9cc836';
  static const String diner = '1414235077428-338989a2e8c0';
  static const String restaurantRoom = '1552566626-52f8b828add9';
}
