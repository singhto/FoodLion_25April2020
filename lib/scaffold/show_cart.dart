import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/order_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:foodlion/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowCart extends StatefulWidget {
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  // Filed
  List<OrderModel> orderModels = List();
  List<String> nameShops = List();
  int totalPrice = 0, totalDelivery = 0, sumTotal = 0;
  List<int> transports = List();
  List<int> distances = List();
  List<int> sumTotals = List();
  double latUser, lngUser;
  UserModel userModel;
  UserShopModel userShopModel;
  List<UserShopModel> userShopModels = List();
  List<int> idShopOnSQLites = List();

  // Method
  @override
  void initState() {
    super.initState();
    findLocationUser();
  }

  Future<void> findLocationUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    print('idUser = $idUser');

    String url =
        'http://movehubs.com/app/getUserWhereId.php?isAdd=true&id=$idUser';
    Response response = await Dio().get(url);
    var result = json.decode(response.data);
    for (var map in result) {
      // print('map ==> $map');
      userModel = UserModel.fromJson(map);
      readSQLite();
    }
  }

  Future<void> readSQLite() async {
    if (orderModels.length != 0) {
      orderModels.clear();
      totalPrice = 0;
      totalDelivery = 0;
      sumTotal = 0;
    }

    try {
      var object = await SQLiteHelper().readDatabase();
      // print("object length ==>> ${object.length}");
      if (object.length != 0) {
        orderModels = object;

        for (var model in orderModels) {
          totalPrice = totalPrice +
              (int.parse(model.priceFood) * int.parse(model.amountFood));
          findLatLngShop(model);
          sumTotal = totalPrice;
        }
      }
    } catch (e) {
      print('e readSQLite ==>> ${e.toString()}');
    }
  }

  Future<void> findLatLngShop(OrderModel orderModel) async {
    Map<String, dynamic> map = Map();
    map = await MyAPI().findLocationShopWhere(orderModel.idShop);
    // print('map =====>>>>>>> ${map.toString()}');

    setState(() {
      userShopModel = UserShopModel.fromJson(map);
      userShopModels.add(userShopModel);

      double lat1 = double.parse(userModel.lat);
      double lng1 = double.parse(userModel.lng);
      double lat2 = double.parse(userShopModel.lat);
      double lng2 = double.parse(userShopModel.lng);

      // List<double> location1 = [13.673452, 100.606735];
      // List<double> location2 = [13.665821, 100.644286];

      int indexOld = 0;
      // int indexLocation = 0;

      int index = int.parse(orderModel.idShop);
      if (checkMemberIdShop(index)) {
        idShopOnSQLites.add(int.parse(orderModel.idShop));
        indexOld = index;
        print('Work indexOld ===>>> $indexOld');

        double distance = MyAPI().calculateDistance(lat1, lng1, lat2, lng2);
        // print('distance ==>>>>> $distance');

        int distanceAint = distance.toInt();
        // print('distanceAint = $distanceAint');
        distances.add(distanceAint);

        int transport = checkTransport(distanceAint);
        print('transport ===>>> $transport');
        transports.add(transport);
        sumTotals.add(transport);
        totalDelivery = totalDelivery + transport;
        sumTotal = sumTotal + totalDelivery;
      } else {
        transports.add(0);
        distances.add(0);
      }
    });
  }

  bool checkMemberIdShop(int idShop) {
    bool result = true;
    for (var member in idShopOnSQLites) {
      if (member == idShop) {
        result = false;
        return result;
      }
    }
    return result;
  }

  int checkTransport(int distance) {
    int transport = 0;
    if (distance <= 5) {
      transport = distance * 25;
      return transport;
    } else {
      transport = 125 + ((distance - 5) * 5);
      return transport;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตะกร้า'),
      ),
      body: orderModels.length == 0
          ? Center(
              child: Text(
                'ยังไม่มี รายการอาหาร คะ',
                style: MyStyle().h1PrimaryStyle,
              ),
            )
          : showContent(),
    );
  }

  Column showContent() {
    return Column(
      children: <Widget>[
        showListCart(),
        showBottom(),
        orderButton(),
      ],
    );
  }

  Widget orderButton() => Container(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton.icon(
          color: MyStyle().primaryColor,
          onPressed: () {
            confirmDialog(
                context, 'Confirm Order', 'กรุณา Confirm Order ด้วย คะ');
          },
          icon: Icon(
            Icons.check_box,
            color: Colors.white,
          ),
          label: Text(
            'สั่งซื่อ',
            style: MyStyle().hiStyleWhite,
          ),
        ),
      );

  Future<void> confirmDialog(BuildContext context, String title, String message,
      {Icon icon}) async {
    if (icon == null) {
      icon = Icon(
        Icons.question_answer,
        size: 36,
        color: MyStyle().dartColor,
      );
    }
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: showTitle(title, icon),
        content: Text(
          message,
          style: MyStyle().h2StylePrimary,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              orderThread();
              Navigator.of(context).pop();
            },
            child: Text(
              'Confirm',
              style: MyStyle().h2Style,
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: MyStyle().h2Style,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> orderThread()async{
    print('orderModels.length ===>>> ${orderModels.length}');
  }

  Widget showSum(String title, String message, Color color) {
    return Container(
      decoration: BoxDecoration(color: color),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Text(
            title,
            style: MyStyle().hiStyleWhite,
          ),
          Text(
            message,
            style: MyStyle().hiStyleWhite,
          ),
        ],
      ),
    );
  }

  Widget showBottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            children: <Widget>[
              showSum(
                  'ค่าขอส่ง', totalDelivery.toString(), MyStyle().lightColor),
              showSum(
                  'ค่าอาหาร', totalPrice.toString(), MyStyle().primaryColor),
              showSum('รวมราคา', sumTotal.toString(), MyStyle().dartColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget showListCart() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
        child: Column(
          children: <Widget>[
            headTitle(),
            Divider(
              color: MyStyle().dartColor,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: orderModels.length,
                  itemBuilder: (value, index) => Container(
                        decoration: BoxDecoration(
                            color: index % 2 == 0
                                ? Colors.grey.shade300
                                : Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          orderModels[index].nameFood,
                                          style: MyStyle().h2NormalStyle,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          orderModels[index].nameShop,
                                          style: MyStyle().h3StylePrimary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                orderModels[index].priceFood,
                                style: MyStyle().h2NormalStyle,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    orderModels[index].amountFood,
                                    style: MyStyle().h2NormalStyle,
                                  ),
                                  Text(
                                    '${distances[index].toString()} km',
                                    style: MyStyle().h3StylePrimary,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    calculateTotal(orderModels[index].priceFood,
                                        orderModels[index].amountFood),
                                    style: MyStyle().h2NormalStyle,
                                  ),
                                  Text(
                                    transports[index].toString(),
                                    style: MyStyle().h3StylePrimary,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: MyStyle().dartColor,
                                      ),
                                      onPressed: () {
                                        confirmAnDelete(orderModels[index]);
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmAnDelete(OrderModel model) async {
    print('id delete ==>>> ${model.id}');
    showDialog(
      context: context,
      builder: (value) => AlertDialog(
        title: Text('ยื่นยันการลบรายการอาหาร'),
        content: Text('คุณต้องการลบ ${model.nameFood} นี่จริงๆ นะคะ'),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
              processDelete(model.id);
            },
            child: Text('ยืนยันลบ'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('ไม่ลบรายการอาหาร'),
          ),
        ],
      ),
    );
  }

  Future<void> processDelete(int id) async {
    await SQLiteHelper().deleteSQLiteWhereId(id).then((value) {
      setState(() {
        readSQLite();
      });
    });
  }

  String calculateTotal(String price, String amount) {
    int princtInt = int.parse(price);
    int amountInt = int.parse(amount);
    int total = princtInt * amountInt;

    return total.toString();
  }

  Row headTitle() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            'รายการอาหาร',
            style: MyStyle().h2Style,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'ราคา',
            style: MyStyle().h2Style,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'จำนวน',
            style: MyStyle().h2Style,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'รวม',
            style: MyStyle().h2Style,
          ),
        ),
      ],
    );
  }
}
