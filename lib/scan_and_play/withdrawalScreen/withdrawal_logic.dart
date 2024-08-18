import 'package:flutter/cupertino.dart';
import 'package:wls_pos/scan_and_play/withdrawalScreen/repository/withdrawal_repository.dart';

import '../../utility/app_constant.dart';
import '../../utility/result.dart';
import '../../utility/user_info.dart';
import '../depositScreen/model/qrCodeResponse.dart';
import 'model/Pending_withdrawal_response.dart';
import 'model/update_qr_withdrawal_response.dart';


class WithdrawalLogic {
  static Future<Result<dynamic>> pendingWithdrawal(
      BuildContext context, Map<String, String> param) async {
    Map<String, String> header = {
      "merchantPwd"  : merchantPwd,
      "merchantId"  : '1',
      "Authorization" : "Bearer ${UserInfo.userToken}",
      "userId" : UserInfo.userId
    };

    dynamic jsonMap =
        await WithdrawalRepository.checkPendingQrCode(context, param, header);

    try {
      var respObj = PendingWithdrawalResponse.fromJson(jsonMap);
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


  static Future<Result<dynamic>> updatePendingWithdrawal(
      BuildContext context, Map<String, dynamic>? requestBody) async {

    Map<String, String> header = {
      "merchantPwd"  : merchantPwd,
      "merchantId"  : '1',
      "Authorization" : "Bearer ${UserInfo.userToken}",
      "userId" : UserInfo.userId
    };


    dynamic jsonMap =
    await WithdrawalRepository.updatePendingQrCode(context, header,requestBody);

    try {
      var respObj = UpdateQRWithdrawalResponse.fromJson(jsonMap);
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

    dynamic jsonMap = await WithdrawalRepository.scanQrCodeResponse(
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

}
