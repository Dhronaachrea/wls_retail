class RePrintQrCodeResponse {
  String? errorMessage;
  int? errorCode;
  Data? data;
  int? responseCode;

  RePrintQrCodeResponse(
      {this.errorMessage, this.errorCode, this.data, this.responseCode});

  RePrintQrCodeResponse.fromJson(Map<String, dynamic> json) {
    errorMessage = json['errorMessage'];
    errorCode = json['errorCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    responseCode = json['responseCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errorMessage'] = this.errorMessage;
    data['errorCode'] = this.errorCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['responseCode'] = this.responseCode;
    return data;
  }
}

class Data {
  String? qrCount;
  String? qrCodeUrl;
  String? merchantPlayerId;
  String? playerId;

  Data({this.qrCount, this.qrCodeUrl, this.merchantPlayerId, this.playerId});

  Data.fromJson(Map<String, dynamic> json) {
    qrCount = json['qrCount'];
    qrCodeUrl = json['qrCodeUrl'];
    merchantPlayerId = json['merchantPlayerId'];
    playerId = json['playerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['qrCount'] = this.qrCount;
    data['qrCodeUrl'] = this.qrCodeUrl;
    data['merchantPlayerId'] = this.merchantPlayerId;
    data['playerId'] = this.playerId;
    return data;
  }
}
