part of 'game_sale_bloc.dart';

@immutable
abstract class GameSaleEvent {}

class GameSale extends GameSaleEvent {
  final BuildContext context;
  final SportsPoolSaleModel? sportsPoolSaleModel;

  GameSale({required this.context, required this.sportsPoolSaleModel});
}
