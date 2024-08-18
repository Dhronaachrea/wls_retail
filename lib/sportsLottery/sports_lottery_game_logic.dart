import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart';
import 'package:wls_pos/sportsLottery/models/response/sp_reprint_response.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';
import 'package:wls_pos/sportsLottery/repository/sports_lottery_game_repository.dart';
import 'package:wls_pos/utility/result.dart';

class SportsLotteryGameLogic {
  static Future<Result<dynamic>> callSportsLotteryGameList(BuildContext context, Map<String, String> param) async {
    // Map<String, String> header = {
      // "Authorization" : "Bearer ${UserInfo.userToken}"
      // "Authorization": "Bearer 4tIV5Bk1SiyMWVpaUFjlHH4kwRD3CRRa26Iog2s7LIo"
    // };

    dynamic jsonMap = await SportsLotteryGameRepository.callSportsLotteryGameList(context, param);

    try {
      var respObj = SportsLotteryGameApiResponse.fromJson(jsonMap);
      if (respObj.responseCode == 0 ) {
        return Result.responseSuccess(data: respObj);

      } else {
        return jsonMap["occurredErrorDescriptionMsg"] != null ? jsonMap["occurredErrorDescriptionMsg"] == "No connection" ? Result.networkFault(data: jsonMap) : Result.failure(data: jsonMap) : Result.responseFailure(data: respObj);
      }

    } catch(e) {
      if(jsonMap["occurredErrorDescriptionMsg"] == "No connection") {
        return Result.networkFault(data: jsonMap);

      } else {
        return Result.failure(data: jsonMap["occurredErrorDescriptionMsg"] != null ? jsonMap : {"occurredErrorDescriptionMsg": e});
      }
    }
  }

  static Future<Result<dynamic>> callRePrint(BuildContext context,Map<String, dynamic> request) async {
    Map<String, String> header = {
      "Accept": "application/json"
    };

    dynamic jsonMap = await SportsLotteryGameRepository.callRePrint(context, header,request);
    try {
      var respObj = SpRePrintResponse.fromJson(jsonMap);
      if (respObj.responseCode == 1000) {
        return Result.responseSuccess(data: respObj);

      } else {
        return jsonMap["occurredErrorDescriptionMsg"] != null ? jsonMap["occurredErrorDescriptionMsg"] == "No connection" ? Result.networkFault(data: jsonMap) : Result.failure(data: jsonMap) : Result.responseFailure(data: respObj);
      }

    } catch(e) {
      log("Error e : $e");
      if(jsonMap["occurredErrorDescriptionMsg"] == "No connection") {
        return Result.networkFault(data: jsonMap);

      } else {
        return Result.failure(data: jsonMap["occurredErrorDescriptionMsg"] != null ? jsonMap : {"occurredErrorDescriptionMsg": e});
      }
    }
  }
}