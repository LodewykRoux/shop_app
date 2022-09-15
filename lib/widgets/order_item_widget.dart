import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/models/order_item.dart';
import 'dart:math';

class OrderItemWidget extends StatefulWidget {
  final OrderItem order;
  const OrderItemWidget({
    super.key,
    required this.order,
  });

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.orderTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.products.length * 20.0 + 10.0, 180.0),
              child: ListView(
                  children: widget.order.products
                      .map((e) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.title,
                              ),
                              Text('${e.quantity}x \$${e.price}')
                            ],
                          ))
                      .toList()),
            ),
        ],
      ),
    );
  }
}
