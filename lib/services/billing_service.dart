import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/bill.dart';

class BillingService {
  static const String _productsKey = 'products';
  static const String _billsKey = 'bills';
  final SharedPreferences _prefs;

  BillingService(this._prefs);

  // Product Management
  Future<List<Product>> getProducts() async {
    final String? productsJson = _prefs.getString(_productsKey);
    if (productsJson == null) return [];

    final List<dynamic> decoded = json.decode(productsJson);
    return decoded.map((item) => Product.fromMap(item)).toList();
  }

  Future<void> saveProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await _prefs.setString(
        _productsKey, json.encode(products.map((p) => p.toMap()).toList()));
  }

  // Bill Management
  Future<List<Bill>> getBills() async {
    final String? billsJson = _prefs.getString(_billsKey);
    if (billsJson == null) return [];

    final List<dynamic> decoded = json.decode(billsJson);
    return decoded.map((item) => Bill.fromMap(item)).toList();
  }

  Future<void> saveBill(Bill bill) async {
    final bills = await getBills();
    bills.add(bill);
    await _prefs.setString(
        _billsKey, json.encode(bills.map((b) => b.toMap()).toList()));
  }

  Future<void> clearAllData() async {
    await _prefs.remove(_productsKey);
    await _prefs.remove(_billsKey);
  }
}
