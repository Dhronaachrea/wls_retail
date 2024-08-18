class SaleResponseModel {
  dynamic responseCode;
  String? responseMessage;
  ResponseData? responseData;

  SaleResponseModel(
      {this.responseCode, this.responseMessage, this.responseData});

  SaleResponseModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['responseCode'];
    responseMessage = json['responseMessage'];
    responseData = json['responseData'] != null
        ? ResponseData.fromJson(json['responseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['responseCode'] = responseCode;
    data['responseMessage'] = responseMessage;
    if (responseData != null) {
      data['responseData'] = responseData!.toJson();
    }
    return data;
  }
}

class ResponseData {
  String? transactionStatus;
  String? saleStatus;
  String? message;
  String? ticketNumber;
  String? orderId;
  String? itemId;
  String? gameCode;
  dynamic playerId;
  int? drawId;
  int? drawNo;
  dynamic totalSaleAmount;
  String? transactionDateTime;
  String? saleStartDateTime;
  String? drawFreezeDateTime;
  int? noOfTicketsPerBoard;
  String? drawDateTime;
  String? rgRespJson;
  MainDrawData? mainDrawData;
  MainDrawData? addOnDrawData;

  ResponseData(
      {this.transactionStatus,
        this.saleStatus,
        this.message,
        this.ticketNumber,
        this.orderId,
        this.itemId,
        this.gameCode,
        this.playerId,
        this.drawId,
        this.drawNo,
        this.totalSaleAmount,
        this.transactionDateTime,
        this.saleStartDateTime,
        this.drawFreezeDateTime,
        this.noOfTicketsPerBoard,
        this.drawDateTime,
        this.rgRespJson,
        this.mainDrawData,
        this.addOnDrawData,
      });

  ResponseData.fromJson(Map<String, dynamic> json) {
    transactionStatus = json['transactionStatus'];
    saleStatus = json['saleStatus'];
    message = json['message'];
    ticketNumber = json['ticketNumber'];
    orderId = json['orderId'];
    itemId = json['itemId'];
    gameCode = json['gameCode'];
    playerId = json['playerId'];
    drawId = json['drawId'];
    drawNo = json['drawNo'];
    totalSaleAmount = json['totalSaleAmount'];
    transactionDateTime = json['transactionDateTime'];
    saleStartDateTime = json['saleStartDateTime'];
    drawFreezeDateTime = json['drawFreezeDateTime'];
    noOfTicketsPerBoard = json['noOfTicketsPerBoard'];
    drawDateTime = json['drawDateTime'];
    rgRespJson = json['rgRespJson'];
    mainDrawData = json['mainDrawData'] != null
        ? MainDrawData.fromJson(json['mainDrawData'])
        : null;
    addOnDrawData = json['addOnDrawData'] != null
        ? MainDrawData.fromJson(json['addOnDrawData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['transactionStatus'] = transactionStatus;
    data['saleStatus'] = saleStatus;
    data['message'] = message;
    data['ticketNumber'] = ticketNumber;
    data['orderId'] = orderId;
    data['itemId'] = itemId;
    data['gameCode'] = gameCode;
    data['playerId'] = playerId;
    data['drawId'] = drawId;
    data['drawNo'] = drawNo;
    data['totalSaleAmount'] = totalSaleAmount;
    data['transactionDateTime'] = transactionDateTime;
    data['saleStartDateTime'] = saleStartDateTime;
    data['drawFreezeDateTime'] = drawFreezeDateTime;
    data['noOfTicketsPerBoard'] = noOfTicketsPerBoard;
    data['drawDateTime'] = drawDateTime;
    data['rgRespJson'] = rgRespJson;
    if (mainDrawData != null) {
      data['mainDrawData'] = mainDrawData!.toJson();
    }
    if (addOnDrawData != null) {
      data['addOnDrawData'] = addOnDrawData!.toJson();
    }
    return data;
  }
}

class MainDrawData {
  int? boardCount;
  dynamic totalPrice;
  dynamic boardUnitPrice;
  List<Boards>? boards;

  MainDrawData(
      {this.boardCount, this.totalPrice, this.boardUnitPrice, this.boards});

  MainDrawData.fromJson(Map<String, dynamic> json) {
    boardCount = json['boardCount'];
    totalPrice = json['totalPrice'];
    boardUnitPrice = json['boardUnitPrice'];
    if (json['boards'] != null) {
      boards = <Boards>[];
      json['boards'].forEach((v) {
        boards!.add(Boards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['boardCount'] = boardCount;
    data['totalPrice'] = totalPrice;
    data['boardUnitPrice'] = boardUnitPrice;
    if (boards != null) {
      data['boards'] = boards!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Boards {
  String? marketName;
  String? marketCode;
  List<Events>? events;
  int? marketId;

  Boards({this.marketName, this.marketCode, this.events, this.marketId});

  Boards.fromJson(Map<String, dynamic> json) {
    marketName = json['marketName'];
    marketCode = json['marketCode'];
    if (json['events'] != null) {
      events = <Events>[];
      json['events'].forEach((v) {
        events!.add(Events.fromJson(v));
      });
    }
    marketId = json['marketId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['marketName'] = marketName;
    data['marketCode'] = marketCode;
    if (events != null) {
      data['events'] = events!.map((v) => v.toJson()).toList();
    }
    data['marketId'] = marketId;
    return data;
  }
}

class Events {
  int? eventId;
  List<Options>? options;
  String? eventName;
  String? homeTeamName;
  String? awayTeamName;
  String? homeTeamAbbr;
  String? awayTeamAbbr;

  Events(
      {this.eventId,
        this.options,
        this.eventName,
        this.homeTeamName,
        this.awayTeamName,
        this.homeTeamAbbr,
        this.awayTeamAbbr
      });

  Events.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
    eventName = json['eventName'];
    homeTeamName = json['homeTeamName'];
    awayTeamName = json['AwayTeamName'];
    homeTeamAbbr = json['homeTeamAbbr'];
    awayTeamAbbr = json['awayTeamAbbr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eventId'] = eventId;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    data['eventName'] = eventName;
    data['homeTeamName'] = homeTeamName;
    data['AwayTeamName'] = awayTeamName;
    data['homeTeamAbbr'] = this.homeTeamAbbr;
    data['awayTeamAbbr'] = this.awayTeamAbbr;
    return data;
  }
}

class Options {
  int? id;
  String? code;
  String? name;
  String? displayName;

  Options({this.id, this.code, this.name, this.displayName});

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    displayName = json['displayName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['displayName'] = displayName;
    return data;
  }
}
