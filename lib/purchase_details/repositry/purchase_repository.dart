import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_base_url.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/api_relative_urls.dart';
import 'package:wls_pos/network/network_utils.dart';

class PurchaseRepository {
  static dynamic callRetailerSaleApi(BuildContext context,
          Map<String, dynamic> param, Map<String, String> header, Map<String, dynamic>? requestBody) async =>
      await CallApi.callApi(sportsBaseUrl, MethodType.post, doRetailerSaleApi,
          params: param, headers: header, requestBody: requestBody);
}
