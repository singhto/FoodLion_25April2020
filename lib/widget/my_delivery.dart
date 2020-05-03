import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/utility/my_style.dart';

class MyDelivery extends StatefulWidget {
  @override
  _MyDeliveryState createState() => _MyDeliveryState();
}

class _MyDeliveryState extends State<MyDelivery> {
  // Field
  List<OrderUserModel> orderUserModels = List();

  // Method
  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<void> readOrder() async {
    String url = 'http://movehubs.com/app/getOrderWhereStatus0.php?isAdd=true';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    // print('result ===>> $result');
    for (var map in result) {
      // print('map ==>> $map');
      OrderUserModel orderUserModel = OrderUserModel.fromJson(map);
      setState(() {
        orderUserModels.add(orderUserModel);
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return orderUserModels.length == 0
        ? showNoOrder()
        : showContent();
  }

  ListView showContent() {
    return ListView.builder(
          itemCount: orderUserModels.length,
          itemBuilder: (value, index) => Text(orderUserModels[index].idShop),
        );
  }

  Center showNoOrder() {
    return Center(
      child: Text(
        'ยังไม่มี ใครสั่งอาหารเลย คะ',
        style: MyStyle().h1PrimaryStyle,
      ),
    );
  }
}
