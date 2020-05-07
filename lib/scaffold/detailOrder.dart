import 'package:flutter/material.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/utility/my_style.dart';

class DetailOrder extends StatefulWidget {
  final OrderUserModel orderUserModel;
  final String nameShop;
  final int distance;
  final int transport;
  DetailOrder(
      {Key key,
      this.orderUserModel,
      this.nameShop,
      this.distance,
      this.transport})
      : super(key: key);
  @override
  _DetailOrderState createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  // Field
  OrderUserModel orderUserModel;
  String nameShop;
  int distance, transport;

  @override
  void initState() {
    super.initState();
    setState(() {
      orderUserModel = widget.orderUserModel;
      nameShop = widget.nameShop;
      distance = widget.distance;
      transport = widget.transport;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการอาหาร $nameShop'),
      ),
      body: ListView(
        children: <Widget>[
          showTitleNameShop(),
          showListOrder(),
        ],
      ),
    );
  }

  Widget showListOrder() => ListView.builder(itemBuilder: (value, index)=>Text('Text'));

  Widget showTitleNameShop() => MyStyle().showTitle(nameShop);
}
