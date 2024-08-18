import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wls_pos/game_result/bloc/game_result_event.dart';
import 'package:wls_pos/game_result/bloc/game_result_state.dart';
import 'package:wls_pos/game_result/game_result_logic.dart';
import 'package:wls_pos/game_result/models/request/gameResultApiRequest.dart';
import 'package:wls_pos/game_result/models/response/gameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/pick4GameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/soccerGameResultApiResponse.dart';

class GameResultBloc extends Bloc<GameResultEvent, GameResultState> {
  GameResultBloc() : super(GameResultInitial()) {
    on<GameResultApiData>(_onGameListEvent);
  }
}

_onGameListEvent(GameResultApiData event, Emitter<GameResultState> emit) async {
  emit(GameResultLoading());

  BuildContext context = event.context;
  String? toDate = event.toDate;
  String? fromDate = event.fromDate;
  String? gameId = event.gameId;
  String? gameName = event.gameName;

  var response = await GameResultLogic.callGameResultList(
      context,
      GameResultApiRequest(
        gameId: gameId,
        fromDate: fromDate,
        toDate: toDate,
        page: '0',
        size: '10',
      ).toJson(),
    gameName
  );

  try {
    response.when(
        idle: () {},
        networkFault: (value) {
          emit(GameResultError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        },
        responseSuccess: (value) {
          switch(gameName)
          {
            case 'SOCCER 4': {
              SoccerGameResultApiResponse soccerGameResultApiResponse =
              value as SoccerGameResultApiResponse;
              emit(SoccerGameResultSuccess(soccerGameResultApiResponse: soccerGameResultApiResponse));
            }
            break;

            case 'SOCCER 12': {
              SoccerGameResultApiResponse soccerGameResultApiResponse =
              value as SoccerGameResultApiResponse;
              emit(SoccerGameResultSuccess(soccerGameResultApiResponse: soccerGameResultApiResponse));
            }
            break;

            case 'CRICKET5': {
              GameResultApiResponse gameResultApiResponse =
              value as GameResultApiResponse;
              emit(GameResultSuccess(gameResultApiResponse: gameResultApiResponse));
            }
            break;

            case 'PICK4': {
              Pick4GameResultApiResponse pick4GameResultApiResponse =
              value as Pick4GameResultApiResponse;
              emit(Pick4GameResultSuccess(pick4gameResultApiResponse: pick4GameResultApiResponse));
            }
            break;
          }
        },
        responseFailure: (value) {
          print("bloc responseFailure:");
          emit(GameResultError(errorMessage: "responseFailure"));
        },
        failure: (value) {
          print("bloc failure: ${value["occurredErrorDescriptionMsg"]}");
          emit(GameResultError(
              errorMessage: value["occurredErrorDescriptionMsg"]));
        });
  } catch (e) {
    print("error=========> $e");
  }
}
