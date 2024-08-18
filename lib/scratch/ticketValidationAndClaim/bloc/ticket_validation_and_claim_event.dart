import 'package:flutter/cupertino.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';

abstract class TicketValidationAndClaimEvent {}

class TicketValidationAndClaimApi extends TicketValidationAndClaimEvent {
  BuildContext context;
  MenuBeanList? scratchList;
  String? barCodeText;

  TicketValidationAndClaimApi({required this.context, required this.scratchList, required this.barCodeText});
}

class TicketClaimApi extends TicketValidationAndClaimEvent {
  BuildContext context;
  MenuBeanList? scratchList;
  String? barCodeText;

  TicketClaimApi({required this.context, required this.scratchList, required this.barCodeText});
}