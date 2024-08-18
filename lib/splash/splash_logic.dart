import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wls_pos/splash/repository/repository/splash_repository.dart';

import '../utility/result.dart';
import 'model/model/response/DefaultConfigData.dart';

class SplashLogic{

  static Future<Result<dynamic>> getDefaultConfigApi(
      BuildContext context) async {

    dynamic jsonMap = await SplashRepository.getDefaultConfigApi(context);
    //dynamic jsonDummy = '{"responseCode":0,"responseMessage":"Success","responseData":{"message":"Success","statusCode":0,"data":{"COUNTRY_CODES":"+243","SYSTEM_ALLOWED_LANGUAGES":"en,fr","MOBILE_REGEX":"","OTP_LENGTH":"5","IS_B2B_AND_B2C":"YES","PASSWORD_REGEX":""}}}';
    //dynamic jsonDummy =   '{"responseCode":0,"responseMessage":"Success","responseData":{"message":"Success","statusCode":0,"data":{"COUNTRY_CODES":"+243","MOBILE_CODE_MIN_MAX_LENGTH":{},"SYSTEM_ALLOWED_LANGUAGES":"en","MOBILE_REGEX":"","OTP_LENGTH":"5","IS_B2B_AND_B2C":"YES","PASSWORD_REGEX":""}}}';
    try {
      var respObj = DefaultDomainConfigData.fromJson(jsonMap);
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