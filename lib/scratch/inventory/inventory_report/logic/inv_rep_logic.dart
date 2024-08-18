import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/model/response/inv_rep_response.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/repository/inv_rep_repository.dart';
import 'package:wls_pos/utility/result.dart';

class InvRepLogic {
  static Future<Result<dynamic>> callInvDetailsForRetailerAPI(
      BuildContext context,
      MenuBeanList? menuBeanList,
      Map<String, String> param) async {
    Map apiDetails = json.decode(menuBeanList?.apiDetails ?? "");
    String? endUrl = apiDetails[apiDetails.keys.first]['url'];
    Map headerValues = apiDetails[apiDetails.keys.first]['headers'];
    Map<String, String> header = {
      "clientId": headerValues['clientId'] /*"RMS"*/,
      "clientSecret": headerValues['clientSecret'] /*"13f1JiFyWSZ0XI/3Plxr3mv7gbNObpU2" */
    };

    dynamic jsonMap = await InvRepRepository.callInvDetailsForRetailerAPI(
        context, param, header,menuBeanList!.basePath ?? "https://rms-wls.infinitilotto.com/PPL", endUrl ?? "/reports/getInventoryDetailsForRetailer");

    try {
      var respObj = InvRepResponse.fromJson(jsonMap);
      if (respObj.responseCode == 1000) {
        return Result.responseSuccess(data: respObj);

      } else {
        return jsonMap["occurredErrorDescriptionMsg"] != null ? jsonMap["occurredErrorDescriptionMsg"] == "No connection" ? Result.networkFault(data: jsonMap) : Result.failure(data: jsonMap) : Result.responseFailure(data: respObj.responseMessage);
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
