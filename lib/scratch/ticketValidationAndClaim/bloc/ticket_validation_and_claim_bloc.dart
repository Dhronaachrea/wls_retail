import 'dart:async';

import 'package:wls_pos/scratch/ticketValidationAndClaim/model/request/ticket_claim_request.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/model/request/ticket_validation_request.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/bloc/ticket_validation_and_claim_event.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/bloc/ticket_validation_and_claim_state.dart';
import 'package:wls_pos/scratch/ticketValidationAndClaim/ticket_validationa_and_claim_logic.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';

import '../model/response/ticket_claim_response.dart';
import '../model/response/ticket_validation_response.dart';

class TicketValidationAndClaimBloc extends Bloc<TicketValidationAndClaimEvent, TicketValidationAndClaimState> {
  TicketValidationAndClaimBloc() : super(TicketValidationAndClaimInitial()) {
    on<TicketValidationAndClaimApi>(_onTicketValidationAndClaimEvent);
    on<TicketClaimApi>(_onTicketClaimEvent);
  }

  FutureOr<void> _onTicketClaimEvent(TicketClaimApi event, Emitter<TicketValidationAndClaimState> emit) async  {
    emit(TicketClaimLoading());

    BuildContext context  = event.context;
    var scratchList       = event.scratchList;

    var response = await TicketValidationAndClaimLogic.callTicketClaimData(
        context,
        TicketClaimRequest(
            barcodeNumber: event.barCodeText.toString(),// double.parse(event.barCodeText.toString()??"0"),
            modelCode: androidInfo?.model == "V2" || androidInfo?.model == "M1" ? "NA" : null,
            requestId: 1234,
            terminalId: androidInfo?.model == "V2" || androidInfo?.model == "M1" ? 12345678901 : null,
            userName: UserInfo.userName,
            userSessionId:UserInfo.userToken
        ).toJson(),
        scratchList);

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(TicketClaimError(errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            TicketClaimResponse successResponse = value as TicketClaimResponse;
            emit(TicketClaimSuccess(response: successResponse));
          },
          responseFailure: (value) {
            print("bloc responseFailure:");
            TicketClaimResponse errorResponse = value as TicketClaimResponse;
            emit(TicketClaimError(errorMessage: errorResponse.responseMessage ?? "responseFailure"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(TicketClaimError(errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
      emit(TicketClaimError(errorMessage: "Technical Issue !"));
    }

  }
}

_onTicketValidationAndClaimEvent(TicketValidationAndClaimApi event, Emitter<TicketValidationAndClaimState> emit) async {
  emit(TicketValidationAndClaimLoading());

  BuildContext context  = event.context;
  var scratchList       = event.scratchList;

  /*{
    "barcodeNumber": "123456789000",
  "modelCode": "V2PRO",
  "terminalId": "NA",
  "userName": "demoret5",
  "userSessionId": "drxR2jMZvGO7MHKB-zZYCTJq529HVORqnh4qq6j0_x0"
  }*/

  var response = await TicketValidationAndClaimLogic.callTicketValidationAndClaimData(
      context,
      // SaleTicketRequest(
      //     gameType: "Scratch",
      //     soldChannel: "MOBILE",
      //     ticketNumberList: [
      //       event.barCodeText.toString(),
      //     ] ,
      //     userName: UserInfo.userName,
      //     modelCode: "V2PRO",
      //     terminalId: "NA",
      //     userSessionId: UserInfo.userToken
      // ).toJson(),
      TicketValidationRequest(
        barcodeNumber:  event.barCodeText.toString(),
          userName: UserInfo.userName,
          userSessionId:UserInfo.userToken
      ).toJson(),
      scratchList);

  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(TicketValidationAndClaimError(errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          TicketValidationResponse successResponse = value as TicketValidationResponse;
          emit(TicketValidationAndClaimSuccess(response: successResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          TicketValidationResponse errorResponse = value as TicketValidationResponse;
          emit(TicketValidationAndClaimError(errorMessage: errorResponse.responseMessage ?? "responseFailure"));
        },
        failure: (value) {
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(TicketValidationAndClaimError(errorMessage: value["occurredErrorDescriptionMsg"]));
        });
  } catch (e) {
    print("error=========> $e");
    emit(TicketValidationAndClaimError(errorMessage: "Technical Issue !"));
  }
}
