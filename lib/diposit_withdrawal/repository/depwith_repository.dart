import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_base_url.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/api_relative_urls.dart';
import 'package:wls_pos/network/network_utils.dart';

class DepWithRepository {
  static dynamic callDepWithApi(BuildContext context, Map<String, String> param, Map<String, String> header) async =>
      await CallApi.callApi(rmsNodBaseUrl, MethodType.get, depositWithdrawalApi, params: param, headers: header);
}