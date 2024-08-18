import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/network_utils.dart';

class SaleTicketRepository {
  static dynamic callSaleTicket(
      BuildContext context,
      Map<String, dynamic> param,
      Map<String, String> header,
      String basePath,
      String relativeUrl
      ) async =>
      await CallApi.callApi(basePath, MethodType.post, relativeUrl, requestBody: param, headers: header);
}
