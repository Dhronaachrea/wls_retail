import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/sportsLottery/bloc/ledger_report_state.dart';
import 'package:wls_pos/sportsLottery/bloc/sports_lottery_game_event.dart';
import 'package:wls_pos/sportsLottery/models/request/sp_reprint_request.dart';
import 'package:wls_pos/sportsLottery/models/request/sportsLotteryGameApiRequest.dart';
import 'package:wls_pos/sportsLottery/models/response/sp_reprint_response.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';
import 'package:wls_pos/sportsLottery/sports_lottery_game_logic.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/user_info.dart';

class SportsLotteryGameBloc
    extends Bloc<SportsLotteryGameEvent, SportsLotteryGameState> {
  SportsLotteryGameBloc() : super(SportsLotteryGameInitial()) {
    on<GetSportsLotteryGameApiData>(_onHomeEvent);
    on<RePrintApi>(_onRePrintEvent);
  }
}

_onHomeEvent(GetSportsLotteryGameApiData event,
    Emitter<SportsLotteryGameState> emit) async {
  emit(SportsLotteryGameLoading());

  BuildContext context = event.context;

  var response = await SportsLotteryGameLogic.callSportsLotteryGameList(
      context,
      SportsLotteryGameApiRequest(
              domain: sportsPoolDomainName, currency: "EUR", merchant: 'RMS')
          .toJson());

  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(SportsLotteryGameError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          SportsLotteryGameApiResponse sportsLotteryGameApiResponse = value;

          emit(SportsLotteryGameSuccess(
              sportsLotteryGameApiResponse: sportsLotteryGameApiResponse));
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          emit(SportsLotteryGameError(errorMessage: "responseFailure"));
        },
        failure: (value) {
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(SportsLotteryGameError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        });
  } catch (e) {
    print("error=========> $e");
  }
}

_onRePrintEvent(RePrintApi event, Emitter<SportsLotteryGameState> emit) async{
  emit(RePrintLoading());

  BuildContext context = event.context;
  String storedOrderId = await UserInfo.getSportsPoolLastOrderId;
  String orderId = storedOrderId.replaceAll('"', "");
  String storedItemId = await UserInfo.getSportsPoolLastItemId;
  String itemId = storedItemId.replaceAll('"', "");
  var response = await SportsLotteryGameLogic.callRePrint(context,
      SpRePrintRequest(
          orderId: orderId,
          itemId: itemId,
          deviceId: "MOBILE",
          retailerId: UserInfo.userId,
        retailerToken: UserInfo.userToken,
        domainName: sportsPoolDomainName,
      ).toJson());

  try {
    response.when(idle: () {

    }, networkFault: (value) {
      emit(RePrintError(errorMessage: value["occurredErrorDescriptionMsg"]));

    }, responseSuccess: (value) {
      SpRePrintResponse successResponse =  value as SpRePrintResponse;
     emit(RePrintSuccess(response: successResponse));

    }, responseFailure: (value) {
      print("bloc responseFailure:");
      SpRePrintResponse errorResponse =  value as SpRePrintResponse;
      emit(RePrintError(errorMessage: errorResponse.responseMessage ?? "responseFailure"));

    }, failure: (value) {
      print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
      emit(RePrintError(errorMessage: value["occurredErrorDescriptionMsg"]));
    });

  } catch(e) {
    print("error=========> $e");
    emit(RePrintError(errorMessage: "Technical Issue !"));
  }

}
