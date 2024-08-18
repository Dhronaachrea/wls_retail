import 'package:flutter/cupertino.dart';
import 'package:wls_pos/game_result/models/response/gameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/pick4GameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/soccerGameResultApiResponse.dart';
import 'package:wls_pos/game_result/repository/game_result_repository.dart';
import 'package:wls_pos/utility/result.dart';

class GameResultLogic {
  static Future<Result<dynamic>> callGameResultList(
      BuildContext context, Map<String, String> param, String gameName) async {
    Map<String, String> header = {
      // "Authorization" : "Bearer ${UserInfo.userToken}"
      "Authorization": "Bearer v8RTJ0Ai21bkLoo-apZanYi7SG_-avf2t76bjXCNSQY"
    };

    dynamic jsonMap =
        await GameResultRepository.callGameResultList(context, param);

    try {
      var respObj;
      switch (gameName) {
        case 'SOCCER 4':
          {
            respObj = SoccerGameResultApiResponse.fromJson(jsonMap);
          }
          break;

        case 'SOCCER 12':
          {
            respObj = SoccerGameResultApiResponse.fromJson(jsonMap);
          }
          break;

        case 'CRICKET5':
          {
            respObj = GameResultApiResponse.fromJson(jsonMap);
          }
          break;
        case 'PICK4':
          {
            respObj = Pick4GameResultApiResponse.fromJson(jsonMap);
          }
          break;
      }
      // var respObj = GameResultApiResponse.fromJson(jsonMap);
      if (respObj.responseCode == 0) {
        return Result.responseSuccess(data: respObj);
      } else {
        return jsonMap["occurredErrorDescriptionMsg"] != null
            ? jsonMap["occurredErrorDescriptionMsg"] == "No connection"
                ? Result.networkFault(data: jsonMap)
                : Result.failure(data: jsonMap)
            : Result.responseFailure(data: respObj);
      }
    } catch (e) {
      if (jsonMap["occurredErrorDescriptionMsg"] == "No connection") {
        return Result.networkFault(data: jsonMap);
      } else {
        return Result.failure(
            data: jsonMap["occurredErrorDescriptionMsg"] != null
                ? jsonMap
                : {"occurredErrorDescriptionMsg": e});
      }
    }
  }
}
