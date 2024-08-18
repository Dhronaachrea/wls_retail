class UpdateQrWithdrawalRequest {
  String? requestId;
  String? amount;
  String? verificationCode;
  String? retailerId;
  String? device;
  String? appType;

  UpdateQrWithdrawalRequest(
      {this.requestId, this.amount,this.retailerId,this.device,this.appType, this.verificationCode});

  UpdateQrWithdrawalRequest.fromJson(Map<String, dynamic> json) {
    requestId = json['requestId'];
    amount = json['amount'];
    device = json['device'];
    appType = json['appType'];
    retailerId = json['retailerId'];
    verificationCode = json['verificationCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['requestId'] = this.requestId;
    data['amount'] = this.amount;
    data['device'] = this.device;
    data['appType'] = this.appType;
    data['retailerId'] = this.retailerId;
    data['verificationCode'] = this.verificationCode;
    return data;
  }
}
