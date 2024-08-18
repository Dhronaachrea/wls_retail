import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/logic/inv_flow_logic.dart';
import 'package:wls_pos/scratch/inventory/inventory_flow/model/response/inv_flow_response.dart';
import 'package:wls_pos/utility/user_info.dart';

part 'inv_flow_event.dart';

part 'inv_flow_state.dart';

class InvFlowBloc extends Bloc<InvFlowEvent, InvFlowState> {
  InvFlowBloc() : super(InvFlowInitial()) {
    on<InvFlowReport>(onInvFlowReport);
  }

  Future<FutureOr<void>> onInvFlowReport(
      event, Emitter<InvFlowState> emit) async {
    emit(GettingInvFlowReport());
    BuildContext context = event.context;
    MenuBeanList? menuBeanList = event.menuBeanList;
    String fromDate = event.startDate;
    String toDate = event.endDate;
    var response = await InvFlowLogic.callInvFlowReportAPI(
      context,
      menuBeanList,
      {
        "fromDate": fromDate,
        "toDate": toDate,
        "userName": UserInfo.userName,
        "userSessionId": UserInfo.userToken
      },
    );

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(InvFlowReportError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            InvFlowResponse successResponse = value as InvFlowResponse;

            emit(GotInvFlowReport(response: successResponse));
          },
          responseFailure: (value) {
            print("bloc responseFailure:");
            emit(InvFlowReportError(errorMessage: "$value"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(InvFlowReportError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }
}
