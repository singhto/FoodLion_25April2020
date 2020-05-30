import 'package:flutter/material.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoShop extends StatefulWidget {
  @override
  _InfoShopState createState() => _InfoShopState();
}

class _InfoShopState extends State<InfoShop> {
  UserShopModel userShopModel;
  List<Widget> showWidgets = List();

  @override
  void initState() {
    super.initState();
    findShop();
  }

  Widget showShop() {
    return showWidgets.length == 0
        ? MyStyle().showProgress()
        : Expanded(
            child: GridView.extent(
              mainAxisSpacing: 3.0,
              crossAxisSpacing: 3.0,
              maxCrossAxisExtent: 160.0,
              children: showWidgets,
            ),
          );
  }
    Widget floatingAction = FloatingActionButton(
      backgroundColor: Colors.yellow.shade700,
      onPressed: () async {},
      child: Icon(Icons.add),
    );

  Future<Null> findShop() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop = $idShop');

    try {
      var object = await MyAPI().findDetailShopWhereId(idShop);
      setState(() {
        userShopModel = object;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              child: userShopModel == null
                  ? MyStyle().showProgress()
                  : Image.network(userShopModel.urlShop),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text('ร้าน อ.มัลลิการ์ เปิดดำเนินการครั้งแรกเมื่อวันที่ 15 พฤศจิกายน 2537 โดยเปิดสาขาแรกที่ถนน แจ้งวัฒนะ ซึ่งร้านนี้นอกจากจะเป็นร้านอาหาร ไทยที่สามารถรองรับลูกค้าได้มากกว่า 120 ท่าน มีเมนูอร่อยให้ลูกค้า เลือกไม่น้อยกว่า 300 รายการแล้ว อ.มัลลิการ์ ยังตกแต่งให้เป็นร้านที่มี บรรยากาศสบายๆมีพันธุ์ไม้ดอกไม้ใบของไทยที่ให้ร่มเงาและ ...'),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('ผู้บริหารร้าน'),
                    subtitle: Text('คุณองอาจ อาหารอร่อย'),
                    trailing: Icon(Icons.edit),
                    onTap: () {},
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('เวลา เปิด-ปิดร้าน'),
                    subtitle: Text('เปิด จันทร์-เสาร์ เวลา 9.00-15.00 น.'),
                    trailing: Icon(Icons.edit),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.note),
                    title: Text('สตอรี่'),
                    subtitle: Text('เรื่องราว ประวัติความเป็นมา'),
                    trailing: Icon(Icons.edit),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.motorcycle),
                    title: Text('ตั้งค่าการจัดส่ง'),
                    subtitle: Text('จัดส่งเอง หรือ ใช้ Send'),
                    trailing: Icon(Icons.edit),
                    onTap: () {},
                  ),
                  
                ],
              ),
            ),
            
          ],
        ),
        
      ],

    );
  }
}
