part of 'bingo_bloc.dart';

abstract class BingoState {}

class BingoInitial extends BingoState {}

class PickingNumber extends BingoState {}

class PickedNumber extends BingoState {
  PickNumberResponse response;

  PickedNumber({required this.response});
}

class PickNumberError extends BingoState {
  String errorMessage;

  PickNumberError({required this.errorMessage});
}
