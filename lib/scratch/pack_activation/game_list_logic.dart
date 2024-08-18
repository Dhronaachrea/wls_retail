import 'dart:convert';
import 'package:wls_pos/scratch/pack_activation/model/game_list_response.dart';
import 'package:wls_pos/scratch/pack_activation/repository/game_list_repository.dart';
import 'package:wls_pos/utility/result.dart';
import 'package:flutter/cupertino.dart';

class GameListLogic {
  static Future<Result<dynamic>> callGameListData(BuildContext context, Map<String, dynamic> param, var scratchList) async {
    Map apiDetails = json.decode(scratchList.apiDetails);
    String endUrl = apiDetails['gameList']['url'];
    Map headerValues = apiDetails[apiDetails.keys.first]['headers'];
    Map<String, String> header = {
      "clientId": "RMS1",
      "clientSecret": "13f1JiFyWSZ0XI/3Plxr3mv7gbNObpU1",
      "Content-Type": headerValues['Content-Type']
    };
    // Map<String, String> header = {
    //   "clientId": headerValues['clientId'],
    //   "clientSecret": headerValues['clientSecret'],
    //   "Content-Type": headerValues['Content-Type']
    // };

    dynamic jsonMap = await GameListRepository.callGameList(context, param, header,scratchList.basePath, endUrl);

    try {
      var respObj = GameListResponse.fromJson(jsonMap);
      if (respObj.responseCode == 1000) {
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

