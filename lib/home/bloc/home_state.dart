import 'package:wls_pos/home/models/response/get_config_response.dart';
import 'package:wls_pos/lottery/models/response/CancelTicketResponse.dart';
import 'package:wls_pos/lottery/models/response/RePrintResponse.dart';

import '../models/response/UserMenuApiResponse.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class UserMenuListLoading extends HomeState{}

class UserMenuListSuccess extends HomeState{
  UserMenuApiResponse response;

  UserMenuListSuccess({required this.response});

}
class UserMenuListError extends HomeState{
  String errorMessage;

  UserMenuListError({required this.errorMessage});
}

class  UserConfigSuccess extends HomeState{
  GetConfigResponse response;

  UserConfigSuccess({required this.response});

}
class UserConfigError extends HomeState{
  String errorMessage;

  UserConfigError({required this.errorMessage});
}

//////////////////////// RePrint api ///////////////////////////////

class RePrintLoading extends HomeState{}

class RePrintSuccess extends HomeState{
  RePrintResponse response;

  RePrintSuccess({required this.response});
}
class RePrintError extends HomeState{
  String errorMessage;
  int? errorCode;

  RePrintError({required this.errorMessage, this.errorCode});
}

//////////////////////////// Cancel Ticket ////////////////////////

class CancelTicketLoading extends HomeState{}

class CancelTicketSuccess extends HomeState{
  CancelTicketResponse response;

  CancelTicketSuccess({required this.response});
}

class CancelTicketError extends HomeState{
  String errorMessage;
  int? errorCode;

  CancelTicketError({required this.errorMessage, this.errorCode});
}