// To parse this JSON data, do
//
//     final bingoSaleModel = bingoSaleModelFromJson(jsonString);

import 'dart:convert';

BingoSaleModel bingoSaleModelFromJson(String str) =>
    BingoSaleModel.fromJson(json.decode(str));

String bingoSaleModelToJson(BingoSaleModel data) => json.encode(data.toJson());

class BingoSaleModel {
  String merchantCode;
  int noOfDraws;
  String gameCode;
  String gameId;
  bool isAdvancePlay;
  bool isAdditionalDraw;
  String currencyCode;
  String purchaseDeviceId;
  String lastTicketNumber;
  String purchaseDeviceType;
  bool isUpdatedPayoutConfirmed;
  bool isPowerballPlusPlayed;
  List<DrawDatum> drawData;
  List<PanelDatum> panelData;
  MerchantData merchantData;

  BingoSaleModel({
    required this.merchantCode,
    required this.noOfDraws,
    required this.gameCode,
    required this.gameId,
    required this.isAdvancePlay,
    required this.isAdditionalDraw,
    required this.currencyCode,
    required this.purchaseDeviceId,
    required this.lastTicketNumber,
    required this.purchaseDeviceType,
    required this.isUpdatedPayoutConfirmed,
    required this.isPowerballPlusPlayed,
    required this.drawData,
    required this.panelData,
    required this.merchantData,
  });

  factory BingoSaleModel.fromJson(Map<String, dynamic> json) => BingoSaleModel(
        merchantCode: json["merchantCode"],
        noOfDraws: json["noOfDraws"],
        gameCode: json["gameCode"],
        gameId: json["gameId"],
        isAdvancePlay: json["isAdvancePlay"],
        isAdditionalDraw: json["isAdditionalDraw"],
        currencyCode: json["currencyCode"],
        purchaseDeviceId: json["purchaseDeviceId"],
        lastTicketNumber: json["lastTicketNumber"],
        purchaseDeviceType: json["purchaseDeviceType"],
        isUpdatedPayoutConfirmed: json["isUpdatedPayoutConfirmed"],
        isPowerballPlusPlayed: json["isPowerballPlusPlayed"],
        drawData: List<DrawDatum>.from(
            json["drawData"].map((x) => DrawDatum.fromJson(x))),
        panelData: List<PanelDatum>.from(
            json["panelData"].map((x) => PanelDatum.fromJson(x))),
        merchantData: MerchantData.fromJson(json["merchantData"]),
      );

  Map<String, dynamic> toJson() => {
        "merchantCode": merchantCode,
        "noOfDraws": noOfDraws,
        "gameCode": gameCode,
        "gameId": gameId,
        "isAdvancePlay": isAdvancePlay,
        "isAdditionalDraw": isAdditionalDraw,
        "currencyCode": currencyCode,
        "purchaseDeviceId": purchaseDeviceId,
        "lastTicketNumber": lastTicketNumber,
        "purchaseDeviceType": purchaseDeviceType,
        "isUpdatedPayoutConfirmed": isUpdatedPayoutConfirmed,
        "isPowerballPlusPlayed": isPowerballPlusPlayed,
        "drawData": List<dynamic>.from(drawData.map((x) => x.toJson())),
        "panelData": List<dynamic>.from(panelData.map((x) => x.toJson())),
        "merchantData": merchantData.toJson(),
      };
}

class DrawDatum {
  DrawDatum();

  factory DrawDatum.fromJson(Map<String, dynamic> json) => DrawDatum();

  Map<String, dynamic> toJson() => {};
}

class MerchantData {
  String aliasName;
  bool deviceCheck;
  String macAddress;
  String userId;
  String sessionId;

  MerchantData({
    required this.aliasName,
    required this.deviceCheck,
    required this.macAddress,
    required this.userId,
    required this.sessionId,
  });

  factory MerchantData.fromJson(Map<String, dynamic> json) => MerchantData(
        aliasName: json["aliasName"],
        deviceCheck: json["deviceCheck"],
        macAddress: json["macAddress"],
        userId: json["userId"],
        sessionId: json["sessionId"],
      );

  Map<String, dynamic> toJson() => {
        "aliasName": aliasName,
        "deviceCheck": deviceCheck,
        "macAddress": macAddress,
        "userId": userId,
        "sessionId": sessionId,
      };
}

class PanelDatum {
  String betType;
  String pickType;
  String pickConfig;
  int betAmountMultiple;
  bool quickPick;
  String pickedValues;
  int numberOfLines;
  bool qpPreGenerated;

  PanelDatum({
    required this.betType,
    required this.pickType,
    required this.pickConfig,
    required this.betAmountMultiple,
    required this.quickPick,
    required this.pickedValues,
    required this.numberOfLines,
    required this.qpPreGenerated,
  });

  factory PanelDatum.fromJson(Map<String, dynamic> json) => PanelDatum(
        betType: json["betType"],
        pickType: json["pickType"],
        pickConfig: json["pickConfig"],
        betAmountMultiple: json["betAmountMultiple"],
        quickPick: json["quickPick"],
        pickedValues: json["pickedValues"],
        numberOfLines: json["numberOfLines"],
        qpPreGenerated: json["qpPreGenerated"],
      );

  Map<String, dynamic> toJson() => {
        "betType": betType,
        "pickType": pickType,
        "pickConfig": pickConfig,
        "betAmountMultiple": betAmountMultiple,
        "quickPick": quickPick,
        "pickedValues": pickedValues,
        "numberOfLines": numberOfLines,
        "qpPreGenerated": qpPreGenerated,
      };
}
