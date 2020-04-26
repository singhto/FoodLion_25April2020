import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';

class MyAPI {
  Future<String> findNameShopWhere(String idShop) async {
    String string = 'aaa';
    String url =
        'http://movehubs.com/app/getShopWhereId.php?isAdd=true&id=$idShop';
    Response response = await Dio().get(url);
    print('res find ==> $response');
    var result = json.decode(response.data);
    for (var map in result) {
      string = map['Name'];
    }
    return string;
  }

  double calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));

    return distance;
  }

  MyAPI();
}
