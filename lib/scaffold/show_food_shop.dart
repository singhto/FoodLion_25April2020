import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodlion/models/food_model.dart';
import 'package:foodlion/utility/my_constant.dart';
import 'package:foodlion/utility/my_style.dart';
import 'package:foodlion/utility/normal_dialog.dart';
import 'package:image_picker/image_picker.dart';

class ShowFoodShop extends StatefulWidget {
  final FoodModel foodModel;
  ShowFoodShop({Key key, this.foodModel});
  @override
  _ShowFoodShopState createState() => _ShowFoodShopState();
}

class _ShowFoodShopState extends State<ShowFoodShop> {
  // Field
  FoodModel foodModel;
  int amountFood = 1;
  String id, idFood, nameFood, urlFood, priceFood, detailFood;
  File file;

  // Method
  @override
  void initState() {
    super.initState();
    foodModel = widget.foodModel;
    id = foodModel.id;
    idFood = foodModel.id;
    nameFood = foodModel.nameFood;
    urlFood = foodModel.urlFood;
    priceFood = foodModel.priceFood;
    detailFood = foodModel.detailFood;
  }

  Widget showName() {
    return Container(
      width: 250.0,
      child: TextFormField(
        onChanged: (value) => nameFood = value.trim(),
        style: MyStyle().h2Style,
        initialValue: foodModel.nameFood,
        decoration: InputDecoration(
          labelText: 'ชื่อรายการอาหาร',
          labelStyle: MyStyle().h3StylePrimary,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().primaryColor)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().dartColor)),
        ),
      ),
    );
  }

  Widget showImage() => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.add_a_photo,
                  size: 36.0,
                  color: MyStyle().dartColor,
                ),
                onPressed: () => chooseImage(ImageSource.camera)),
            Container(
              width: 250,
              child: showChooseImage(),
            ),
            IconButton(
                icon: Icon(
                  Icons.add_photo_alternate,
                  size: 36.0,
                  color: MyStyle().dartColor,
                ),
                onPressed: () => chooseImage(ImageSource.gallery)),
          ],
        ),
      );

  Widget showChooseImage() {
    return file == null
        ? CachedNetworkImage(
            imageUrl: foodModel.urlFood,
            placeholder: (value, string) => MyStyle().showProgress(),
          )
        : Image.file(file);
  }

  Future<void> chooseImage(ImageSource source) async {
    try {
      var response = await ImagePicker.pickImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );
      setState(() {
        file = response;
      });
    } catch (e) {}
  }

  Widget showDetail() {
    return Container(
      width: 250.0,
      child: TextFormField(
        onChanged: (value) => detailFood = value.trim(),
        style: MyStyle().h2Style,
        initialValue: foodModel.detailFood,
        decoration: InputDecoration(
          labelText: 'รายละเอียด',
          labelStyle: MyStyle().h3StylePrimary,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().primaryColor)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().dartColor)),
        ),
      ),
    );
  }

  Widget showPrice() {
    return Row(
      children: <Widget>[
        MyStyle().showTitle('ราคา :'),
        priceForm(),
      ],
    );
  }

  Widget priceForm() {
    return Container(
      width: 150.0,
      child: TextFormField(
        keyboardType: TextInputType.number,
        onChanged: (value) => priceFood = value.trim(),
        style: MyStyle().h2Style,
        initialValue: foodModel.priceFood,
        decoration: InputDecoration(
          labelText: 'ราคาอาหาร',
          labelStyle: MyStyle().h3StylePrimary,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().primaryColor)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyStyle().dartColor)),
        ),
      ),
    );
  }

  Widget showContent() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(
          top: 50.0,
          bottom: 50.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showName(),
            MyStyle().mySizeBox(),
            showImage(),
            MyStyle().mySizeBox(),
            MyStyle().showTitle('รายละเอียด :'),
            showDetail(),
            MyStyle().mySizeBox(),
            showPrice(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('แก้ไข รายการอาหาร'),
        ),
        body: ListView(
          children: <Widget>[
            showContent(),
            saveButton(),
          ],
        ));
  }

  Widget saveButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: RaisedButton.icon(
            color: MyStyle().primaryColor,
            onPressed: () {
              if (nameFood.isEmpty || detailFood.isEmpty || priceFood.isEmpty) {
                normalDialog(context, 'มีช่องว่าง คะ', 'กรุณา กรอกทุกช่อง คะ');
              } else if (file == null) {
                insertDtaToMySQL();
              } else {
                uploadImageToServer();
              }
            },
            icon: Icon(
              Icons.cloud_upload,
              color: Colors.white,
            ),
            label: Text(
              'บันทึก',
              style: MyStyle().h2StyleWhite,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> uploadImageToServer() async {
    String url = MyConstant().urlSaveFile;
    Random random = Random();
    int i = random.nextInt(100000);
    String nameFile = 'shop$i.jpg';
    print(
        'name = $nameFood, urlImage = $urlFood , detail = $detailFood, price = $priceFood, id = $id');

    try {
      Map<String, dynamic> map = Map();

      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);
      await Dio().post(url, data: formData).then((response) {
        urlFood = '${MyConstant().urlImagePathShop}$nameFile';
        print(
            'name = $nameFood, urlImage = $urlFood , detail = $detailFood, price = $priceFood, id = $id');
        insertDtaToMySQL();
      });
    } catch (e) {}
  }

  Future<void> insertDtaToMySQL() async {
    // urlImage = '${MyConstant().urlImagePathShop}$string';

    String urlAPI =
        'http://movehubs.com/app/editFoodShopWhereId.php?isAdd=true&id=$id&NameFood=$nameFood&DetailFood=$detailFood&UrlFood=$urlFood&PriceFood=$priceFood';

    try {
      await Dio().get(urlAPI).then(
        (response) {
          if (response.toString() == 'true') {
            Navigator.of(context).pop();
          } else {
            normalDialog(context, 'Register False', 'Please Try Again');
          }
        },
      );
    } catch (e) {}
  }
}
