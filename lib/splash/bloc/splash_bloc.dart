import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:wls_pos/splash/bloc/splash_event.dart';
import 'package:wls_pos/splash/bloc/splash_state.dart';

import '../model/model/response/DefaultConfigData.dart';
import '../splash_logic.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<GetConfigData>(_onConfigEvent);
  }


  _onConfigEvent(GetConfigData event, Emitter<SplashState> emit) async {
    emit(DefaultConfigLoading());

    BuildContext context = event.context;

    var response = await SplashLogic.getDefaultConfigApi(context);

    response.when(
        idle: () {},
        networkFault: (value) {
          emit(DefaultConfigError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          DefaultDomainConfigData successResponse = value as DefaultDomainConfigData;
          emit(DefaultConfigSuccess(response: successResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          DefaultDomainConfigData errorResponse = value as DefaultDomainConfigData;
          emit(DefaultConfigError(errorMessage: errorResponse.responseMessage ?? ""));
        },
        failure: (value) {
          print("=======>${value}");
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(DefaultConfigError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        });

    try {

    } catch (e) {
      print("error=========> $e");
    }
  }


}
