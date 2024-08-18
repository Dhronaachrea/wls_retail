// To parse this JSON data, do
//
//     final gameResultApiResponse = gameResultApiResponseFromJson(jsonString);

import 'dart:convert';

GameResultApiResponse gameResultApiResponseFromJson(String str) => GameResultApiResponse.fromJson(json.decode(str));

String gameResultApiResponseToJson(GameResultApiResponse data) => json.encode(data.toJson());

class GameResultApiResponse {
  int responseCode;
  String responseMessage;
  ResponseData responseData;

  GameResultApiResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory GameResultApiResponse.fromJson(Map<String, dynamic> json) => GameResultApiResponse(
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
  List<Content> content;
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
    content: List<Content>.from(json["content"].map((x) => Content.fromJson(x))),
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

class Content {
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
  DrawWinningData drawWinningDataAddOn;

  Content({
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

  factory Content.fromJson(Map<String, dynamic> json) => Content(
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
    drawWinningDataAddOn: DrawWinningData.fromJson(json["drawWinningDataAddOn"]),
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
  dynamic totalPrizePool;
  List<WinnerDatum> winnerData;
  String nextEstimatedJackpotAmt;

  DrawWinningData({
    required this.totalPrizePool,
    required this.winnerData,
    required this.nextEstimatedJackpotAmt,
  });

  factory DrawWinningData.fromJson(Map<String, dynamic> json) => DrawWinningData(
    totalPrizePool: json["totalPrizePool"],
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
  int noOfTotalOutcomes;
  int noOfMatchedOutcomes;
  int noOfWinners;
  dynamic payoutPerWinnerSystem;

  WinnerDatum({
    required this.rankId,
    required this.noOfTotalOutcomes,
    required this.noOfMatchedOutcomes,
    required this.noOfWinners,
    required this.payoutPerWinnerSystem,
  });

  factory WinnerDatum.fromJson(Map<String, dynamic> json) => WinnerDatum(
    rankId: json["rank_id"],
    noOfTotalOutcomes: json["no_of_total_outcomes"],
    noOfMatchedOutcomes: json["no_of_matched_outcomes"],
    noOfWinners: json["no_of_winners"],
    payoutPerWinnerSystem: json["payout_per_winner_system"],
  );

  Map<String, dynamic> toJson() => {
    "rank_id": rankId,
    "no_of_total_outcomes": noOfTotalOutcomes,
    "no_of_matched_outcomes": noOfMatchedOutcomes,
    "no_of_winners": noOfWinners,
    "payout_per_winner_system": payoutPerWinnerSystem,
  };
}

class MarketWiseEventData {
  Map<String, OneXTwo> oneXTwo;
  Map<String, OneXTwo> tossWinner;

  MarketWiseEventData({
    required this.oneXTwo,
    required this.tossWinner,
  });

  factory MarketWiseEventData.fromJson(Map<String, dynamic> json) => MarketWiseEventData(
    oneXTwo: Map.from(json["ONE_X_TWO"]).map((k, v) => MapEntry<String, OneXTwo>(k, OneXTwo.fromJson(v))),
    tossWinner: Map.from(json["TOSS_WINNER"]).map((k, v) => MapEntry<String, OneXTwo>(k, OneXTwo.fromJson(v))),
  );

  Map<String, dynamic> toJson() => {
    "ONE_X_TWO": Map.from(oneXTwo).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
    "TOSS_WINNER": Map.from(tossWinner).map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
  };
}

class OneXTwo {
  String eventId;
  HomeScore homeScore;
  String awayTeam;
  String marketId;
  Result1 result;
  String score;
  String marketName;
  AwayScore awayScore;
  String eventName;
  String homeTeam;
  MarketIdentifier marketIdentifier;
  List<Result1> results;
  DateTime eventDate;

  OneXTwo({
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

  factory OneXTwo.fromJson(Map<String, dynamic> json) => OneXTwo(
    eventId: json["eventId"],
    homeScore: homeScoreValues.map[json["homeScore"]]!,
    awayTeam: json["awayTeam"],
    marketId: json["marketId"],
    result: resultValues.map[json["result"]]!,
    score: json["score"],
    // marketName: marketNameValues.map[json["marketName"]]!,
    marketName: json["marketName"],
    awayScore: awayScoreValues.map[json["awayScore"]]!,
    eventName: json["eventName"],
    homeTeam: json["homeTeam"],
    marketIdentifier: marketIdentifierValues.map[json["marketIdentifier"]]!,
    results: List<Result1>.from(json["results"].map((x) => resultValues.map[x]!)),
    eventDate: DateTime.parse(json["eventDate"]),
  );

  Map<String, dynamic> toJson() => {
    "eventId": eventId,
    "homeScore": homeScoreValues.reverse[homeScore],
    "awayTeam": awayTeam,
    "marketId": marketId,
    "result": resultValues.reverse[result],
    "score": score,
    "marketName": marketNameValues.reverse[marketName],
    "awayScore": awayScoreValues.reverse[awayScore],
    "eventName": eventName,
    "homeTeam": homeTeam,
    "marketIdentifier": marketIdentifierValues.reverse[marketIdentifier],
    "results": List<dynamic>.from(results.map((x) => resultValues.reverse[x])),
    "eventDate": eventDate.toIso8601String(),
  };
}

enum AwayScore { THE_5010, EMPTY }

final awayScoreValues = EnumValues({
  "": AwayScore.EMPTY,
  "50/10": AwayScore.THE_5010
});

enum HomeScore { THE_25010, EMPTY }

final homeScoreValues = EnumValues({
  "": HomeScore.EMPTY,
  "250/10": HomeScore.THE_25010
});

enum MarketIdentifier { ONE_X_TWO, TOSS_WINNER }

final marketIdentifierValues = EnumValues({
  "ONE_X_TWO": MarketIdentifier.ONE_X_TWO,
  "TOSS_WINNER": MarketIdentifier.TOSS_WINNER
});

enum MarketName { THE_1_X2, TOSS_WINNER }

final marketNameValues = EnumValues({
  "1X2": MarketName.THE_1_X2,
  "Toss Winner": MarketName.TOSS_WINNER
});

enum Result1 { HOME, AWAY }

final resultValues = EnumValues({
  "AWAY": Result1.AWAY,
  "HOME": Result1.HOME
});

class MarketWiseEventList {
  List<OneXTwo> oneXTwo;
  List<OneXTwo> tossWinner;

  MarketWiseEventList({
    required this.oneXTwo,
    required this.tossWinner,
  });

  factory MarketWiseEventList.fromJson(Map<String, dynamic> json) => MarketWiseEventList(
    oneXTwo: List<OneXTwo>.from(json["ONE_X_TWO"].map((x) => OneXTwo.fromJson(x))),
    tossWinner: List<OneXTwo>.from(json["TOSS_WINNER"].map((x) => OneXTwo.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ONE_X_TWO": List<dynamic>.from(oneXTwo.map((x) => x.toJson())),
    "TOSS_WINNER": List<dynamic>.from(tossWinner.map((x) => x.toJson())),
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

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
