import 'product.dart';

class BillItem {
  final Product product;
  final int quantity;

  BillItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.totalPrice * quantity;
  double get totalCGST => product.cgst * quantity;
  double get totalSGST => product.sgst * quantity;
  double get subtotal => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      product: Product.fromMap(map['product']),
      quantity: map['quantity'],
    );
  }
}

class Bill {
  final String id;
  final DateTime dateTime;
  final List<BillItem> items;

  Bill({
    required this.id,
    required this.dateTime,
    required this.items,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get totalCGST => items.fold(0, (sum, item) => sum + item.totalCGST);
  double get totalSGST => items.fold(0, (sum, item) => sum + item.totalSGST);
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      dateTime: DateTime.parse(map['dateTime']),
      items:
          (map['items'] as List).map((item) => BillItem.fromMap(item)).toList(),
    );
  }
}
