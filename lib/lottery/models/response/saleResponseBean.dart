class SaleResponseBean {
  int? responseCode;
  String? responseMessage;
  ResponseData? responseData;

  SaleResponseBean(
      {this.responseCode, this.responseMessage, this.responseData});

  SaleResponseBean.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    responseData = json['responseData'] != null
        ? new ResponseData.fromJson(json['responseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['responseCode'] = this.responseCode;
    data['responseMessage'] = this.responseMessage;
    if (this.responseData != null) {
      data['responseData'] = this.responseData!.toJson();
    }
    return data;
  }
}

class ResponseData {
  int? gameId;
  String? gameName;
  String? gameCode;
  double? totalPurchaseAmount;
  double? playerPurchaseAmount;
  String? purchaseTime;
  String? ticketNumber;
  List<PanelData>? panelData;
  List<DrawData>? drawData;
  String? merchantCode;
  String? currencyCode;
  String? partyType;
  String? channel;
  String? availableBal;
  String? validationCode;
  String? ticketExpiry;
  int? noOfDraws;
  double? secureJackpotAmount;
  double? doubleJackpotAmount;

  ResponseData(
      {this.gameId,
        this.gameName,
        this.gameCode,
        this.totalPurchaseAmount,
        this.playerPurchaseAmount,
        this.purchaseTime,
        this.ticketNumber,
        this.panelData,
        this.drawData,
        this.merchantCode,
        this.currencyCode,
        this.partyType,
        this.channel,
        this.availableBal,
        this.validationCode,
        this.ticketExpiry,
        this.noOfDraws,
        this.secureJackpotAmount,
        this.doubleJackpotAmount
       });

  ResponseData.fromJson(Map<String, dynamic> json) {
    gameId = json['gameId'];
    gameName = json['gameName'];
    gameCode = json['gameCode'];
    totalPurchaseAmount = json['totalPurchaseAmount'];
    playerPurchaseAmount = json['playerPurchaseAmount'];
    purchaseTime = json['purchaseTime'];
    ticketNumber = json['ticketNumber'];
    if (json['panelData'] != null) {
      panelData = <PanelData>[];
      json['panelData'].forEach((v) {
        panelData!.add(new PanelData.fromJson(v));
      });
    }
    if (json['drawData'] != null) {
      drawData = <DrawData>[];
      json['drawData'].forEach((v) {
        drawData!.add(new DrawData.fromJson(v));
      });
    }
    merchantCode = json['merchantCode'];
    currencyCode = json['currencyCode'];
    partyType = json['partyType'];
    channel = json['channel'];
    availableBal = json['availableBal'];
    validationCode = json['validationCode'];
    ticketExpiry = json['ticketExpiry'];
    noOfDraws = json['noOfDraws'];
    secureJackpotAmount = json['secureJackpotAmount'];
    doubleJackpotAmount = json['doubleJackpotAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gameId'] = this.gameId;
    data['gameName'] = this.gameName;
    data['gameCode'] = this.gameCode;
    data['totalPurchaseAmount'] = this.totalPurchaseAmount;
    data['playerPurchaseAmount'] = this.playerPurchaseAmount;
    data['purchaseTime'] = this.purchaseTime;
    data['ticketNumber'] = this.ticketNumber;
    if (this.panelData != null) {
      data['panelData'] = this.panelData!.map((v) => v.toJson()).toList();
    }
    if (this.drawData != null) {
      data['drawData'] = this.drawData!.map((v) => v.toJson()).toList();
    }
    data['merchantCode'] = this.merchantCode;
    data['currencyCode'] = this.currencyCode;
    data['partyType'] = this.partyType;
    data['channel'] = this.channel;
    data['availableBal'] = this.availableBal;
    data['validationCode'] = this.validationCode;
    data['ticketExpiry'] = this.ticketExpiry;
    data['noOfDraws'] = this.noOfDraws;
    data['secureJackpotAmount'] = this.secureJackpotAmount;
    data['doubleJackpotAmount'] = this.doubleJackpotAmount;
    return data;
  }
}

class PanelData {
  String? betType;
  String? pickType;
  String? pickConfig;
  dynamic betAmountMultiple; //changed from int? to dynamic for 2d Myanmar
  bool? quickPick;
  String? pickedValues;
  bool? qpPreGenerated;
  int? numberOfLines;
  double? unitCost;
  double? panelPrice;
  double? playerPanelPrice;
  String? betDisplayName;
  String? pickDisplayName;
  bool? doubleJackpot;
  bool? secureJackpot;

  PanelData(
      {this.betType,
        this.pickType,
        this.pickConfig,
        this.betAmountMultiple,
        this.quickPick,
        this.pickedValues,
        this.qpPreGenerated,
        this.numberOfLines,
        this.unitCost,
        this.panelPrice,
        this.playerPanelPrice,
        this.betDisplayName,
        this.pickDisplayName,
        this.doubleJackpot,
        this.secureJackpot,
      });

  PanelData.fromJson(Map<String, dynamic> json) {
    betType = json['betType'];
    pickType = json['pickType'];
    pickConfig = json['pickConfig'];
    betAmountMultiple = json['betAmountMultiple'];
    quickPick = json['quickPick'];
    pickedValues = json['pickedValues'];
    qpPreGenerated = json['qpPreGenerated'];
    numberOfLines = json['numberOfLines'];
    unitCost = json['unitCost'];
    panelPrice = json['panelPrice'];
    playerPanelPrice = json['playerPanelPrice'];
    betDisplayName = json['betDisplayName'];
    pickDisplayName = json['pickDisplayName'];
    if(json['doubleJackpot'] != null){
      doubleJackpot = json['doubleJackpot'];
    }
    if(json['secureJackpot'] != null){
      secureJackpot = json['secureJackpot'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['betType'] = this.betType;
    data['pickType'] = this.pickType;
    data['pickConfig'] = this.pickConfig;
    data['betAmountMultiple'] = this.betAmountMultiple;
    data['quickPick'] = this.quickPick;
    data['pickedValues'] = this.pickedValues;
    data['qpPreGenerated'] = this.qpPreGenerated;
    data['numberOfLines'] = this.numberOfLines;
    data['unitCost'] = this.unitCost;
    data['panelPrice'] = this.panelPrice;
    data['playerPanelPrice'] = this.playerPanelPrice;
    data['betDisplayName'] = this.betDisplayName;
    data['pickDisplayName'] = this.pickDisplayName;
    if(this.doubleJackpot != null){
      data['doubleJackpot'] = this.doubleJackpot;
    }
    if(this.secureJackpot != null){
      data['secureJackpot'] = this.secureJackpot;
    }
    return data;
  }
}

class DrawData {
  String? drawName;
  String? drawDate;
  String? drawTime;

  DrawData({this.drawName, this.drawDate, this.drawTime});

  DrawData.fromJson(Map<String, dynamic> json) {
    drawName = json['drawName'];
    drawDate = json['drawDate'];
    drawTime = json['drawTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['drawName'] = this.drawName;
    data['drawDate'] = this.drawDate;
    data['drawTime'] = this.drawTime;
    return data;
  }
}
