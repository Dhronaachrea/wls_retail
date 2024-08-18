import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_base_url.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/api_relative_urls.dart';
import 'package:wls_pos/network/network_utils.dart';

class GameResultRepository {
  static dynamic callGameResultList(BuildContext context, Map<String, String> param) async =>
      await CallApi.callApi(sportsBaseUrl, MethodType.get, getHistoricalResults, params: param);
}