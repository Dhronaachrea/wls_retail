class RmsResponseJsonModel {
  RmsResponse? rmsResponse;

  RmsResponseJsonModel({this.rmsResponse});

  RmsResponseJsonModel.fromJson(Map<String, dynamic> json) {
    rmsResponse = json['rmsResponse'] != null
        ? RmsResponse.fromJson(json['rmsResponse'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rmsResponse != null) {
      data['rmsResponse'] = rmsResponse!.toJson();
    }
    return data;
  }
}

class RmsResponse {
  int? responseCode;
  String? responseMessage;
  ResponseData? responseData;
  int? serialVersionUid;

  RmsResponse(
      {this.responseCode,
        this.responseMessage,
        this.responseData,
        this.serialVersionUid});

  RmsResponse.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    responseData = json['responseData'] != null
        ? ResponseData.fromJson(json['responseData'])
        : null;
    serialVersionUid = json['serialVersionUid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['responseMessage'] = responseMessage;
    if (responseData != null) {
      data['responseData'] = responseData!.toJson();
    }
    data['serialVersionUid'] = serialVersionUid;
    return data;
  }
}

class ResponseData {
  String? statusCode;
  String? message;

  ResponseData({this.statusCode, this.message});

  ResponseData.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}