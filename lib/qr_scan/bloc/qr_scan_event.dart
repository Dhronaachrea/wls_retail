import 'package:flutter/cupertino.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';

abstract class QrScanEvent {}

class GetWinClaimDataApi extends QrScanEvent {
  BuildContext context;
  String? barCodetext;

  GetWinClaimDataApi({required this.context, required this.barCodetext});
}
