import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/widgets/product_grid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  ProductsOverviewScreen({Key? key}) : super(key: key);


  final List<Map> _products = List.generate(
      100,
      (index) => {
            "id": index,
            "name": "Product $index",
            "price": Random().nextInt(100)
          }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProductsGrid(),
        ],
      ),
    );
  }
}
