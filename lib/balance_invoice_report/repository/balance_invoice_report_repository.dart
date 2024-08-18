import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_base_url.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/api_relative_urls.dart';
import 'package:wls_pos/network/network_utils.dart';

class BalanceInvoiceReportRepository {
  static dynamic callBalanceInvoiceReportApi(BuildContext context, Map<String, String> param, Map<String, String> header) async =>
      await CallApi.callApi(rmsBaseUrl, MethodType.get, getBalanceInvoiceReportDataApi, params: param, headers: header);
}