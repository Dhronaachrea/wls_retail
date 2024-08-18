import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_base_url.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/api_relative_urls.dart';
import 'package:wls_pos/network/network_utils.dart';

class SportsLotteryGameRepository {
  static dynamic callSportsLotteryGameList(BuildContext context, Map<String, String> param) async =>
      await CallApi.callApi(sportsBaseUrl, MethodType.get, getGamesWithDraw, params: param);
  static dynamic callRePrint(BuildContext context,  Map<String, String> header,Map<String, dynamic> param,) async =>
      await CallApi.callApi(sportsBaseUrl, MethodType.get, spReprint, params: param, headers:header );
}