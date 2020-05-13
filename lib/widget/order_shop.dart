import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/utility/find_token.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderShop extends StatefulWidget {
  @override
  _OrderShopState createState() => _OrderShopState();
}

class _OrderShopState extends State<OrderShop> {
  // Field
  String idShop;

  // Method
  @override
  void initState() {
    super.initState();
    updateToken();
  }

  Future<Null> updateToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString('id');
    String token = await findToken();

    String url =
        'http://movehubs.com/app/editTokenShopWhereId.php?isAdd=true&id=$idShop&Token=$token';
    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      normalToast('อัพเดทตำแหน่งใหม่ สำเร็จ');
    }
  }

  Widget waitOrder() {
    return Container(
      alignment: Alignment(0, -0.6),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Card(
          color: MyStyle().primaryColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyStyle().mySizeBox(),
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Image.asset('images/wait2.png'),
              ),
              MyStyle().mySizeBox(),
              Text(
                'โปรดรอ สักครู่คะ ยังไม่มี รายการสั่ง',
                style: MyStyle().h2StyleWhite,
              ),
              MyStyle().mySizeBox(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return waitOrder();
  }
}
