import 'package:flutter/material.dart';
import 'package:wls_pos/network/api_call.dart';
import 'package:wls_pos/network/network_utils.dart';

class BingoRepository {
  static dynamic callPickNumber (BuildContext context, Map<String, dynamic> request, Map<String, String> header) async =>
      await CallApi.callApi("https://dms-wls.infinitilotto.com/", MethodType.post, "/DMS/ticket/pickednumber/BingoSeventyFive3", requestBody: request, headers: header);
}