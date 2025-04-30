class Product {
  final String id;
  final String name;
  final double price;
  final double gstPercentage;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.gstPercentage,
  });

  double get cgst => (price * gstPercentage / 100) / 2;
  double get sgst => (price * gstPercentage / 100) / 2;
  double get totalPrice => price + cgst + sgst;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gstPercentage': gstPercentage,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      gstPercentage: map['gstPercentage'],
    );
  }
}
