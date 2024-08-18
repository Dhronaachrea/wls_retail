import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wls_pos/diposit_withdrawal/depwith_logic.dart';
import 'package:wls_pos/diposit_withdrawal/model/depwith_api_request.dart';
import 'package:wls_pos/diposit_withdrawal/model/depwith_response.dart';

part 'depwith_event.dart';

part 'depwith_state.dart';

class DepWithBloc extends Bloc<DepWithEvent, DepWithState> {
  DepWithBloc() : super(DepWithInitial()) {
    on<GetDepWith>(onGetDepWith);
  }

  Future<FutureOr<void>> onGetDepWith(
      GetDepWith event, Emitter<DepWithState> emit) async {
    emit(GettingDepWith());
    BuildContext context = event.context;
    String? fromDate = event.fromDate;
    String? toDate = event.toDate;

    var response = await DepWithLogic.callDepWithApi(
        context,
        DepWithApiRequest(
          orgId: '630',
          startDate: fromDate ?? "2022-12-01",
          endDate: toDate ?? '2022-12-25',
          orgTypeCode: "RET",
        ).toJson());

    try {
      response.when(
          idle: () {},
          networkFault: (value) {
            emit(GetDepWithError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            DepWithResponse successResponse = value as DepWithResponse;

            emit(GetDepWithSuccess(response: successResponse));
          },
          responseFailure: (value) {
            print("bloc responseFailure:");
            emit(GetDepWithError(errorMessage: "$value"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(GetDepWithError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }
}
