class UserShopModel {
  String id;
  String name;
  String user;
  String password;
  String urlShop;
  String lat;
  String lng;
  String token;
  String check;

  UserShopModel(
      {this.id,
      this.name,
      this.user,
      this.password,
      this.urlShop,
      this.lat,
      this.lng,
      this.token,
      this.check});

  UserShopModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['Name'];
    user = json['User'];
    password = json['Password'];
    urlShop = json['UrlShop'];
    lat = json['Lat'];
    lng = json['Lng'];
    token = json['Token'];
    check = json['Check'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['Name'] = this.name;
    data['User'] = this.user;
    data['Password'] = this.password;
    data['UrlShop'] = this.urlShop;
    data['Lat'] = this.lat;
    data['Lng'] = this.lng;
    data['Token'] = this.token;
    data['Check'] = this.check;
    return data;
  }
}

