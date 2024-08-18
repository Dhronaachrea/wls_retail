// To parse this JSON data, do
//
//     final pick4GameResultApiResponse = pick4GameResultApiResponseFromJson(jsonString);

import 'dart:convert';

Pick4GameResultApiResponse pick4GameResultApiResponseFromJson(String str) => Pick4GameResultApiResponse.fromJson(json.decode(str));

String pick4GameResultApiResponseToJson(Pick4GameResultApiResponse data) => json.encode(data.toJson());

class Pick4GameResultApiResponse {
  int responseCode;
  String responseMessage;
  ResponseData responseData;

  Pick4GameResultApiResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory Pick4GameResultApiResponse.fromJson(Map<String, dynamic> json) => Pick4GameResultApiResponse(
    responseCode: json["responseCode"],
    responseMessage: json["responseMessage"],
    responseData: ResponseData.fromJson(json["responseData"]),
  );

  Map<String, dynamic> toJson() => {
    "responseCode": responseCode,
    "responseMessage": responseMessage,
    "responseData": responseData.toJson(),
  };
}

class ResponseData {
  List<Pick4Content> content;
  dynamic pageable;
  int totalPages;
  int totalElements;
  bool last;
  bool first;
  Sort sort;
  int numberOfElements;
  int size;
  int number;
  bool empty;

  ResponseData({
    required this.content,
    this.pageable,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.first,
    required this.sort,
    required this.numberOfElements,
    required this.size,
    required this.number,
    required this.empty,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) => ResponseData(
    content: List<Pick4Content>.from(json["content"].map((x) => Pick4Content.fromJson(x))),
    pageable: json["pageable"],
    totalPages: json["totalPages"],
    totalElements: json["totalElements"],
    last: json["last"],
    first: json["first"],
    sort: Sort.fromJson(json["sort"]),
    numberOfElements: json["numberOfElements"],
    size: json["size"],
    number: json["number"],
    empty: json["empty"],
  );

  Map<String, dynamic> toJson() => {
    "content": List<dynamic>.from(content.map((x) => x.toJson())),
    "pageable": pageable,
    "totalPages": totalPages,
    "totalElements": totalElements,
    "last": last,
    "first": first,
    "sort": sort.toJson(),
    "numberOfElements": numberOfElements,
    "size": size,
    "number": number,
    "empty": empty,
  };
}

class Pick4Content {
  int id;
  String provider;
  String drawType;
  String drawNo;
  String drawName;
  DateTime drawSaleDate;
  DateTime drawFreezeDate;
  DateTime drawDate;
  String drawStatus;
  String fixtureType;
  String resultStatus;
  String gameName;
  String gameCode;
  MarketWiseEventData marketWiseEventData;
  MarketWiseEventList marketWiseEventList;
  DrawWinningData drawWinningData;
  DrawWinningDataAddOn drawWinningDataAddOn;

  Pick4Content({
    required this.id,
    required this.provider,
    required this.drawType,
    required this.drawNo,
    required this.drawName,
    required this.drawSaleDate,
    required this.drawFreezeDate,
    required this.drawDate,
    required this.drawStatus,
    required this.fixtureType,
    required this.resultStatus,
    required this.gameName,
    required this.gameCode,
    required this.marketWiseEventData,
    required this.marketWiseEventList,
    required this.drawWinningData,
    required this.drawWinningDataAddOn,
  });

