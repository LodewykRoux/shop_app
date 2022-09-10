import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavourites;
  const ProductsGrid({super.key, required this.showFavourites});

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final productItems =
        showFavourites ? productData.favouriteItems : productData.items;
    return Expanded(
      child: GridView.builder(
        itemCount: productItems.length,
        padding: const EdgeInsets.all(10.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20),
        itemBuilder: (context, index) => ChangeNotifierProvider.value(
          value: productItems[index],
          child: const ProductItem(),
        ),
      ),
    );
  }
}
