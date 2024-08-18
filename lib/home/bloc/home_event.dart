import 'package:flutter/cupertino.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';

abstract class HomeEvent {}

class GetUserMenuListApiData extends HomeEvent {
  BuildContext context;

  GetUserMenuListApiData({required this.context});
}

class GetConfigData extends HomeEvent {
  BuildContext context;

  GetConfigData({required this.context});
}

class RePrintApi extends HomeEvent {
  BuildContext context;
  UrlDrawGameBean? apiUrlDetails;

  RePrintApi({required this.context, required this.apiUrlDetails});
}

class CancelTicketApi extends HomeEvent {
  BuildContext context;
  UrlDrawGameBean? apiUrlDetails;

  CancelTicketApi({required this.context, required this.apiUrlDetails});
}
