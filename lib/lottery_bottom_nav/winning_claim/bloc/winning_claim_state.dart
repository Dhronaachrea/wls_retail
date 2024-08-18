import 'package:wls_pos/lottery/models/response/RePrintResponse.dart';

import '../models/response/ClaimWinResponse.dart';
import '../models/response/TicketVerifyResponse.dart';

abstract class WinningClaimState {}

class WinningClaimInitial extends WinningClaimState {}

class TicketVerifyApiLoading extends WinningClaimState{}

class TicketVerifySuccess extends WinningClaimState{
  TicketVerifyResponse? response;

  TicketVerifySuccess({required this.response});

}
class TicketVerifyError extends WinningClaimState{
  String errorMessage;
  int? errorCode;
  TicketVerifyError({required this.errorMessage, this.errorCode});
}

class ClaimWinPayPwtSuccess extends WinningClaimState{
  ClaimWinResponse? response;
  ClaimWinPayPwtSuccess({required this.response});

}
class ClaimWinPayPwtError extends WinningClaimState{
  String errorMessage;
  int? errorCode;
  ClaimWinPayPwtError({required this.errorMessage, this.errorCode});
}