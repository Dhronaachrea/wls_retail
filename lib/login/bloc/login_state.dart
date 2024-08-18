
import 'package:wls_pos/login/models/response/GetLoginDataResponse.dart';
import 'package:wls_pos/login/models/response/LoginTokenResponse.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginTokenLoading extends LoginState{}

class LoginTokenSuccess extends LoginState{
  LoginTokenResponse? response;

  LoginTokenSuccess({required this.response});

}
class LoginTokenError extends LoginState{
  String errorMessage;

  LoginTokenError({required this.errorMessage});
}

/////////////////////////////////////////////////////////////////////

class GetLoginDataLoading extends LoginState{}

class GetLoginDataSuccess extends LoginState{
  GetLoginDataResponse? response;

  GetLoginDataSuccess({required this.response});

}
class GetLoginDataError extends LoginState{
  String errorMessage;

  GetLoginDataError({required this.errorMessage});
}

////////////////////////////////////////////////////////////////////
class FetchGameLoading extends LoginState{}

class FetchGameSuccess extends LoginState{
  FetchGameDataResponse response;

  FetchGameSuccess({required this.response});

}
class FetchGameError extends LoginState{
  String errorMessage;

  FetchGameError({required this.errorMessage});
}
