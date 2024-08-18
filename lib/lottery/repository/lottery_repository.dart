import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_base_url.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/api_relative_urls.dart';
import 'package:wls_pos/network/network_utils.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';

class LotteryRepository {
  static dynamic callFetchGameData(BuildContext context, Map<String, dynamic> request, Map<String, String> header) async =>
      await CallApi.callApi("https://dms-wls.infinitilotto.com/", MethodType.put, "DMS/dataMgmt/fetchGameData", requestBody: request, headers: header);

  static dynamic callRePrint(BuildContext context, Map<String, dynamic> request, Map<String, String> header, String baseUrl, String relativeUrl, UrlDrawGameBean? urlsDetails) async =>
      await CallApi.callApi(urlsDetails?.basePath ?? "", MethodType.post, relativeUrl, requestBody: request, headers: header);

  static dynamic callResult(BuildContext context, Map<String, dynamic> request, Map<String, String> header, String baseUrl, String relativeUrl) async =>
      await CallApi.callApi(baseUrl, MethodType.post, relativeUrl, requestBody: request, headers: header);
//"https://dms-wls.infinitilotto.com/

  static dynamic callLotterySaleApi(BuildContext context, Map<String, dynamic> request, Map<String, String> header,String baseUrl, String relativeUrl) async =>
      await CallApi.callApi(baseUrl, MethodType.post, relativeUrl, requestBody: request, headers: header);

  static dynamic callCancelTicket(BuildContext context, Map<String, dynamic> request, Map<String, String> header, String baseUrl, String relativeUrl) async =>
      await CallApi.callApi(baseUrl, MethodType.post, relativeUrl, requestBody: request, headers: header);

}