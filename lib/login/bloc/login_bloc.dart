import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/login/bloc/login_event.dart';
import 'package:wls_pos/login/bloc/login_state.dart';
import 'package:wls_pos/login/login_logic.dart';
import 'package:wls_pos/login/models/response/GetLoginDataResponse.dart';
import 'package:wls_pos/login/models/response/LoginTokenResponse.dart';
import 'package:wls_pos/lottery/lottery_logic.dart';
import 'package:wls_pos/lottery/models/request/fetch_game_data_request.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginTokenApi>(_onLoginTokenApiEvent);
    on<GetLoginDataApi>(_onGetLoginDataEvent);
    on<FetchGameDataApi>(_onFetchThaiGameDataEvent);
  }


  _onLoginTokenApiEvent(LoginTokenApi event, Emitter<LoginState> emit) async {
    emit(LoginTokenLoading());
    BuildContext context      = event.context;
    String userName           = event.userName;
    String encryptedPassword  = encryptMd5(event.password);

    Map<String, String> loginInfo = {
        "userName"    : userName,
        "password"    : encryptedPassword
    };

    var response = await LoginLogic.callLoginTokenApi(context, loginInfo);



    try {
      response.when(idle: () {

      },
          networkFault: (value) {
            emit(LoginTokenError(
                errorMessage: value["occurredErrorDescriptionMsg"]));
          },
          responseSuccess: (value) {
            LoginTokenResponse successResponse = value as LoginTokenResponse;
            String playerId = (successResponse.responseData?.userId != null) ? successResponse.responseData!.userId.toString() : "";
            UserInfo.setPlayerToken( successResponse.responseData?.authToken ?? "");
            UserInfo.setPlayerId(playerId);
            emit(LoginTokenSuccess(response: successResponse));
          },
          responseFailure: (value) {
            LoginTokenResponse errorResponse = value as LoginTokenResponse;
            print("bloc responseFailure: ${errorResponse.responseData?.message} =======> ");
            emit(LoginTokenError(errorMessage: errorResponse.responseData?.message ?? "Something Went Wrong!"));
          },
          failure: (value) {
            print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
            emit(LoginTokenError(errorMessage: value["occurredErrorDescriptionMsg"]));
          });
    } catch (e) {
      print("error=========> $e");
    }
  }

  _onGetLoginDataEvent(GetLoginDataApi event, Emitter<LoginState> emit) async {
    emit(LoginTokenLoading());
    BuildContext context      = event.context;

    var response = await LoginLogic.callGetLoginDataApi(context);
    response.when(idle: () {

    },
        networkFault: (value) {
          emit(GetLoginDataError(errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          print("-------------------------------------------------------------------------------------------------------------------->");
          GetLoginDataResponse successResponse = value as GetLoginDataResponse;
          UserInfo.setTotalBalance(successResponse.responseData?.data?.balance?.toString() ?? "");
          UserInfo.setOrganisation(successResponse.responseData?.data?.orgCode?.toString() ?? "");
          UserInfo.setOrganisationId(successResponse.responseData?.data?.orgId?.toString() ?? "");
          UserInfo.setUserName(successResponse.responseData?.data?.username?.toString() ?? "");
          UserInfo.setOrgName(successResponse.responseData?.data?.orgName?.toString() ?? "");
          UserInfo.setUserInfoData(jsonEncode(successResponse));
          UserInfo.setDomainId(successResponse.responseData?.data?.domainId?.toString() ?? "");
          emit(GetLoginDataSuccess(response: successResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          emit(GetLoginDataError(errorMessage: "responseFailure"));
        },
        failure: (value) {

          print("bloc failure: ${value}");
          emit(GetLoginDataError(errorMessage: "Something Went Wrong!"));
        });
    try {

    } catch (e) {
      print("error=========> $e");
    }
  }

  _onFetchThaiGameDataEvent(FetchGameDataApi event, Emitter<LoginState> emit) async{
    emit(FetchGameLoading());

    BuildContext context = event.context;

    var response = await LotteryLogic.callFetchGameData(context, FetchGameDataRequest(
        lastTicketNumber : "0",
        retailerId       : UserInfo.userId,
        sessionId         : UserInfo.userToken
    ).toJson(),
        event.gameCodeList
    );
    try {
      response.when(idle: () {

      }, networkFault: (value) {
        emit(FetchGameError(errorMessage: value["occurredErrorDescriptionMsg"]));

      }, responseSuccess: (value) {
        FetchGameDataResponse successResponse =  value as FetchGameDataResponse;

        emit(FetchGameSuccess(response: successResponse));

      }, responseFailure: (value) {
        print("bloc responseFailure:");
        emit(FetchGameError(errorMessage: "responseFailure"));

      }, failure: (value) {
        print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
        emit(FetchGameError(errorMessage: value["occurredErrorDescriptionMsg"]));
      });

    } catch(e) {
      print("error=========> $e");
    }

  }

}
