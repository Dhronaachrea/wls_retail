class DepositRequest {
  String? aliasName;
  String? deviceType;
  String? appType;
  int? couponCount;
  String? responseType;
  String? retailerName;
  String? amount;
  String? gameCode;
  String? serviceCode;
  String? providerCode;
  String? userName;

  DepositRequest(
      {this.aliasName,
        this.deviceType,
        this.appType,
        this.couponCount,
        this.responseType,
        this.retailerName,
        this.amount,
        this.gameCode,
        this.serviceCode,
        this.providerCode,
        this.userName
      });

  DepositRequest.fromJson(Map<String, dynamic> json) {
    aliasName = json['aliasName'];
    deviceType = json['deviceType'];
    appType = json['appType'];
    couponCount = json['couponCount'];
    responseType = json['responseType'];
    retailerName = json['retailerName'];
    amount = json['amount'];
    gameCode = json['gameCode'];
    serviceCode = json['serviceCode'];
    providerCode = json['providerCode'];
    if(json['userName']!=null && json['userName'].toString().isNotEmpty) {
      userName = json['userName'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['aliasName'] = this.aliasName;
    data['deviceType'] = this.deviceType;
    data['appType'] = this.appType;
    data['couponCount'] = this.couponCount;
    data['responseType'] = this.responseType;
    data['retailerName'] = this.retailerName;
    data['amount'] = this.amount;
    data['gameCode'] = this.gameCode;
    data['serviceCode'] = this.serviceCode;
    data['providerCode'] = this.providerCode;
    if(this.userName!=null && this.userName.toString().isNotEmpty){
      data['userName'] = this.userName;
    }
    return data;
  }
}
