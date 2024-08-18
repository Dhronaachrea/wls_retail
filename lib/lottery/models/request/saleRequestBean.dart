class SaleRequestBean {
  String? currencyCode;
  List<DrawData>? drawData;
  String? gameCode;
  bool? isAdvancePlay;
  String? lastTicketNumber;
  String? merchantCode;
  MerchantData? merchantData;
  String? modelCode;
  int? noOfDraws;
  int? noOfPanels;
  bool? isUpdatedPayoutConfirmed;
  bool? isPowerballPlusPlayed;
  List<PanelData>? panelData;
  String? purchaseDeviceId;
  String? purchaseDeviceType;
  int? gameId;

  SaleRequestBean(
      {this.currencyCode,
        this.drawData,
        this.gameCode,
        this.isAdvancePlay,
        this.lastTicketNumber,
        this.merchantCode,
        this.merchantData,
        this.modelCode,
        this.noOfDraws,
        this.noOfPanels,
        this.isUpdatedPayoutConfirmed,
        this.isPowerballPlusPlayed,
        this.panelData,
        this.purchaseDeviceId,
        this.purchaseDeviceType,
        this.gameId,
      });

  SaleRequestBean.fromJson(Map<String, dynamic> json) {
    currencyCode = json['currencyCode'];
    if (json['drawData'] != null) {
      drawData = <DrawData>[];
      json['drawData'].forEach((v) {
        drawData!.add(new DrawData.fromJson(v));
      });
    }
    gameCode = json['gameCode'];
    isAdvancePlay = json['isAdvancePlay'];
    lastTicketNumber = json['lastTicketNumber'];
    merchantCode = json['merchantCode'];
    merchantData = json['merchantData'] != null
        ? new MerchantData.fromJson(json['merchantData'])
        : null;
    modelCode = json['modelCode'];
    noOfDraws = json['noOfDraws'];
    noOfPanels = json['noOfPanels'];
    isUpdatedPayoutConfirmed = json['isUpdatedPayoutConfirmed'];
    isPowerballPlusPlayed = json['isPowerballPlusPlayed'];
    if (json['panelData'] != null) {
      panelData = <PanelData>[];
      json['panelData'].forEach((v) {
        panelData!.add(new PanelData.fromJson(v));
      });
    }
    purchaseDeviceId = json['purchaseDeviceId'];
    purchaseDeviceType = json['purchaseDeviceType'];
    gameId = json['gameId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currencyCode'] = this.currencyCode;
    if (this.drawData != null) {
      data['drawData'] = this.drawData!.map((v) => v.toJson()).toList();
    }
    data['gameCode'] = this.gameCode;
    data['isAdvancePlay'] = this.isAdvancePlay;
    data['lastTicketNumber'] = this.lastTicketNumber;
    data['merchantCode'] = this.merchantCode;
    if (this.merchantData != null) {
      data['merchantData'] = this.merchantData!.toJson();
    }
    data['modelCode'] = this.modelCode;
    data['noOfDraws'] = this.noOfDraws;
    data['noOfPanels'] = this.noOfPanels;
    data['isUpdatedPayoutConfirmed'] = this.isUpdatedPayoutConfirmed;
    data['isPowerballPlusPlayed'] = this.isPowerballPlusPlayed;
    if (this.panelData != null) {
      data['panelData'] = this.panelData!.map((v) => v.toJson()).toList();
    }
    data['purchaseDeviceId'] = this.purchaseDeviceId;
    data['purchaseDeviceType'] = this.purchaseDeviceType;
    data['gameId'] = this.gameId;
    return data;
  }
}

class DrawData {
  String? drawId;

  DrawData({this.drawId});

  DrawData.fromJson(Map<String, dynamic> json) {
    drawId = json['drawId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drawId'] = this.drawId;
    return data;
  }
}

class MerchantData {
  String? sessionId;
  int? userId;
  String? userName;
  String? aliasName;

  MerchantData({this.sessionId, this.userId, this.userName, this.aliasName});

  MerchantData.fromJson(Map<String, dynamic> json) {
    sessionId = json['sessionId'];
    userId = json['userId'];
    userName = json['userName'];
    aliasName = json['aliasName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionId'] = this.sessionId;
    data['userId'] = this.userId;
    data['userName'] = this.userName;
    data['aliasName'] = this.aliasName;
    return data;
  }
}

class PanelData {
  int? betAmountMultiple;
  String? betType;
  String? pickConfig;
  String? pickType;
  String? pickedValues;
  bool? qpPreGenerated;
  bool? quickPick;
  int? totalNumbers;
  double? currentPayout;
 /* double? doubleJackpotCost;
  double? secureJackpotCost;*/
  bool? doubleJackpot;
  bool? secureJackpot;

  PanelData(
      {this.betAmountMultiple,
        this.betType,
        this.pickConfig,
        this.pickType,
        this.pickedValues,
        this.qpPreGenerated,
        this.quickPick,
        this.totalNumbers,
        this.currentPayout,
       /* this.doubleJackpotCost,
        this.secureJackpotCost,*/
        this.doubleJackpot,
        this.secureJackpot,
      });

  PanelData.fromJson(Map<String, dynamic> json) {
    betAmountMultiple = json['betAmountMultiple'];
    betType = json['betType'];
    pickConfig = json['pickConfig'];
    pickType = json['pickType'];
    pickedValues = json['pickedValues'];
    qpPreGenerated = json['qpPreGenerated'];
    quickPick = json['quickPick'];
    totalNumbers = json['totalNumbers'];
    currentPayout = json['currentPayout'];
   /* if(json['doubleJackpotCost'] != null){
      doubleJackpotCost = json['doubleJackpotCost'];
    }
    if(json['secureJackpotCost'] != null){
      secureJackpotCost = json['secureJackpotCost'];
    }*/
    if(json['doubleJackpot'] != null){
      doubleJackpot = json['doubleJackpot'];
    }
    if(json['secureJackpot'] != null){
      secureJackpot = json['secureJackpot'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['betAmountMultiple'] = this.betAmountMultiple;
    data['betType'] = this.betType;
    data['pickConfig'] = this.pickConfig;
    data['pickType'] = this.pickType;
    data['pickedValues'] = this.pickedValues;
    data['qpPreGenerated'] = this.qpPreGenerated;
    data['quickPick'] = this.quickPick;
    data['totalNumbers'] = this.totalNumbers;
    data['currentPayout'] = this.currentPayout;
   /* if(this.doubleJackpotCost != null){
      data['doubleJackpotCost'] = this.doubleJackpotCost;
    }
    if(this.secureJackpotCost != null){
      data['secureJackpotCost'] = this.secureJackpotCost;
    }*/
    if(this.doubleJackpot != null){
      data['doubleJackpot'] = this.doubleJackpot;
    }
    if(this.secureJackpot != null){
      data['secureJackpot'] = this.secureJackpot;
    }
    return data;
  }
}
