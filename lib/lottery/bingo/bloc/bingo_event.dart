part of 'bingo_bloc.dart';

abstract class BingoEvent {}

class PickNumber extends BingoEvent{
  BuildContext context;
  PickNumber({required this.context});
}
