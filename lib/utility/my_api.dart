import 'dart:convert';

import 'package:dio/dio.dart';

class MyAPI {

  Future<String> findNameShopWhere(String idShop)async{
    String string = 'aaa';
    String url = 'http://movehubs.com/app/getShopWhereId.php?isAdd=true&id=$idShop';
    Response response = await Dio().get(url);
    print('res find ==> $response');
    var result = json.decode(response.data);
    for (var map in result) {
      string = map['Name'];
      
    }
    return string;
  }



  MyAPI();
  
}