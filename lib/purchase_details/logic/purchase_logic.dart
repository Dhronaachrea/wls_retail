import 'package:flutter/material.dart';
import 'package:wls_pos/login/models/response/LoginTokenResponse.dart';
import 'package:wls_pos/purchase_details/model/response/sale_response_model.dart';
import 'package:wls_pos/purchase_details/repositry/purchase_repository.dart';

import '../../utility/result.dart';

class PurchaseLogic {
  static Future<Result<dynamic>> callSaleApi(
    BuildContext context,
    Map<String, dynamic> saleInfo,
    Map<String, String> param,
  ) async {
    Map<String, dynamic> requestBody = saleInfo;

    Map<String, String> header = {'Content-Type': 'application/json'};

    dynamic jsonMap = await PurchaseRepository.callRetailerSaleApi(
      context,
      param,
      header,
      requestBody,
    );

    try {
      var respObj = SaleResponseModel.fromJson(jsonMap);
      if (respObj.responseCode == 0 && respObj.responseData?.transactionStatus.toString().toUpperCase() == "SUCCESS") {
        return Result.responseSuccess(data: respObj);
      }else if (respObj.responseCode == 401 || respObj.responseCode == 100) {
        return Result.failure(data: respObj);
      }
      else {
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
