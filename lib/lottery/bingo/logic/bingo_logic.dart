import 'package:flutter/material.dart';
import 'package:wls_pos/lottery/bingo/model/response/pick_number_response_model.dart';
import 'package:wls_pos/lottery/bingo/repository/bingo_repository.dart';
import 'package:wls_pos/utility/result.dart';

class BingoLogic {
  static Future<Result<dynamic>> callPickNumber(BuildContext context, Map<String, dynamic> request) async {
    Map<String, String> header = {
      "username": "weaver",
      "password": "password"
    };

    dynamic jsonMap = await BingoRepository.callPickNumber(context, request, header);

    try {
      var respObj = PickNumberResponse.fromJson(jsonMap);
      if (respObj.responseCode == 0) {
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

}