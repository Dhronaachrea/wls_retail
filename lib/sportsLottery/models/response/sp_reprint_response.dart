class SpRePrintResponse {
  int? responseCode;
  String? responseMessage;
  ResponseData? responseData;

  SpRePrintResponse(
      {this.responseCode, this.responseMessage, this.responseData});

  SpRePrintResponse.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? year;
  int? month;
  int? day;
  String? ticketDate;
  String? deviceId;
  int? randomNo;
  int? lastRandomNo;
  String? lastTicketNo;
  int? dayOfYear;
  int? txnOfDay;
  String? ticketNo;
  int? domainId;
  double? saleAmountDomain;
  String? oneWayEncLastTicketNo;
  String? twoWayEncLastTicketNo;
  String? oneWayEncTicketNo;
  String? twoWayEncTicketNo;
  String? tpTxnId;
  dynamic saleReturnTpTxnId;
  dynamic tpErrorResponse;
  String? authoriserRemarks;
  int? gameId;
  int? merchantId;
  String? merchantGameCode;
  String? currency;
  String? currencyDomain;
  String? currencySystem;
  int? userId;
  String? merchantPlayerId;
  String? ticketType;
  String? userType;
  int? txnCount;
  int? noOfTicketPerLine;
  double? saleAmount;
  double? cancelledAmount;
  String? winningStatus;
  double? winningAmount;
  double? winningAmountDomain;
  double? saleAmountSystem;
  double? mainDrawSaleAmountSystem;
  double? addonDrawSaleAmountSystem;
  dynamic payoutTransactionId;
  double? cancelledAmountSystem;
  double? winningAmountSystem;
  double? mainDrawWinningAmountSystem;
  double? addonDrawWinningAmountSystem;
  dynamic payoutRetailerUserId;
  dynamic paidAt;
  String? successAt;
  String? status;
  String? transactionStatus;
  String? settlementStatus;
  int? reprintCount;
  String? lastReprintAt;
  dynamic payoutValidTill;
  int? drawId;
  int? addonDrawId;
  String? orderId;
  String? itemId;
  dynamic highWinningRequestId;
  dynamic cancelledRemarks;
  dynamic cancelledBy;
  dynamic cancelledByUserName;
  dynamic cancelledByUserId;
  dynamic settledAt;
  dynamic isHighWin;
  dynamic isQuickPick;
  String? selectionJson;
  String? createdAt;
  String? updatedAt;
  String? service;
  dynamic betTransactions;
  dynamic markedByScheduler;
  dynamic cancelledAt;
  dynamic sessionUserId;
  dynamic sessionUserName;
  dynamic cancelationRemarks;
  dynamic mainBoardData;
  dynamic addOnBoardData;
  dynamic eventIds;
  dynamic sportEventMarketOptionById;
  dynamic processMethod;
  dynamic rgRespJson;
  int? merchantErrorCode;
  String? statusMessage;
  int? drawNo;
  String? saleStartDateTime;
  String? drawFreezeDateTime;
  String? drawDateTime;

  ResponseData(
      {this.id,
        this.year,
        this.month,
        this.day,
        this.ticketDate,
        this.deviceId,
        this.randomNo,
        this.lastRandomNo,
        this.lastTicketNo,
        this.dayOfYear,
        this.txnOfDay,
        this.ticketNo,
        this.domainId,
        this.saleAmountDomain,
        this.oneWayEncLastTicketNo,
        this.twoWayEncLastTicketNo,
        this.oneWayEncTicketNo,
        this.twoWayEncTicketNo,
        this.tpTxnId,
        this.saleReturnTpTxnId,
        this.tpErrorResponse,
        this.authoriserRemarks,
        this.gameId,
        this.merchantId,
        this.merchantGameCode,
        this.currency,
        this.currencyDomain,
        this.currencySystem,
        this.userId,
        this.merchantPlayerId,
        this.ticketType,
        this.userType,
        this.txnCount,
        this.noOfTicketPerLine,
        this.saleAmount,
        this.cancelledAmount,
        this.winningStatus,
        this.winningAmount,
        this.winningAmountDomain,
        this.saleAmountSystem,
        this.mainDrawSaleAmountSystem,
        this.addonDrawSaleAmountSystem,
        this.payoutTransactionId,
        this.cancelledAmountSystem,
        this.winningAmountSystem,
        this.mainDrawWinningAmountSystem,
        this.addonDrawWinningAmountSystem,
        this.payoutRetailerUserId,
        this.paidAt,
        this.successAt,
        this.status,
        this.transactionStatus,
        this.settlementStatus,
        this.reprintCount,
        this.lastReprintAt,
        this.payoutValidTill,
        this.drawId,
        this.addonDrawId,
        this.orderId,
        this.itemId,
        this.highWinningRequestId,
        this.cancelledRemarks,
        this.cancelledBy,
        this.cancelledByUserName,
        this.cancelledByUserId,
        this.settledAt,
        this.isHighWin,
        this.isQuickPick,
        this.selectionJson,
        this.createdAt,
        this.updatedAt,
        this.service,
        this.betTransactions,
        this.markedByScheduler,
        this.cancelledAt,
        this.sessionUserId,
        this.sessionUserName,
        this.cancelationRemarks,
        this.mainBoardData,
        this.addOnBoardData,
        this.eventIds,
        this.sportEventMarketOptionById,
        this.processMethod,
        this.rgRespJson,
        this.merchantErrorCode,
        this.statusMessage,
        this.drawNo,
        this.saleStartDateTime,
        this.drawFreezeDateTime,
        this.drawDateTime});

  ResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    year = json['year'];
    month = json['month'];
    day = json['day'];
    ticketDate = json['ticketDate'];
    deviceId = json['deviceId'];
    randomNo = json['randomNo'];
    lastRandomNo = json['lastRandomNo'];
    lastTicketNo = json['lastTicketNo'];
    dayOfYear = json['dayOfYear'];
    txnOfDay = json['txnOfDay'];
    ticketNo = json['ticketNo'];
    domainId = json['domainId'];
    saleAmountDomain = json['saleAmountDomain'];
    oneWayEncLastTicketNo = json['oneWayEncLastTicketNo'];
    twoWayEncLastTicketNo = json['twoWayEncLastTicketNo'];
    oneWayEncTicketNo = json['oneWayEncTicketNo'];
    twoWayEncTicketNo = json['twoWayEncTicketNo'];
    tpTxnId = json['tpTxnId'];
    saleReturnTpTxnId = json['saleReturnTpTxnId'];
    tpErrorResponse = json['tpErrorResponse'];
    authoriserRemarks = json['authoriserRemarks'];
    gameId = json['gameId'];
    merchantId = json['merchantId'];
    merchantGameCode = json['merchantGameCode'];
    currency = json['currency'];
    currencyDomain = json['currencyDomain'];
    currencySystem = json['currencySystem'];
    userId = json['userId'];
    merchantPlayerId = json['merchantPlayerId'];
    ticketType = json['ticketType'];
    userType = json['userType'];
    txnCount = json['txnCount'];
    noOfTicketPerLine = json['noOfTicketPerLine'];
    saleAmount = json['saleAmount'];
    cancelledAmount = json['cancelledAmount'];
    winningStatus = json['winningStatus'];
    winningAmount = json['winningAmount'];
    winningAmountDomain = json['winningAmountDomain'];
    saleAmountSystem = json['saleAmountSystem'];
    mainDrawSaleAmountSystem = json['mainDrawSaleAmountSystem'];
    addonDrawSaleAmountSystem = json['addonDrawSaleAmountSystem'];
    payoutTransactionId = json['payoutTransactionId'];
    cancelledAmountSystem = json['cancelledAmountSystem'];
    winningAmountSystem = json['winningAmountSystem'];
    mainDrawWinningAmountSystem = json['mainDrawWinningAmountSystem'];
    addonDrawWinningAmountSystem = json['addonDrawWinningAmountSystem'];
    payoutRetailerUserId = json['payoutRetailerUserId'];
    paidAt = json['paidAt'];
    successAt = json['successAt'];
    status = json['status'];
    transactionStatus = json['transactionStatus'];
    settlementStatus = json['settlementStatus'];
    reprintCount = json['reprintCount'];
    lastReprintAt = json['lastReprintAt'];
    payoutValidTill = json['payoutValidTill'];
    drawId = json['drawId'];
    addonDrawId = json['addonDrawId'];
    orderId = json['orderId'];
    itemId = json['itemId'];
    highWinningRequestId = json['highWinningRequestId'];
    cancelledRemarks = json['cancelledRemarks'];
    cancelledBy = json['cancelledBy'];
    cancelledByUserName = json['cancelledByUserName'];
    cancelledByUserId = json['cancelledByUserId'];
    settledAt = json['settledAt'];
    isHighWin = json['isHighWin'];
    isQuickPick = json['isQuickPick'];
    selectionJson = json['selectionJson'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    service = json['service'];
    betTransactions = json['betTransactions'];
    markedByScheduler = json['markedByScheduler'];
    cancelledAt = json['cancelledAt'];
    sessionUserId = json['sessionUserId'];
    sessionUserName = json['sessionUserName'];
    cancelationRemarks = json['cancelationRemarks'];
    mainBoardData = json['mainBoardData'];
    addOnBoardData = json['addOnBoardData'];
    eventIds = json['eventIds'];
    sportEventMarketOptionById = json['sportEventMarketOptionById'];
    processMethod = json['processMethod'];
    rgRespJson = json['rgRespJson'];
    merchantErrorCode = json['merchantErrorCode'];
    statusMessage = json['statusMessage'];
    drawNo = json['drawNo'];
    saleStartDateTime = json['saleStartDateTime'];
    drawFreezeDateTime = json['drawFreezeDateTime'];
    drawDateTime = json['drawDateTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['year'] = this.year;
    data['month'] = this.month;
    data['day'] = this.day;
    data['ticketDate'] = this.ticketDate;
    data['deviceId'] = this.deviceId;
    data['randomNo'] = this.randomNo;
    data['lastRandomNo'] = this.lastRandomNo;
    data['lastTicketNo'] = this.lastTicketNo;
    data['dayOfYear'] = this.dayOfYear;
    data['txnOfDay'] = this.txnOfDay;
    data['ticketNo'] = this.ticketNo;
    data['domainId'] = this.domainId;
    data['saleAmountDomain'] = this.saleAmountDomain;
    data['oneWayEncLastTicketNo'] = this.oneWayEncLastTicketNo;
    data['twoWayEncLastTicketNo'] = this.twoWayEncLastTicketNo;
    data['oneWayEncTicketNo'] = this.oneWayEncTicketNo;
    data['twoWayEncTicketNo'] = this.twoWayEncTicketNo;
    data['tpTxnId'] = this.tpTxnId;
    data['saleReturnTpTxnId'] = this.saleReturnTpTxnId;
    data['tpErrorResponse'] = this.tpErrorResponse;
    data['authoriserRemarks'] = this.authoriserRemarks;
    data['gameId'] = this.gameId;
    data['merchantId'] = this.merchantId;
    data['merchantGameCode'] = this.merchantGameCode;
    data['currency'] = this.currency;
    data['currencyDomain'] = this.currencyDomain;
    data['currencySystem'] = this.currencySystem;
    data['userId'] = this.userId;
    data['merchantPlayerId'] = this.merchantPlayerId;
    data['ticketType'] = this.ticketType;
    data['userType'] = this.userType;
    data['txnCount'] = this.txnCount;
    data['noOfTicketPerLine'] = this.noOfTicketPerLine;
    data['saleAmount'] = this.saleAmount;
    data['cancelledAmount'] = this.cancelledAmount;
    data['winningStatus'] = this.winningStatus;
    data['winningAmount'] = this.winningAmount;
    data['winningAmountDomain'] = this.winningAmountDomain;
    data['saleAmountSystem'] = this.saleAmountSystem;
    data['mainDrawSaleAmountSystem'] = this.mainDrawSaleAmountSystem;
    data['addonDrawSaleAmountSystem'] = this.addonDrawSaleAmountSystem;
    data['payoutTransactionId'] = this.payoutTransactionId;
    data['cancelledAmountSystem'] = this.cancelledAmountSystem;
    data['winningAmountSystem'] = this.winningAmountSystem;
    data['mainDrawWinningAmountSystem'] = this.mainDrawWinningAmountSystem;
    data['addonDrawWinningAmountSystem'] = this.addonDrawWinningAmountSystem;
    data['payoutRetailerUserId'] = this.payoutRetailerUserId;
    data['paidAt'] = this.paidAt;
    data['successAt'] = this.successAt;
    data['status'] = this.status;
    data['transactionStatus'] = this.transactionStatus;
    data['settlementStatus'] = this.settlementStatus;
    data['reprintCount'] = this.reprintCount;
    data['lastReprintAt'] = this.lastReprintAt;
    data['payoutValidTill'] = this.payoutValidTill;
    data['drawId'] = this.drawId;
    data['addonDrawId'] = this.addonDrawId;
    data['orderId'] = this.orderId;
    data['itemId'] = this.itemId;
    data['highWinningRequestId'] = this.highWinningRequestId;
    data['cancelledRemarks'] = this.cancelledRemarks;
    data['cancelledBy'] = this.cancelledBy;
    data['cancelledByUserName'] = this.cancelledByUserName;
    data['cancelledByUserId'] = this.cancelledByUserId;
    data['settledAt'] = this.settledAt;
    data['isHighWin'] = this.isHighWin;
    data['isQuickPick'] = this.isQuickPick;
    data['selectionJson'] = this.selectionJson;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['service'] = this.service;
    data['betTransactions'] = this.betTransactions;
    data['markedByScheduler'] = this.markedByScheduler;
    data['cancelledAt'] = this.cancelledAt;
    data['sessionUserId'] = this.sessionUserId;
    data['sessionUserName'] = this.sessionUserName;
    data['cancelationRemarks'] = this.cancelationRemarks;
    data['mainBoardData'] = this.mainBoardData;
    data['addOnBoardData'] = this.addOnBoardData;
    data['eventIds'] = this.eventIds;
    data['sportEventMarketOptionById'] = this.sportEventMarketOptionById;
    data['processMethod'] = this.processMethod;
    data['rgRespJson'] = this.rgRespJson;
    data['merchantErrorCode'] = this.merchantErrorCode;
    data['statusMessage'] = this.statusMessage;
    data['drawNo'] = this.drawNo;
    data['saleStartDateTime'] = this.saleStartDateTime;
    data['drawFreezeDateTime'] = this.drawFreezeDateTime;
    data['drawDateTime'] = this.drawDateTime;
    return data;
  }
}