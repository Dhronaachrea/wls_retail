import 'package:flutter/cupertino.dart';

import '../../../network/api_base_url.dart';
import '../../../network/api_call.dart';
import '../../../network/api_relative_urls.dart';
import '../../../network/network_utils.dart';

class SplashRepository {


  static dynamic getDefaultConfigApi(BuildContext context) async =>
      await CallApi.callApi(rmsPamUrl, MethodType.get, defaultConfigApi);

}
