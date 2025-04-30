import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/bill.dart';
import '../../models/product.dart';
import '../../services/billing_service.dart';

class NewBillTab extends StatefulWidget {
  const NewBillTab({super.key});

  @override
  State<NewBillTab> createState() => _NewBillTabState();
}

class _NewBillTabState extends State<NewBillTab> {
  final List<BillItem> _items = [];
  Product? _selectedProduct;
  final _quantityController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedProduct != null) {
      setState(() {
        _items.add(
          BillItem(
            product: _selectedProduct!,
            quantity: int.parse(_quantityController.text),
          ),
        );
        _selectedProduct = null;
        _quantityController.text = '1';
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _generateBill() async {
    if (_items.isEmpty) return;

    final bill = Bill(
      id: const Uuid().v4(),
      dateTime: DateTime.now(),
      items: List.from(_items),
    );

    await context.read<BillingService>().saveBill(bill);
    setState(() {
      _items.clear();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill generated successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Product Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        FutureBuilder<List<Product>>(
                          future: context.read<BillingService>().getProducts(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const CircularProgressIndicator();
                            }

                            // Reset selected product if it's not in the list
                            if (_selectedProduct != null &&
                                !snapshot.data!
                                    .any((p) => p.id == _selectedProduct!.id)) {
                              _selectedProduct = null;
                            }

                            return DropdownButtonFormField<String>(
                              value: _selectedProduct?.id,
                              decoration: const InputDecoration(
                                labelText: 'Select Product',
                                border: OutlineInputBorder(),
                              ),
                              items: snapshot.data!.map((product) {
                                return DropdownMenuItem(
                                  value: product.id,
                                  child: Text(
                                    '${product.name} - ₹${product.price.toStringAsFixed(2)}',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedProduct = snapshot.data!
                                        .firstWhere((p) => p.id == value);
                                  });
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _selectedProduct == null ? null : _addItem,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add to Bill'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Bill Items Card
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        padding: const EdgeInsets.all(16),
                        child: const Row(
                          children: [
                            Expanded(flex: 3, child: Text('Item')),
                            Expanded(child: Text('Qty')),
                            Expanded(child: Text('Price')),
                            Expanded(child: Text('GST')),
                            Expanded(child: Text('Total')),
                            SizedBox(width: 48), // For delete button
                          ],
                        ),
                      ),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No items added to bill'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ListTile(
                              title: Row(
                                children: [
                                  Expanded(
                                      flex: 3, child: Text(item.product.name)),
                                  Expanded(child: Text('${item.quantity}')),
                                  Expanded(
                                    child: Text(
                                        '₹${item.product.price.toStringAsFixed(2)}'),
                                  ),
                                  Expanded(
                                    child:
                                        Text('${item.product.gstPercentage}%'),
                                  ),
                                  Expanded(
                                    child: Text(
                                        '₹${item.totalPrice.toStringAsFixed(2)}'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bill Summary Card
                if (_items.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal:'),
                              Text(
                                '₹${_items.fold<double>(0, (sum, item) => sum + item.subtotal).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('CGST:'),
                              Text(
                                '₹${_items.fold<double>(0, (sum, item) => sum + item.totalCGST).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('SGST:'),
                              Text(
                                '₹${_items.fold<double>(0, (sum, item) => sum + item.totalSGST).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${_items.fold<double>(0, (sum, item) => sum + item.totalPrice).toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _generateBill,
                            icon: const Icon(Icons.receipt),
                            label: const Text('Generate Bill'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
