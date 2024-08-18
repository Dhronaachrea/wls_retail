class PickNumberResponse {
  int? responseCode;
  String? responseMessage;
  List<String>? responseData;

  PickNumberResponse(
      {this.responseCode, this.responseMessage, this.responseData});

  PickNumberResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    responseData = json['responseData'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['responseMessage'] = this.responseMessage;
    data['responseData'] = this.responseData;
    return data;
  }
}
