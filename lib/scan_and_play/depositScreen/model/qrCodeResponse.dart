class QrCodeResponse {
  String? errorMessage;
  int? errorCode;
  String? data;
  int? responseCode;

  QrCodeResponse(
      {this.errorMessage, this.errorCode, this.data, this.responseCode});

  QrCodeResponse.fromJson(Map<String, dynamic> json) {
    errorMessage = json['errorMessage'];
    errorCode = json['errorCode'];
    data = json['data'];
    responseCode = json['responseCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errorMessage'] = this.errorMessage;
    data['errorCode'] = this.errorCode;
    data['data'] = this.data;
    data['responseCode'] = this.responseCode;
    return data;
  }
}
