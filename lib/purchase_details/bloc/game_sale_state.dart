part of 'game_sale_bloc.dart';

@immutable
abstract class GameSaleState {}

class GameSaleInitial extends GameSaleState {}

class SellingGame extends GameSaleState {}

class GameSaleError extends GameSaleState {
  final String errorMessage;

  GameSaleError({required this.errorMessage});
}

class GameSaleSuccess extends GameSaleState {
  final SaleResponseModel response;
  GameSaleSuccess({required this.response});
}
