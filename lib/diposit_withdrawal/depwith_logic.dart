import 'package:flutter/material.dart';
import 'package:wls_pos/diposit_withdrawal/model/depwith_response.dart';
import 'package:wls_pos/diposit_withdrawal/repository/depwith_repository.dart';
import 'package:wls_pos/utility/result.dart';

class DepWithLogic {
  static Future<Result<dynamic>> callDepWithApi(BuildContext context, Map<String, String> param) async {
    Map<String, String> header = {
      // "Authorization" : "Bearer ${UserInfo.userToken}"
      "Authorization": "Bearer HVdcfzXFfuCGC9va1pJzuZaH4iflTxEZ4R7KoIXlXtY"
    };

    dynamic jsonMap = await DepWithRepository.callDepWithApi(context, param, header);

    try {
      var respObj = DepWithResponse.fromJson(jsonMap);
      if (respObj.responseCode == 0 && respObj.responseData.statusCode == 0) {
        return Result.responseSuccess(data: respObj);

      } else {
        return jsonMap["occurredErrorDescriptionMsg"] != null ? jsonMap["occurredErrorDescriptionMsg"] == "No connection" ? Result.networkFault(data: jsonMap) : Result.failure(data: jsonMap) : Result.responseFailure(data: respObj.responseData.message);
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