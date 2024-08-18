class PendingWithdrawalResponse {
  int? errorCode;
  String? errorMsg;
  List<Data>? data;

  PendingWithdrawalResponse({this.errorCode, this.errorMsg, this.data});

  PendingWithdrawalResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['errorCode'];
    errorMsg = json['errorMsg'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errorCode'] = this.errorCode;
    data['errorMsg'] = this.errorMsg;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? createdAt;
  String? netAmount;
  String? requestId;

  Data({this.createdAt, this.netAmount, this.requestId});

  Data.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    netAmount = json['netAmount'];
    requestId = json['requestId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['netAmount'] = this.netAmount;
    data['requestId'] = this.requestId;
    return data;
  }
}
