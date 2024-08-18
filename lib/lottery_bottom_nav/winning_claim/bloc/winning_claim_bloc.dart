import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/bloc/winning_claim_event.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/bloc/winning_claim_state.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/request/ClaimWinPayPwtRequest.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/request/TicketVerifyRequest.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/response/ClaimWinResponse.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/response/TicketVerifyResponse.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/models/response/WinningClaimApiUrlsResponse.dart';
import 'package:wls_pos/lottery_bottom_nav/winning_claim/winning_claim_logic.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';
import 'package:wls_pos/utility/user_info.dart';

import '../../../lottery/models/request/RePrintRequest.dart';
import '../../../utility/app_constant.dart';

class WinningClaimBloc extends Bloc<WinningClaimEvent, WinningClaimState> {
  WinningClaimBloc() : super(WinningClaimInitial()) {
    on<TicketVerifyApi>(_onTicketVerifyEvent);
    on<ClaimWinPayPwtApi>(_onClaimWinPayPwtEvent);
  }
}

_onTicketVerifyEvent(TicketVerifyApi event, Emitter<WinningClaimState> emit) async{
  emit(TicketVerifyApiLoading());

  BuildContext context        = event.context;
  String ticketNumber         = event.ticketNumber;
  UrlDrawGameBean? apiDetails = event.apiDetails;
  String relativePath         = apiDetails?.url ?? "";
  String baseUrl              = apiDetails?.basePath ?? "";
  Map<String, dynamic> header = {
    "username" : apiDetails?.username,
    "password" : apiDetails?.password,
  };

  var response = await WinningClaimLogic.callTicketVerify(context, baseUrl, relativePath, header, TicketVerifyRequest(
      lastPWTTicket     : 0,
      merchantCode      : "LotteryRMS",
      sessionId         : UserInfo.userToken,
      ticketNumber      : ticketNumber,
      userName          : UserInfo.userName
  ).toJson());



  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(TicketVerifyError(errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          print("ticket response----------------->$value");
          TicketVerifyResponse? response = value as TicketVerifyResponse?;
          emit(TicketVerifySuccess(response: response));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          TicketVerifyResponse? errorResponse = value as TicketVerifyResponse?;
          emit(TicketVerifyError(errorMessage: errorResponse?.responseMessage ?? "responseFailure"));
        },
        failure: (value) {
          print("bloc failure: ${value}");
          emit(TicketVerifyError(errorMessage: value["occurredErrorDescriptionMsg"]));
        }
    );
  } catch(e) {
    print("error=========> $e");
    emit(TicketVerifyError(errorMessage: "Technical Issue !"));
  }

}

_onClaimWinPayPwtEvent(ClaimWinPayPwtApi event, Emitter<WinningClaimState> emit) async{
  emit(TicketVerifyApiLoading());

  BuildContext context          = event.context;
  ClaimWinPayPwtRequest request = event.request;
  String relativePath           = event.apiDetails?.url ?? "";
  String baseUrl                = event.apiDetails?.basePath ?? "";

  Map<String, dynamic> header = {
    "username": event.apiDetails?.username ?? "",
    "password": event.apiDetails?.password ?? ""
  };

  var response = await WinningClaimLogic.callClaimWinPayPwt(context, baseUrl, relativePath, header, request.toJson());
  log("-----------------response-----------------");
  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(ClaimWinPayPwtError(errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          log("ticket response----------------->$value");
          ClaimWinResponse? response = value as ClaimWinResponse?;
          emit(ClaimWinPayPwtSuccess(response: response));

        },
        responseFailure: (value) {
          print("bloc responseFailure: $value");
          ClaimWinResponse? errorResponse = value as ClaimWinResponse?;
          emit(ClaimWinPayPwtError(errorMessage: errorResponse?.responseMessage ?? "responseFailure"));

        },
        failure: (value) {
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(ClaimWinPayPwtError(errorMessage: value["occurredErrorDescriptionMsg"]));
        }
    );

  } catch(e) {
    print("error=========> $e");
    emit(ClaimWinPayPwtError(errorMessage: "Technical Issue !"));
  }

}

