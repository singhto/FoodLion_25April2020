import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/scaffold/detailOrder.dart';
import 'package:foodlion/utility/find_token.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDelivery extends StatefulWidget {
  @override
  _MyDeliveryState createState() => _MyDeliveryState();
}

class _MyDeliveryState extends State<MyDelivery> {
  // Field
  List<OrderUserModel> orderUserModels = List();
  List<String> nameShops = List();
  List<int> distances = List();
  List<int> transports = List();
  String idRider;

  // Method
  @override
  void initState() {
    super.initState();
    updateToken();
    readOrder();
  }

  Future<Null> updateToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idRider = preferences.getString('id');
    String token = await findToken();

    String url =
        'http://movehubs.com/app/editTokenRiderWhereId.php?isAdd=true&id=$idRider&Token=$token';
    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      normalToast('อัพเดทตำแหน่งใหม่ สำเร็จ');
    }
  }

  Future<void> readOrder() async {
    String url = 'http://movehubs.com/app/getOrderWhereStatus0.php?isAdd=true';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    // print('result ==>> ${result.toString()}');

    for (var map in result) {
      OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

      UserModel userModel =
          await MyAPI().findDetailUserWhereId(orderUserModel.idUser);

      UserShopModel userShopModel =
          await MyAPI().findDetailShopWhereId(orderUserModel.idShop);
      String nameShop = userShopModel.name;

      double distance = MyAPI().calculateDistance(
          double.parse(userModel.lat),
          double.parse(userModel.lng),
          double.parse(userShopModel.lat),
          double.parse(userShopModel.lng));
      // print('distance ==>>> $distance');

      int distanceToInt = distance.round();
      // print('distanceToInt ==>>> $distanceToInt');

      int transport = MyAPI().checkTransport(distanceToInt);

      setState(() {
        orderUserModels.add(orderUserModel);
        nameShops.add(nameShop);
        distances.add(distanceToInt);
        transports.add(transport);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: orderUserModels.length == 0 ? showNoOrder() : showContent());
  }

  ListView showContent() {
    return ListView.builder(
      itemCount: orderUserModels.length,
      itemBuilder: (value, index) => GestureDetector(
        onTap: () => rountToDetailOrder(index),
        child: Card(
          color: index % 2 == 0 ? Colors.orange.shade100 : Colors.white,
          child: Column(
            children: <Widget>[
              MyStyle().showTitle(nameShops[index]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 16.0),
                    child: Text(
                      'ระยะทาง = ${distances[index]} กิโลเมตร',
                      style: MyStyle().h2NormalStyle,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16.0),
                    child: Text(
                      'ค่าขนส่ง = ${transports[index]} บาท',
                      style: MyStyle().h2Style,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  rountToDetailOrder(int index) {
    MaterialPageRoute route = MaterialPageRoute(
        builder: (value) => DetailOrder(
              orderUserModel: orderUserModels[index],
              nameShop: nameShops[index],
              distance: distances[index],
              transport: transports[index],
            ));
    Navigator.push(context, route);
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
