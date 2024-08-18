import 'package:wls_pos/game_result/models/response/gameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/pick4GameResultApiResponse.dart';
import 'package:wls_pos/game_result/models/response/soccerGameResultApiResponse.dart';

abstract class GameResultState {}

class GameResultInitial extends GameResultState {}

class GameResultLoading extends GameResultState{}

class GameResultSuccess extends GameResultState{
  GameResultApiResponse gameResultApiResponse;

  GameResultSuccess({required this.gameResultApiResponse});
}

class SoccerGameResultSuccess extends GameResultState{
  SoccerGameResultApiResponse soccerGameResultApiResponse;
  SoccerGameResultSuccess({required this.soccerGameResultApiResponse});
}

class Pick4GameResultSuccess extends GameResultState{
  Pick4GameResultApiResponse pick4gameResultApiResponse;
  Pick4GameResultSuccess({required this.pick4gameResultApiResponse});
}

class GameResultError extends GameResultState{
  String errorMessage;

  GameResultError({required this.errorMessage});
}