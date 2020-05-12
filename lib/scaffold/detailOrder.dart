import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/models/order_user_model.dart';
import 'package:foodlion/models/user_model.dart';
import 'package:foodlion/models/user_shop_model.dart';
import 'package:foodlion/utility/my_api.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  String nameShop, nameUser;
  int distance, transport, sumFood = 0;
  LatLng shopLatLng, userLatLng;
  IconData shopMarkerIcon;
  List<String> nameFoods = List();
  List<int> amounts = List();
  List<int> prices = List();
  List<int> sums = List();
  int sumPrice = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      orderUserModel = widget.orderUserModel;
      nameShop = widget.nameShop;
      distance = widget.distance;
      transport = widget.transport;
      findDetailShopAnUser();
      findOrder();
      findAmound();
      findSum();
    });
  }

  Future<Null> findSum() async {
    String idShop = orderUserModel.idShop;
    String idFoods = orderUserModel.idFoods;
    String amounes = orderUserModel.amountFoods;

    print('idShop ==> $idShop, idFoods ==> $idFoods, amounts ==> $amounes');

    List<int> amountIntFoods = changeToArray(amounes);
    List<int> idFoodInt = changeToArray(idFoods);
    // List<int> priceIntFoods = List();

    int i = 0;
    for (var idFood in idFoodInt) {
      FoodModel foodModel =
          await MyAPI().findDetailFoodWhereId(idFood.toString());

      setState(() {
        sumPrice =
            sumPrice + (int.parse(foodModel.priceFood)) * amountIntFoods[1];
        // print('sumPrice ==>> $sumPrice');
      });
      i++;
    }
  }

  List<int> changeToArray(String string) {
    List<int> list = List();
    string = string.substring(1, string.length - 1);
    List<String> listStrings = string.split(',');

    for (var string in listStrings) {
      list.add(int.parse(string.trim()));
    }
    return list;
  }

  Future<void> findAmound() async {
    String string = orderUserModel.amountFoods;
    string = string.substring(1, string.length - 1);
    List<String> strings = string.split(',');

    // int i = 0;
    for (var string in strings) {
      setState(() {
        amounts.add(int.parse(string.trim()));
      });
      // i++;
    }
  }

  Future<void> findOrder() async {
    String string = orderUserModel.idFoods;
    string = string.substring(1, string.length - 1);
    List<String> strings = string.split(',');

    for (var string in strings) {
      FoodModel foodModel = await MyAPI().findDetailFoodWhereId(string.trim());
      setState(() {
        nameFoods.add(foodModel.nameFood);
        prices.add(int.parse(foodModel.priceFood));
      });
    }
  }

  Future<void> findDetailShopAnUser() async {
    UserShopModel userShopModel =
        await MyAPI().findDetailShopWhereId(orderUserModel.idShop);

    UserModel userModel =
        await MyAPI().findDetailUserWhereId(orderUserModel.idUser);

    setState(() {
      shopLatLng = LatLng(double.parse(userShopModel.lat.trim()),
          double.parse(userShopModel.lng.trim()));

      nameUser = userModel.name;
      userLatLng = LatLng(double.parse(userModel.lat.trim()),
          double.parse(userModel.lng.trim()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: acceptJob(),
      appBar: AppBar(
        title: Text('รายการอาหาร $nameShop'),
      ),
      body: ListView(
        children: <Widget>[
          showTitleNameShop(),
          showMap(shopLatLng, nameShop, 'ร้านค้าที่ไปรับอาหาร', 100.0),
          MyStyle().showTitle('รายการอาหารที่สั่ง'),
          showListOrder(),
          showSumFood(),
          showSumDistance(),
          showNameUser(),
          showMap(userLatLng, nameUser, 'สถานที่ส่งอาหาร', 310.0),
        ],
      ),
    );
  }

  FloatingActionButton acceptJob() => FloatingActionButton(
        child: Icon(Icons.directions_bike),
        backgroundColor: MyStyle().primaryColor,
        onPressed: () {},
      );

  Widget showSumFood() => Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'ผลรวมอาหาร   ',
                  style: MyStyle().h2StylePrimary,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(right: 5.0),
              decoration: BoxDecoration(color: MyStyle().primaryColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$sumPrice บาท',
                    style: MyStyle().h2StyleWhite,
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget showSumDistance() => Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'ผลรวมระยะทาง และ ค่าขนส่ง   ',
                  style: MyStyle().h2StylePrimary,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(margin: EdgeInsets.only(right: 5.0),
              decoration: BoxDecoration(color: MyStyle().dartColor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '$distance กิโลเมตร',
                    style: MyStyle().h2StyleWhite,
                  ),
                  Text(
                    '$transport บาท',
                    style: MyStyle().h2StyleWhite,
                  )
                ],
              ),
            ),
          ),
        ],
      );

  Widget showNameUser() {
    return nameUser == null
        ? MyStyle().showTitle('ผู้สั่งอาหาร ')
        : MyStyle().showTitle('ผู้สั่งอาหาร $nameUser');
  }

  Set<Marker> createMarker(
      LatLng latLng, String title, String subTitle, double hue) {
    Random random = Random();
    int i = random.nextInt(100);
    return <Marker>[
      Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        markerId: MarkerId('id$i'),
        position: latLng,
        infoWindow: InfoWindow(
          title: title,
          snippet: subTitle,
        ),
      )
    ].toSet();
  }

  Widget showMap(LatLng latLng, String title, String subTitle, double hue) {
    CameraPosition cameraPosition;
    if (latLng != null) {
      cameraPosition = CameraPosition(
        target: latLng,
        zoom: 16,
      );
    }
    return Container(
      height: 200.0,
      child: latLng == null
          ? MyStyle().showProgress()
          : GoogleMap(
              initialCameraPosition: cameraPosition,
              onMapCreated: (controller) {},
              markers: createMarker(latLng, title, subTitle, hue),
            ),
    );
  }

  Widget showListOrder() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: nameFoods.length,
        itemBuilder: (value, index) => Container(
          padding: EdgeInsets.only(left: 16.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  nameFoods[index],
                  style: MyStyle().h3StylePrimary,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  amounts[index].toString(),
                  style: MyStyle().h3StyleDark,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  prices[index].toString(),
                  style: MyStyle().h3StyleDark,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${amounts[index] * prices[index]}',
                  style: MyStyle().h3StyleDark,
                ),
              ),
            ],
          ),
        ),
      );

  String showSumPrice(int amount, int price) {
    int sumPrice = amount * price;
    setState(() {
      sumFood = sumFood + sumPrice;
      print('sumFood = $sumFood');
    });
    return sumPrice.toString();
  }

  Widget showTitleNameShop() => MyStyle().showTitle('ร้าน $nameShop');
}
