class UpdateQRWithdrawalResponse {
  int? errorCode;
  String? errorMsg;
  Data? data;

  UpdateQRWithdrawalResponse({this.errorCode, this.errorMsg, this.data});

  UpdateQRWithdrawalResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMsg = json['errorMsg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errorCode'] = this.errorCode;
    data['errorMsg'] = this.errorMsg;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? userTxnId;
  double? amount;

  Data({
    this.userTxnId,
    this.amount,
  });

  Data.fromJson(Map<String, dynamic> json) {
    userTxnId = json['userTxnId'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userTxnId'] = this.userTxnId;
    data['amount'] = this.amount;

    return data;
  }
}
