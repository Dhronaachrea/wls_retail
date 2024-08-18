// To parse this JSON data, do
//
//     final soccerGameResultApiResponse = soccerGameResultApiResponseFromJson(jsonString);

import 'dart:convert';

SoccerGameResultApiResponse soccerGameResultApiResponseFromJson(String str) =>
    SoccerGameResultApiResponse.fromJson(json.decode(str));

String soccerGameResultApiResponseToJson(SoccerGameResultApiResponse data) =>
    json.encode(data.toJson());

class SoccerGameResultApiResponse {
  int responseCode;
  String responseMessage;
  ResponseData responseData;

  SoccerGameResultApiResponse({
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory SoccerGameResultApiResponse.fromJson(Map<String, dynamic> json) =>
      SoccerGameResultApiResponse(
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
  List<SoccerContent> content;
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
        content: List<SoccerContent>.from(json["content"].map((x) => SoccerContent.fromJson(x))),
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

class SoccerContent {
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

  SoccerContent({
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

  factory SoccerContent.fromJson(Map<String, dynamic> json) => SoccerContent(
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
        marketWiseEventData:
            MarketWiseEventData.fromJson(json["marketWiseEventData"]),
        marketWiseEventList:
            MarketWiseEventList.fromJson(json["marketWiseEventList"]),
        drawWinningData: DrawWinningData.fromJson(json["drawWinningData"]),
        drawWinningDataAddOn:
            DrawWinningDataAddOn.fromJson(json["drawWinningDataAddOn"]),
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

  factory DrawWinningData.fromJson(Map<String, dynamic> json) =>
      DrawWinningData(
        totalPrizePool: json["totalPrizePool"]?.toDouble(),
        winnerData: List<WinnerDatum>.from(
            json["winnerData"].map((x) => WinnerDatum.fromJson(x))),
        nextEstimatedJackpotAmt: json["nextEstimatedJackpotAmt"],
      );

  Map<String, dynamic> toJson() => {
        "totalPrizePool": totalPrizePool,
        "winnerData": List<dynamic>.from(winnerData.map((x) => x.toJson())),
        "nextEstimatedJackpotAmt": nextEstimatedJackpotAmt,
      };
}

class WinnerDatum {
  dynamic rankId;
  dynamic noOfMatchedOutcomes;
  dynamic noOfTotalOutcomes;
  dynamic noOfWinners;
  dynamic payoutPerWinnerSystem;

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
        payoutPerWinnerSystem: json["payout_per_winner_system"],
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

  factory DrawWinningDataAddOn.fromJson(Map<String, dynamic> json) =>
      DrawWinningDataAddOn();

  Map<String, dynamic> toJson() => {};
}

class MarketWiseEventData {
  Map<String, OneXTwo> halfTimeOneXTwo;
  Map<String, OneXTwo> oneXTwo;

  MarketWiseEventData({
    required this.halfTimeOneXTwo,
    required this.oneXTwo,
  });

  factory MarketWiseEventData.fromJson(Map<String, dynamic> json) =>
      MarketWiseEventData(
        halfTimeOneXTwo: json["HALF_TIME_ONE_X_TWO"] != null ? Map.from(json["HALF_TIME_ONE_X_TWO"])
            .map((k, v) => MapEntry<String, OneXTwo>(k, OneXTwo.fromJson(v))) : {},
        oneXTwo: json["ONE_X_TWO"] != null ? Map.from(json["ONE_X_TWO"])
            .map((k, v) => MapEntry<String, OneXTwo>(k, OneXTwo.fromJson(v))) : {},
      );

  Map<String, dynamic> toJson() => {
        "HALF_TIME_ONE_X_TWO": halfTimeOneXTwo != null ? Map.from(halfTimeOneXTwo)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())) : {},
        "ONE_X_TWO": oneXTwo != null ? Map.from(oneXTwo)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())) : {},
      };
}

class OneXTwo {
  String eventId;
  String homeScore;
  String awayTeam;
  String marketId;
  Result1 result;
  String score;
  // MarketName marketName;
  String marketName;
  String awayScore;
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
        homeScore: json["homeScore"],
        awayTeam: json["awayTeam"],
        marketId: json["marketId"],
        result: resultValues.map[json["result"]]!,
        score: json["score"],
        // marketName: marketNameValues.map[json["marketName"]]!,
        marketName: json["marketName"]!,
        awayScore: json["awayScore"],
        eventName: json["eventName"],
        homeTeam: json["homeTeam"],
        marketIdentifier: marketIdentifierValues.map[json["marketIdentifier"]]!,
        results: List<Result1>.from(
            json["results"].map((x) => resultValues.map[x]!)),
        eventDate: DateTime.parse(json["eventDate"]),
      );

  Map<String, dynamic> toJson() => {
        "eventId": eventId,
        "homeScore": homeScore,
        "awayTeam": awayTeam,
        "marketId": marketId,
        "result": resultValues.reverse[result],
        "score": score,
        "marketName": marketNameValues.reverse[marketName],
        "awayScore": awayScore,
        "eventName": eventName,
        "homeTeam": homeTeam,
        "marketIdentifier": marketIdentifierValues.reverse[marketIdentifier],
        "results":
            List<dynamic>.from(results.map((x) => resultValues.reverse[x])),
        "eventDate": eventDate.toIso8601String(),
      };
}

enum MarketIdentifier { HALF_TIME_ONE_X_TWO, ONE_X_TWO }

final marketIdentifierValues = EnumValues({
  "HALF_TIME_ONE_X_TWO": MarketIdentifier.HALF_TIME_ONE_X_TWO,
  "ONE_X_TWO": MarketIdentifier.ONE_X_TWO
});

enum MarketName { HALF_TIME_1_X2, THE_1_X2 }

final marketNameValues = EnumValues(
    {"Half time 1X2": MarketName.HALF_TIME_1_X2, "1X2": MarketName.THE_1_X2});

enum Result1 { HOME }

final resultValues = EnumValues({"HOME": Result1.HOME});

class MarketWiseEventList {
  List<OneXTwo>? halfTimeOneXTwo;
  List<OneXTwo>? oneXTwo;

  MarketWiseEventList({
    required this.halfTimeOneXTwo,
    required this.oneXTwo,
  });

  MarketWiseEventList.fromJson(Map<String, dynamic> json) {
    if (json['HALF_TIME_ONE_X_TWO'] != null) {
      halfTimeOneXTwo = <OneXTwo>[];
      json['HALF_TIME_ONE_X_TWO'].forEach((v) {
        halfTimeOneXTwo!.add(new OneXTwo.fromJson(v));
      });
    }
    if (json['ONE_X_TWO'] != null) {
      oneXTwo = <OneXTwo>[];
      json['ONE_X_TWO'].forEach((v) {
        oneXTwo!.add(new OneXTwo.fromJson(v));
      });
    }
  }

  // factory MarketWiseEventList.fromJson(Map<String, dynamic> json) => MarketWiseEventList(
  //   halfTimeOneXTwo: List<OneXTwo>.from(json["HALF_TIME_ONE_X_TWO"].map((x) => OneXTwo.fromJson(x))),
  //   oneXTwo: List<OneXTwo>.from(json["ONE_X_TWO"].map((x) => OneXTwo.fromJson(x))),
  // );

  // Map<String, dynamic> toJson() => {
  //   "HALF_TIME_ONE_X_TWO": List<dynamic>.from(halfTimeOneXTwo.map((x) => x.toJson())),
  //   "ONE_X_TWO": List<dynamic>.from(oneXTwo.map((x) => x.toJson())),
  // };

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.halfTimeOneXTwo != null) {
      data['HALF_TIME_ONE_X_TWO'] =
          this.halfTimeOneXTwo!.map((v) => v.toJson()).toList();
    }
    if (this.oneXTwo != null) {
      data['ONE_X_TWO'] = this.oneXTwo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
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
