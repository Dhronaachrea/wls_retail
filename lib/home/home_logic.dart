import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/home/models/response/get_config_response.dart';
import 'package:wls_pos/home/repository/home_repository.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/result.dart';
import 'package:wls_pos/utility/utils.dart';

import '../lottery/repository/lottery_repository.dart';
import '../utility/user_info.dart';
import 'models/response/get_config_response.dart';

class HomeLogic {
  static Future<Result<dynamic>> callUserMenuList(
      BuildContext context, Map<String, String> param) async {
    Map<String, String> header = {
      "Authorization" : "Bearer ${UserInfo.userToken}"
    };

    dynamic jsonMap =
        await HomeRepository.callUserMenuList(context, param, header);

    try {
      var respObj = UserMenuApiResponse.fromJson(jsonMap);
      if (respObj.responseData?.statusCode == 0) {
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


  static Future<Result<dynamic>> callConfigData(
      BuildContext context, Map<String, String> param) async {
    Map<String, String> header = {
      "Authorization" : "Bearer ${UserInfo.userToken}"
    };

    dynamic jsonMap =
        await HomeRepository.getConfigResponse(context, param, header);

    try {
      var respObj = GetConfigResponse.fromJson(jsonMap);
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

  static Future<Result<dynamic>> callRePrint(BuildContext context, String baseUrl, String relativeUrl, Map<String, dynamic> request) async {
    ModuleBeanLst? mModuleBeanList = ModuleBeanLst.fromJson(jsonDecode(UserInfo.getDrawGameBeanList));
    MenuBeanList? apiDetails = mModuleBeanList.menuBeanList?.where((element) => element.menuCode == "DGE_REPRINT").toList()[0];
    UrlDrawGameBean? rePrintGameUrlsDetails = getDrawGameUrlDetails(apiDetails!, context, "reprintTicket");

    Map<String, String> header = {
      "username": rePrintGameUrlsDetails?.username ?? "",
      "password": rePrintGameUrlsDetails?.password ?? "",
    };

    dynamic jsonMap = await LotteryRepository.callRePrint(context, request, header, baseUrl, relativeUrl, rePrintGameUrlsDetails);

    try {
      var respObj = RePrintResponse.fromJson(jsonMap);
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
