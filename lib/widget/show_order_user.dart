import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowOrderUser extends StatefulWidget {
  @override
  _ShowOrderUserState createState() => _ShowOrderUserState();
}

class _ShowOrderUserState extends State<ShowOrderUser> {
  // Field
  bool status;
  Widget currentWidget;
  List<OrderUserModel> orderUserModels = List();
  List<String> nameShops = List();
  List<List<FoodModel>> listFoodModels = List();
  List<List<String>> listAmounts = List();

  // Method
  @override
  void initState() {
    super.initState();
    readOrder();
  }

  Future<void> readOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');

    String url =
        'http://movehubs.com/app/getOrderWhereIdUserStatus.php?isAdd=true&idUser=$idUser&Success=0';
    Response response = await Dio().get(url);
    // print('res ===>> $response');

    if (response.toString() == 'null') {
      setState(() {
        currentWidget = Center(
          child: Text(
            'ไม่มี รายการอาหาร ที่รอส่ง คะ',
            style: MyStyle().h1PrimaryStyle,
          ),
        );
      });
    } else {
      var result = json.decode(response.data);
      for (var map in result) {
        OrderUserModel orderUserModel = OrderUserModel.fromJson(map);

        // print('amount = ${orderUserModel.amountFoods.toString()}');
        String amountString = orderUserModel.amountFoods;
        amountString = amountString.substring(1, (amountString.length - 1));
        print('amountString ==> $amountString');
        List<String> amounts = amountString.split(',');
        // amounts.add(amountString);

        int j = 0;
        for (var string in amounts) {
          amounts[j] = string.trim();
          j++;
        }
        print('amounts ==>> ${amounts.toString()}');

        int k = 0;
        for (var string in amounts) {
          print('amounts[$k] = $string');
          k++;
        }

        String idFoodString = orderUserModel.idFoods;
        // print('idFoodString1 $idFoodString');
        idFoodString = idFoodString.substring(1, (idFoodString.length - 1));
        List<String> idFoods = idFoodString.split(',');

        int i = 0;
        for (var string in idFoods) {
          idFoods[i] = string.trim();
          i++;
        }

        // print('idFoods ===>> ${idFoods.toString()}');
        List<FoodModel> foodModels = List();
        for (var idFood in idFoods) {
          // print('idFood = $idFood');
          FoodModel foodModel = await MyAPI().findDetailFoodWhereId(idFood);
          // print('nameFood = ${foodModel.nameFood}');
          foodModels.add(foodModel);
        }

        String nameShop =
            await MyAPI().findNameShopWhere(orderUserModel.idShop);
        setState(() {
          listAmounts.add(amounts);
          listFoodModels.add(foodModels);
          nameShops.add(nameShop);
          orderUserModels.add(orderUserModel);
          currentWidget = showContent();
        });
      }
    }
  }

  Widget showContent() => ListView.builder(
        itemCount: orderUserModels.length,
        itemBuilder: (value, index) => Column(
          children: <Widget>[
            showShop(index),
            showDateTime(index),
            headTitle(),
            showListViewOrder(index),
          ],
        ),
      );

  Widget headTitle() => Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              'รายการอาหาร',
              style: MyStyle().h3StyleDark,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'ราคา',
              style: MyStyle().h3StyleDark,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'จำนวน',
              style: MyStyle().h3StyleDark,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'รวม',
              style: MyStyle().h3StyleDark,
            ),
          ),
        ],
      );

  Widget showListViewOrder(int index) => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: listFoodModels[index].length,
        itemBuilder: (value, index2) => Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Text(listFoodModels[index][index2].nameFood),
            ),
            Expanded(
              flex: 1,
              child: Text(listFoodModels[index][index2].priceFood),
            ),
            Expanded(
              flex: 1,
              child: Text(listAmounts[index][index2]),
            ),
            Expanded(
              flex: 1,
              child: Text(
                  '${(int.parse(listFoodModels[index][index2].priceFood)) * (int.parse(listAmounts[index][index2]))}'),
            ),
          ],
        ),
      );

  Widget showDateTime(int index) =>
      MyStyle().showTitleH2Primary(orderUserModels[index].dateTime);

  Widget showShop(int index) => MyStyle().showTitle('ร้าน ${nameShops[index]}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายการสั่งอาหาร'),),
      body: currentWidget == null ? MyStyle().showProgress() : currentWidget,
    );
  }
}
