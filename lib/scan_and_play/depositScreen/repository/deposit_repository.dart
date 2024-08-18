import 'package:flutter/cupertino.dart';

import '../../../network/api_base_url.dart';
import '../../../network/api_call.dart';
import '../../../network/api_relative_urls.dart';
import '../../../network/network_utils.dart';

class DepositRepository {
  static dynamic depositAmount(BuildContext context, Map<String, String> header,
          String url, Map<String, dynamic>? requestBody) async =>
      await CallApi.callApi(
          rmsScanAndPlayBackendUrl, MethodType.post, depositAmountApi,
          headers: header, requestBody: requestBody);


  static dynamic checkAvailability(
          BuildContext context,
          Map<String, String> header,
          String url,
          Map<String, dynamic>? requestBody) async =>
      await CallApi.callApi(
          rmsScanAndPlayWeaverUrl, MethodType.post, checkAvailabilityApi,
          headers: header, requestBody: requestBody);


  static dynamic sendOtpResponse(
          BuildContext context,
          Map<String, String> header,
          String url,
          Map<String, String> param) async =>
      await CallApi.callApi(rmsScanAndPlayRamUrl, MethodType.get, sendOtp,
          headers: header, params: param);


  static dynamic scanQrCodeResponse(
          BuildContext context,
          Map<String, String> header,
          String url,
          Map<String, String> param) async =>
      await CallApi.callApi(
          rmsScanAndPlayRamUrl, MethodType.get, qrCodeResponse,
          headers: header, params: param);


  static dynamic couponReversalApi(
          BuildContext context,
          Map<String, String> header,
          String url,
          Map<String, dynamic>? requestBody) async =>
      await CallApi.callApi(
          rmsScanAndPlayBackendUrl, MethodType.post, couponReversal,
          headers: header, requestBody: requestBody);

  static dynamic rePrintQrCodeResponse(
      BuildContext context,
      Map<String, String> header,
      String url,
      Map<String, String> param) async =>
      await CallApi.callApi(
          rmsScanAndPlayRamUrl, MethodType.get, rePrintQrCode,
          headers: header, params: param);


}
