import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order_item.dart';
import 'package:http/http.dart' as http;

class OrderProvider with ChangeNotifier {
  final List<OrderItem> _orders = [];
  final String authToken;

  OrderProvider(this.authToken);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final uri = Uri.https(
      'shopapp-d572e-default-rtdb.europe-west1.firebasedatabase.app',
      '/orders.json?auth=$authToken',
    );

    final response = await http.get(uri);
    final List<OrderItem> loadedOrders = [];
    final Map<String, dynamic>? extractedData =
        json.decode(response.body) as Map<String, dynamic>?;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            orderTime: DateTime.parse(
              orderData['dateTime'],
            ),
            products: (orderData['products'] as List<dynamic>)
                .map((e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price']))
                .toList(),
          ),
        );
      },
    );
    _orders.clear();
    _orders.addAll(loadedOrders.reversed.toList());
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final uri = Uri.https(
      'shopapp-d572e-default-rtdb.europe-west1.firebasedatabase.app',
      '/orders.json',
    );
    final DateTime timeStamp = DateTime.now();
    final response = await http.post(uri,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        orderTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