  factory Pick4Content.fromJson(Map<String, dynamic> json) => Pick4Content(
    id: json["id"],
    provider: json["provider"],
    drawType: json["drawType"],
    drawNo: json["drawNo"],
    drawName: json["drawName"],
    drawSaleDate: DateTime.parse(json["drawSaleDate"]),
    drawFreezeDate: DateTime.parse(json["drawFreezeDate"]),
    drawDate: DateTime.parse(json["drawDate"]),
    drawStatus: json["drawStatus"],
    fixtureType: json["fixtureType"],
    resultStatus: json["resultStatus"],
    gameName: json["gameName"],
    gameCode: json["gameCode"],
    marketWiseEventData: MarketWiseEventData.fromJson(json["marketWiseEventData"]),
    marketWiseEventList: MarketWiseEventList.fromJson(json["marketWiseEventList"]),
    drawWinningData: DrawWinningData.fromJson(json["drawWinningData"]),
    drawWinningDataAddOn: DrawWinningDataAddOn.fromJson(json["drawWinningDataAddOn"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provider": provider,
    "drawType": drawType,
    "drawNo": drawNo,
    "drawName": drawName,
    "drawSaleDate": drawSaleDate.toIso8601String(),
    "drawFreezeDate": drawFreezeDate.toIso8601String(),
    "drawDate": drawDate.toIso8601String(),
    "drawStatus": drawStatus,
    "fixtureType": fixtureType,
    "resultStatus": resultStatus,
    "gameName": gameName,
    "gameCode": gameCode,
    "marketWiseEventData": marketWiseEventData.toJson(),
    "marketWiseEventList": marketWiseEventList.toJson(),
    "drawWinningData": drawWinningData.toJson(),
    "drawWinningDataAddOn": drawWinningDataAddOn.toJson(),
  };
}

class DrawWinningData {
  double totalPrizePool;
  List<WinnerDatum> winnerData;
  String nextEstimatedJackpotAmt;

  DrawWinningData({
    required this.totalPrizePool,
    required this.winnerData,
    required this.nextEstimatedJackpotAmt,
  });

  factory DrawWinningData.fromJson(Map<String, dynamic> json) => DrawWinningData(
    totalPrizePool: json["totalPrizePool"]?.toDouble(),
    winnerData: List<WinnerDatum>.from(json["winnerData"].map((x) => WinnerDatum.fromJson(x))),
    nextEstimatedJackpotAmt: json["nextEstimatedJackpotAmt"],
  );

  Map<String, dynamic> toJson() => {
    "totalPrizePool": totalPrizePool,
    "winnerData": List<dynamic>.from(winnerData.map((x) => x.toJson())),
    "nextEstimatedJackpotAmt": nextEstimatedJackpotAmt,
  };
}

class WinnerDatum {
  int rankId;
  int noOfMatchedOutcomes;
  int noOfTotalOutcomes;
  int noOfWinners;
  double payoutPerWinnerSystem;

  WinnerDatum({
    required this.rankId,
    required this.noOfMatchedOutcomes,
    required this.noOfTotalOutcomes,
    required this.noOfWinners,
    required this.payoutPerWinnerSystem,
  });

  factory WinnerDatum.fromJson(Map<String, dynamic> json) => WinnerDatum(
    rankId: json["rank_id"],
    noOfMatchedOutcomes: json["no_of_matched_outcomes"],
    noOfTotalOutcomes: json["no_of_total_outcomes"],
    noOfWinners: json["no_of_winners"],
    payoutPerWinnerSystem: json["payout_per_winner_system"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "rank_id": rankId,
    "no_of_matched_outcomes": noOfMatchedOutcomes,
    "no_of_total_outcomes": noOfTotalOutcomes,
    "no_of_winners": noOfWinners,
    "payout_per_winner_system": payoutPerWinnerSystem,
  };
}

class DrawWinningDataAddOn {
  DrawWinningDataAddOn();

  factory DrawWinningDataAddOn.fromJson(Map<String, dynamic> json) => DrawWinningDataAddOn(
  );

  Map<String, dynamic> toJson() => {
  };
}

class MarketWiseEventData {
  Map<String, Winner> winner;

  MarketWiseEventData({
    required this.winner,
  });

  factory MarketWiseEventData.fromJson(Map<String, dynamic> json) => MarketWiseEventData(
    winner: Map.from(json["WINNER"]).map((k, v) => MapEntry<String, Winner>(k, Winner.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "WINNER": Map.from(winner).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class Winner {
  String eventId;
  String homeScore;
  String awayTeam;
  String marketId;
  String result;
  String score;
  String marketName;
  String awayScore;
  String eventName;
  String homeTeam;
  String marketIdentifier;
  List<String> results;
  DateTime eventDate;

  Winner({
    required this.eventId,
    required this.homeScore,
    required this.awayTeam,
    required this.marketId,
    required this.result,
    required this.score,
    required this.marketName,
    required this.awayScore,
    required this.eventName,
    required this.homeTeam,
    required this.marketIdentifier,
    required this.results,
    required this.eventDate,
  });

  factory Winner.fromJson(Map<String, dynamic> json) => Winner(
    eventId: json["eventId"],
    homeScore: json["homeScore"],
    awayTeam: json["awayTeam"],
    marketId: json["marketId"],
    result: json["result"],
    score: json["score"],
    marketName: json["marketName"],
    awayScore: json["awayScore"],
    eventName: json["eventName"],
    homeTeam: json["homeTeam"],
    marketIdentifier: json["marketIdentifier"],
    results: List<String>.from(json["results"].map((x) => x)),
    eventDate: DateTime.parse(json["eventDate"]),
  );

  Map<String, dynamic> toJson() => {
    "eventId": eventId,
    "homeScore": homeScore,
    "awayTeam": awayTeam,
    "marketId": marketId,
    "result": result,
    "score": score,
    "marketName": marketName,
    "awayScore": awayScore,
    "eventName": eventName,
    "homeTeam": homeTeam,
    "marketIdentifier": marketIdentifier,
    "results": List<dynamic>.from(results.map((x) => x)),
    "eventDate": eventDate.toIso8601String(),
  };
}

class MarketWiseEventList {
  List<Winner> winner;

  MarketWiseEventList({
    required this.winner,
  });

  factory MarketWiseEventList.fromJson(Map<String, dynamic> json) => MarketWiseEventList(
    winner: List<Winner>.from(json["WINNER"].map((x) => Winner.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "WINNER": List<dynamic>.from(winner.map((x) => x.toJson())),
  };
}

class Sort {
  bool sorted;
  bool unsorted;
  bool empty;

  Sort({
    required this.sorted,
    required this.unsorted,
    required this.empty,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
    sorted: json["sorted"],
    unsorted: json["unsorted"],
    empty: json["empty"],
  );

  Map<String, dynamic> toJson() => {
    "sorted": sorted,
    "unsorted": unsorted,
    "empty": empty,
  };
}
