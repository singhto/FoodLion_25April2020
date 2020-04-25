import 'package:flutter/material.dart';
import 'package:foodlion/utility/my_style.dart';

class MyDelivery extends StatefulWidget {
  @override
  _MyDeliveryState createState() => _MyDeliveryState();
}

class _MyDeliveryState extends State<MyDelivery> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'ยังไม่มี ใครสั่งอาหารเลย คะ',style: MyStyle().h1PrimaryStyle,
      ),
    );
  }
}