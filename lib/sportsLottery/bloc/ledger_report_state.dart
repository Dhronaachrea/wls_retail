import 'package:wls_pos/sportsLottery/models/response/sp_reprint_response.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';

abstract class SportsLotteryGameState {}

class SportsLotteryGameInitial extends SportsLotteryGameState {}

class SportsLotteryGameLoading extends SportsLotteryGameState{}

class SportsLotteryGameSuccess extends SportsLotteryGameState{
  SportsLotteryGameApiResponse sportsLotteryGameApiResponse;

  SportsLotteryGameSuccess({required this.sportsLotteryGameApiResponse});

}
class SportsLotteryGameError extends SportsLotteryGameState{
  String errorMessage;

  SportsLotteryGameError({required this.errorMessage});
}

//////////////////////// RePrint api ///////////////////////////////

class RePrintLoading extends SportsLotteryGameState{}

class RePrintSuccess extends SportsLotteryGameState{
  SpRePrintResponse response;

  RePrintSuccess({required this.response});
}
class RePrintError extends SportsLotteryGameState{
  String errorMessage;

  RePrintError({required this.errorMessage});
}