import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/network_utils.dart';

class WinningClaimRepository {
  static dynamic callTicketVerify(BuildContext context, String baseUrl, String relativeUrl, Map<String, dynamic> request, Map<String, dynamic> header) async =>
      await CallApi.callApi("https://dms-wls.infinitilotto.com/", MethodType.post, relativeUrl, requestBody: request, headers: header);

  static dynamic callClaimWinPayPwt(BuildContext context, String baseUrl, String relativeUrl, Map<String, dynamic> request, Map<String, dynamic> header) async =>
      await CallApi.callApi("https://dms-wls.infinitilotto.com/", MethodType.post, relativeUrl, requestBody: request, headers: header);
}