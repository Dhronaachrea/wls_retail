import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:wls_pos/scratch/packOrder/model/pack_order_response.dart';
import 'package:wls_pos/scratch/packOrder/repository/pack_order_repository.dart';
import 'package:wls_pos/utility/result.dart';

class PackOrderLogic {
  static Future<Result<dynamic>> callPackOrderData(BuildContext context, Map<String, dynamic> param, var scratchList) async {
    // Map<dynamic, dynamic> apiDetails = json.decode(scratchList.apiDetails);
    Map apiDetails = json.decode(scratchList.apiDetails);
    String endUrl = apiDetails[apiDetails.keys.first]['url'] ; //quickOrderUrl;
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

    dynamic jsonMap = await PackOrderRepository.callPackOrder(context, param, header,scratchList.basePath, endUrl);

    try {
      var respObj = PackOrderResponse.fromJson(jsonMap);
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

