import 'dart:convert';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:wls_pos/scratch/saleTicket/repository/sale_ticket_repository.dart';
import 'package:wls_pos/utility/result.dart';

import 'model/response/sale_ticket_response.dart';

class SaleTicketLogic {
  static Future<Result<dynamic>> callSaleTicketData(BuildContext context, Map<String, dynamic> param, var scratchList) async {
    // Map<dynamic, dynamic> apiDetails = json.decode(scratchList.apiDetails);
    Map apiDetails = json.decode(scratchList.apiDetails);
    String endUrl = apiDetails[apiDetails.keys.first]['url']; //soldTicketUrl;
    Map headerValues = apiDetails[apiDetails.keys.first]['headers'];
    Map<String, String> header = {
      "clientId": "RMS1",
      "clientSecret": "13f1JiFyWSZ0XI/3Plxr3mv7gbNObpU1",
      "Content-Type": headerValues['Content-Type']
    };

    dynamic jsonMap = await SaleTicketRepository.callSaleTicket(context, param, header,scratchList.basePath, endUrl);

    try {
      var respObj = SaleTicketResponse.fromJson(jsonMap);
      if (respObj.responseCode == scratchResponseCode) {
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

