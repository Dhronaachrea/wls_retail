import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:wls_pos/lottery/bingo/logic/bingo_logic.dart';
import 'package:wls_pos/lottery/bingo/model/request/pick_number_request_model.dart';
import 'package:wls_pos/lottery/bingo/model/response/pick_number_response_model.dart';
import 'package:wls_pos/utility/app_constant.dart';

part 'bingo_event.dart';

part 'bingo_state.dart';

class BingoBloc extends Bloc<BingoEvent, BingoState> {
  BingoBloc() : super(BingoInitial()) {
    on<PickNumber>(_onPickNumber);
  }

  _onPickNumber(PickNumber event, Emitter<BingoState> emit) async {
    emit(PickingNumber());
    BuildContext context = event.context;

    var response = await BingoLogic.callPickNumber(context, PickNumberRequestModel(
        betCode: "BingoSeventyFive3", drawIdList: [ 0 ], format: "string", noOfLines: numOfBingoCards, numbersPicked: "1"
    ).toJson());
    try {
      response.when(idle: () {

      }, networkFault: (value) {
        emit(PickNumberError(errorMessage: value["occurredErrorDescriptionMsg"]));

      }, responseSuccess: (value) {
        PickNumberResponse successResponse =  value as PickNumberResponse;
        emit(PickedNumber(response: successResponse));

      }, responseFailure: (value) {
        print("bloc responseFailure:");
        emit(PickNumberError(errorMessage: "responseFailure"));

      }, failure: (value) {
        print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
        emit(PickNumberError(errorMessage: value["occurredErrorDescriptionMsg"]));
      });

    } catch(e) {
      print("error=========> $e");
    }
  }
}
