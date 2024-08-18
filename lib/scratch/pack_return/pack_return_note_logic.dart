import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:wls_pos/scratch/pack_return/model/pack_return_note_response.dart';
import 'package:wls_pos/scratch/pack_return/model/response/game_vise_inventory_response.dart';
import 'package:wls_pos/scratch/pack_return/repository/pack_return_note_repository.dart';
import 'package:wls_pos/utility/result.dart';

import 'model/response/pack_return_submit_response.dart';

class PackReturnNoteLogic {
  static Future<Result<dynamic>> callPackReturnNoteData(BuildContext context, Map<String, dynamic> param, var scratchList) async {
    Map apiDetails = json.decode(scratchList.apiDetails);
    String endUrl = apiDetails['getReturnNote']['url'];
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

    dynamic jsonMap = await PackReturnNoteRepository.callPackReturnNoteList(context, param, header,scratchList.basePath, endUrl);

    try {
      var respObj = PackReturnNoteResponse.fromJson(jsonMap);
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
  static Future<Result<dynamic>> callGameViseInventoryData(BuildContext context, Map<String, dynamic> param, var scratchList) async {
    Map apiDetails = json.decode(scratchList.apiDetails);
      String endUrl = apiDetails['getGameWiseInventory']['url']; //gameWiseInventoryUrl ;
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

    dynamic jsonMap = await GameWiseInventoryRepository.callGameViseInventory(context, param, header,/*scratchUrl*/ scratchList.basePath, endUrl);

    //dynamic dummyData = '{"responseCode":1000,"responseMessage":"Success","response":{"gameDetails":[{"gameId":37,"bookList":["206-002008","206-002009","206-003002","206-003003","206-003004","206-003005","206-003006","206-003007","206-003008","206-003009","206-003010","206-003011","206-003012","206-003013","206-003014","206-003015","206-003016","206-003017","206-003018","206-003019","206-003020","206-004005","206-004006","206-004007","206-004008","206-004009","206-004010"]},{"gameId":38,"bookList":["306-002008","306-002009","306-003002","306-003003","306-003004","306-003005","306-003006","306-003007"]}]}}';

    try {
      //var respObj = GameViseInventoryResponse.fromJson(jsonDecode(dummyData));
      var respObj = GameViseInventoryResponse.fromJson(jsonMap);
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
  static Future<Result<dynamic>> callPackReturnSubmitData(BuildContext context, Map<String, dynamic> param, var scratchList) async {
    Map apiDetails = json.decode(scratchList.apiDetails);
    String endUrl = apiDetails['packReturnSubmit']['url']; // packReturnSubmitUrl ;
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

    dynamic jsonMap = await PackReturnSubmitRepository.callPackReturnSubmit(context, param, header, /*scratchUrl*/ scratchList.basePath, endUrl);

    try {
      var respObj = PackReturnSubmitResponse.fromJson(jsonMap);
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

