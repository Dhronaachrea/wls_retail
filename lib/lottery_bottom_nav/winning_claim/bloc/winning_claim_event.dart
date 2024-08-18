import 'package:flutter/cupertino.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';

import '../models/request/ClaimWinPayPwtRequest.dart';

abstract class WinningClaimEvent {}

class TicketVerifyApi extends WinningClaimEvent {
  BuildContext context;
  String ticketNumber;
  UrlDrawGameBean? apiDetails;

  TicketVerifyApi({required this.context, required this.ticketNumber, required this.apiDetails});
}

class ClaimWinPayPwtApi extends WinningClaimEvent {
  BuildContext context;
  ClaimWinPayPwtRequest request;
  UrlDrawGameBean? apiDetails;

  ClaimWinPayPwtApi({required this.context, required this.request,required this.apiDetails});
}
