class SpRePrintRequest {
  String? orderId;
  String? itemId;
  String? deviceId;
  String? retailerId;
  String? retailerToken;
  String? domainName;



  SpRePrintRequest(
      {this.orderId, this.itemId, this.deviceId, this.retailerId, this.retailerToken, this.domainName});

  SpRePrintRequest.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    itemId = json['itemId'];
    deviceId = json['deviceId'];
    retailerId = json['retailerId'];
    retailerToken = json['retailerToken'];
    domainName = json['domainName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['orderId'] = this.orderId;
    data['itemId'] = this.itemId;
    data['deviceId'] = this.deviceId;
    data['retailerId'] = this.retailerId;
    data['retailerToken'] = this.retailerToken;
    data['domainName'] = this.domainName;
    return data;
  }
}
