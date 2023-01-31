import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/exceptions/http_exception.dart';
import 'package:shop_app/models/product.dart';
import 'package:http/http.dart' as http;

class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  // final List<Product> _items = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cosy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((i) => i.isFavourite).toList();
  }

  Future<void> getList() async {
    try {
      final response = await http.get(Constants.url);
      print(jsonDecode(response.body));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      Product newProduct = product.copyWith(
        id: DateTime.now().toString(),
      );
      http.Response result = await http.post(
        Constants.url,
        body: json.encode(
          newProduct.toJson(),
        ),
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    int existingProduct = _items.indexWhere((i) => i.id == product.id);
    if (existingProduct >= 0) {
      await http.patch(
        Uri.https(
          'shopapp-d572e-default-rtdb.europe-west1.firebasedatabase.app',
          '/products/${product.id}.json',
        ),
        body: json.encode(
          product.toJson(),
        ),
      );
    }
    _items[existingProduct] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(Product product) async {
    int existingProduct = _items.indexWhere((i) => i.id == product.id);
    if (existingProduct >= 0) {
      _items.removeAt(existingProduct);
      await http
          .delete(
        Uri.https(
          'shopapp-d572e-default-rtdb.europe-west1.firebasedatabase.app',
          '/products/${product.id}.json',
        ),
      )
          .then((response) {
        if (response.statusCode >= 400) {
          throw HttpException('Could not delete product.');
        }
      }).catchError((_) {
        _items.insert(existingProduct, product);
      });
    }
    notifyListeners();
  }

  Product findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final response = await http.get(Constants.url);
      final Map<String, dynamic>? extractedData =
          json.decode(response.body) as Map<String, dynamic>?;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavourite: prodData['isFavourite'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
