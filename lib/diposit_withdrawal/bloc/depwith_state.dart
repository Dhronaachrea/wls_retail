part of 'depwith_bloc.dart';

abstract class DepWithState {}

class DepWithInitial extends DepWithState {}

class GettingDepWith extends DepWithState {}

class GetDepWithError extends DepWithState {
  String errorMessage;
  GetDepWithError({required this.errorMessage});
}

class GetDepWithSuccess extends DepWithState {
  DepWithResponse response;
  GetDepWithSuccess({required this.response});
}
