import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/logic/inv_rep_logic.dart';
import 'package:wls_pos/scratch/inventory/inventory_report/model/response/inv_rep_response.dart';
import 'package:wls_pos/utility/user_info.dart';

part 'inv_rep_event.dart';

part 'inv_rep_state.dart';

class InvRepBloc extends Bloc<InvRepEvent, InvRepState> {
  InvRepBloc() : super(InvRepInitial()) {
    on<InvRepForRetailer>(onInvRepForRetailer);
  }

  FutureOr<void> onInvRepForRetailer(
      InvRepForRetailer event, Emitter<InvRepState> emit) async {
    emit(GettingInvRepForRet());
    BuildContext context = event.context;
    MenuBeanList? menuBeanList = event.menuBeanList;
    var response = await InvRepLogic.callInvDetailsForRetailerAPI(
      context,
      menuBeanList,
      {"userName": UserInfo.userName, "userSessionId": UserInfo.userToken},
    );

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(InvRepForRetError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            InvRepResponse successResponse = value as InvRepResponse;

            emit(GotInvRepForRet(response: successResponse));
          },
          responseFailure: (value) {
            print("bloc responseFailure:");
            emit(InvRepForRetError(errorMessage: "$value"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(InvRepForRetError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }
}
