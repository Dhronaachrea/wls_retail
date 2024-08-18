// To parse this JSON data, do
//
//     final checkAvailabilityResponse = checkAvailabilityResponseFromJson(jsonString);

import 'dart:convert';

CheckAvailabilityResponse checkAvailabilityResponseFromJson(String str) => CheckAvailabilityResponse.fromJson(json.decode(str));

String checkAvailabilityResponseToJson(CheckAvailabilityResponse data) => json.encode(data.toJson());

class CheckAvailabilityResponse {
  CheckAvailabilityResponse({
    required this.errorCode,
    required this.respMsg,
  });

  int errorCode;
  String respMsg;

  factory CheckAvailabilityResponse.fromJson(Map<String, dynamic> json) => CheckAvailabilityResponse(
    errorCode: json["errorCode"],
    respMsg: json["respMsg"],
  );

  Map<String, dynamic> toJson() => {
    "errorCode": errorCode,
    "respMsg": respMsg,
  };
}
