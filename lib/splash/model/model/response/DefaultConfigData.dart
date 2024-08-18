class DefaultDomainConfigData {
  int? responseCode;
  String? responseMessage;
  ResponseData? responseData;

  DefaultDomainConfigData(
      {this.responseCode, this.responseMessage, this.responseData});

  DefaultDomainConfigData.fromJson(Map<dynamic, dynamic> json) {
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    responseData = json['responseData'] != null
        ? new ResponseData.fromJson(json['responseData'])
        : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['responseCode'] = this.responseCode;
    data['responseMessage'] = this.responseMessage;
    if (this.responseData != null) {
      data['responseData'] = this.responseData!.toJson();
    }
    return data;
  }
}

class ResponseData {
  String? message;
  int? statusCode;
  Data? data;

  ResponseData({this.message, this.statusCode, this.data});

  ResponseData.fromJson(Map<dynamic, dynamic> json) {
    message = json['message'];
    statusCode = json['statusCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? cOUNTRYCODES;
  String? ANON_DEPOSIT_LIMIT;

  Data(
      {this.cOUNTRYCODES,
        this.ANON_DEPOSIT_LIMIT});

  Data.fromJson(Map<dynamic, dynamic> json) {
    cOUNTRYCODES = json['COUNTRY_CODES'];
    ANON_DEPOSIT_LIMIT = json['ANON_DEPOSIT_LIMIT'];
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['COUNTRY_CODES'] = this.cOUNTRYCODES;
    data['ANON_DEPOSIT_LIMIT'] = this.ANON_DEPOSIT_LIMIT;
    return data;
  }
}
