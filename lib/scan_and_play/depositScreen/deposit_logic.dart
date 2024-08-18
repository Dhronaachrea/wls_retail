import 'package:flutter/cupertino.dart';
import 'package:wls_pos/diposit_withdrawal/model/check_availability_response.dart';
import 'package:wls_pos/diposit_withdrawal/model/rePrintApiReponse.dart';
import 'package:wls_pos/scan_and_play/depositScreen/model/qrCodeResponse.dart';
import 'package:wls_pos/scan_and_play/depositScreen/model/sendOtpResponse.dart';
import 'package:wls_pos/scan_and_play/depositScreen/repository/deposit_repository.dart';

import '../../utility/app_constant.dart';
import '../../utility/result.dart';
import '../../utility/user_info.dart';
import 'model/deposit_coupon_reversal/coupon_reversal_response.dart';
import 'model/deposit_response.dart';

class DepositLogic {
  static Future<Result<dynamic>> depositData(
      BuildContext context, Map<String, dynamic> requestBody) async {
    Map<String, String> header = {
      "merchantPwd": merchantPwd,
      "merchantId": rmsMerchantId.toString(),
      "Authorization": "Bearer ${UserInfo.userToken}",
      "userId": UserInfo.userId
    };

    dynamic jsonMap =
        await DepositRepository.depositAmount(context, header, "", requestBody);

    try {
      var respObj = DepositResponse.fromJson(jsonMap);
      if (respObj.errorCode == 0) {
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



  static Future<Result<dynamic>> checkAvailability(
      BuildContext context, Map<String, dynamic> requestBody) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    dynamic jsonMap = await DepositRepository.checkAvailability(
        context, headers, "", requestBody);

    try {
      var respObj = CheckAvailabilityResponse.fromJson(jsonMap);
      if (respObj.errorCode == 0) {
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



  static Future<Result<dynamic>> sendOtp(
      BuildContext context, Map<String, String> requestBody) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "merchantCode": merchantCode,
    };

    dynamic jsonMap = await DepositRepository.sendOtpResponse(
        context, headers, "", requestBody);

    try {
      var respObj = SendOtpResponse.fromJson(jsonMap);
      if (respObj.errorCode == 0) {
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


  static Future<Result<dynamic>> scanQrCode(
      BuildContext context, Map<String, String> requestBody) async {
    Map<String, String> headers = {
      "merchantCode": merchantCode,
      "merchantPwd": merchantPwd,

    };

    dynamic jsonMap = await DepositRepository.scanQrCodeResponse(
        context, headers, "", requestBody);

    try {
      var respObj = QrCodeResponse.fromJson(jsonMap);
      if (respObj.errorCode == 0) {
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


  static Future<Result<dynamic>> reprintQrCode(
      BuildContext context, Map<String, String> requestBody) async {
    Map<String, String> headers = {
      "merchantCode": merchantCode,
      "merchantPwd": merchantPwd,

    };

    dynamic jsonMap = await DepositRepository.rePrintQrCodeResponse(
        context, headers, "", requestBody);

    try {
      var respObj = RePrintQrCodeResponse.fromJson(jsonMap);
      if (respObj.errorCode == 0) {
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


  static Future<Result<dynamic>> couponReversalApi(
      BuildContext context, Map<String, dynamic> requestBody) async {
    Map<String, String> header = {
      "Authorization" : "Bearer ${UserInfo.userToken}",
      "userId"        : UserInfo.userId,
      "merchantId"    : "1",
      "merchantPwd"   : merchantPwd
    };

    dynamic jsonMap = await DepositRepository.couponReversalApi(context, header, "", requestBody);

    try {
      var respObj = CouponReversalResponse.fromJson(jsonMap);
      if (respObj.errorCode == 0) {
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
