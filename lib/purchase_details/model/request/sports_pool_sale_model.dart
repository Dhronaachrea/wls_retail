class SportsPoolSaleModel {
  String? locale;
  String? domainName;
  int? merchantId;
  String? gameCode;
  String? currencyCode;
  int? orderId;
  int? itemId;
  int? drawId;
  String? userType;
  String? drawStatus;
  String? drawName;
  String? saleStartTime;
  String? drawFreezeTime;
  String? drawDateTime;
  double? noOfTicketPerLine;
  double? totalSaleAmount;
  bool? isMobile;
  String? deviceId;
  MainDrawData? mainDrawData;
  AddOnDrawData? addOnDrawData;
  String? betType;

  SportsPoolSaleModel(
      {this.locale,
      this.domainName,
      this.merchantId,
      this.gameCode,
      this.currencyCode,
      this.orderId,
      this.itemId,
      this.drawId,
      this.userType,
      this.drawStatus,
      this.drawName,
      this.saleStartTime,
      this.drawFreezeTime,
      this.drawDateTime,
      this.noOfTicketPerLine,
      this.totalSaleAmount,
      this.isMobile,
      this.deviceId,
      this.mainDrawData,
      this.addOnDrawData,
      this.betType});

  SportsPoolSaleModel.fromJson(Map<String, dynamic> json) {
    locale = json['locale'];
    domainName = json['domainName'];
    merchantId = json['merchantId'];
    gameCode = json['gameCode'];
    currencyCode = json['currencyCode'];
    orderId = json['orderId'];
    itemId = json['itemId'];
    drawId = json['drawId'];
    userType = json['userType'];
    drawStatus = json['drawStatus'];
    drawName = json['drawName'];
    saleStartTime = json['saleStartTime'];
    drawFreezeTime = json['drawFreezeTime'];
    drawDateTime = json['drawDateTime'];
    noOfTicketPerLine = json['noOfTicketPerLine'];
    totalSaleAmount = json['totalSaleAmount'];
    isMobile = json['isMobile'];
    deviceId = json['deviceId'];
    mainDrawData = json['mainDrawData'] != null
        ? new MainDrawData.fromJson(json['mainDrawData'])
        : null;
    addOnDrawData = json['addOnDrawData'] != null
        ? new AddOnDrawData.fromJson(json['addOnDrawData'])
        : null;
    betType = json['betType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locale'] = this.locale;
    data['domainName'] = this.domainName;
    data['merchantId'] = this.merchantId;
    data['gameCode'] = this.gameCode;
    data['currencyCode'] = this.currencyCode;
    data['orderId'] = this.orderId;
    data['itemId'] = this.itemId;
    data['drawId'] = this.drawId;
    data['userType'] = this.userType;
    data['drawStatus'] = this.drawStatus;
    data['drawName'] = this.drawName;
    data['saleStartTime'] = this.saleStartTime;
    data['drawFreezeTime'] = this.drawFreezeTime;
    data['drawDateTime'] = this.drawDateTime;
    data['noOfTicketPerLine'] = this.noOfTicketPerLine;
    data['totalSaleAmount'] = this.totalSaleAmount;
    data['isMobile'] = this.isMobile;
    data['deviceId'] = this.deviceId;
    if (this.mainDrawData != null) {
      data['mainDrawData'] = this.mainDrawData!.toJson();
    }
    if (this.addOnDrawData != null) {
      data['addOnDrawData'] = this.addOnDrawData!.toJson();
    }
    data['betType'] = this.betType;
    return data;
  }
}

class MainDrawData {
  int? noOfLines;
  double? unitTicketPrice;
  double? totalAmount;
  List<Markets>? markets;

  MainDrawData(
      {this.noOfLines, this.unitTicketPrice, this.totalAmount, this.markets});

  MainDrawData.fromJson(Map<String, dynamic> json) {
    noOfLines = json['noOfLines'];
    unitTicketPrice = json['unitTicketPrice'];
    totalAmount = json['totalAmount'];
    if (json['markets'] != null) {
      markets = <Markets>[];
      json['markets'].forEach((v) {
        markets!.add(new Markets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['noOfLines'] = this.noOfLines;
    data['unitTicketPrice'] = this.unitTicketPrice;
    data['totalAmount'] = this.totalAmount;
    if (this.markets != null) {
      data['markets'] = this.markets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Markets {
  String? marketCode;
  List<Events>? events;

  Markets({this.marketCode, this.events});

  Markets.fromJson(Map<String, dynamic> json) {
    marketCode = json['marketCode'];
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(new Events.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['marketCode'] = this.marketCode;
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Events {
  int? eventId;
  List<Options>? options;

  Events({this.eventId, this.options});

  Events.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(new Options.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  int? id;
  String? code;
  String? name;

  Options({this.id, this.code, this.name});

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    return data;
  }
}

class AddOnDrawData {
  int? noOfLines;
  double? unitTicketPrice;
  double? totalAmount;
  List<Markets>? markets;

  AddOnDrawData(
      {this.noOfLines, this.unitTicketPrice, this.totalAmount, this.markets});

  AddOnDrawData.fromJson(Map<String, dynamic> json) {
    noOfLines = json['noOfLines'];
    unitTicketPrice = json['unitTicketPrice'];
    totalAmount = json['totalAmount'];
    if (json['markets'] != null) {
      markets = <Markets>[];
      json['markets'].forEach((v) {
        markets!.add(new Markets.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['noOfLines'] = this.noOfLines;
    data['unitTicketPrice'] = this.unitTicketPrice;
    data['totalAmount'] = this.totalAmount;
    if (this.markets != null) {
      data['markets'] = this.markets!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
