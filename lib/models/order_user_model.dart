class OrderUserModel {
  String id;
  String idUser;
  String idShop;
  String dateTime;
  String idFoods;
  String amountFoods;
  String idDelivery;
  String success;

  OrderUserModel(
      {this.id,
      this.idUser,
      this.idShop,
      this.dateTime,
      this.idFoods,
      this.amountFoods,
      this.idDelivery,
      this.success});

  OrderUserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idUser = json['idUser'];
    idShop = json['idShop'];
    dateTime = json['DateTime'];
    idFoods = json['idFoods'];
    amountFoods = json['amountFoods'];
    idDelivery = json['idDelivery'];
    success = json['Success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idUser'] = this.idUser;
    data['idShop'] = this.idShop;
    data['DateTime'] = this.dateTime;
    data['idFoods'] = this.idFoods;
    data['amountFoods'] = this.amountFoods;
    data['idDelivery'] = this.idDelivery;
    data['Success'] = this.success;
    return data;
  }
}

