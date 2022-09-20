import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final Product product;
  const UserProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          product.imageUrl,
        ),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProductScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
