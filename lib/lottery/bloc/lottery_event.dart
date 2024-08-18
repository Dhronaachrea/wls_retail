import 'package:flutter/cupertino.dart';
import 'package:wls_pos/lottery/models/request/saleRequestBean.dart';
import 'package:wls_pos/utility/UrlDrawGameBean.dart';

import '../models/otherDataClasses/panelBean.dart';
import '../models/response/fetch_game_data_response.dart';

abstract class LotteryEvent {}

class FetchGameDataApi extends LotteryEvent {
  BuildContext context;
  List<String>? gameCodeList;

  FetchGameDataApi({required this.context, this.gameCodeList});
}


class RePrintApi extends LotteryEvent {
  BuildContext context;
  UrlDrawGameBean? apiUrlDetails;

  RePrintApi({required this.context, required this.apiUrlDetails});
}

class ResultApi extends LotteryEvent {
  BuildContext context;
  UrlDrawGameBean? apiUrlDetails;
  String toDateTime;
  String fromDateTime;
  String gameCode;

  ResultApi({required this.context, required this.apiUrlDetails, required this.fromDateTime, required this.toDateTime, required this.gameCode});
}

class LotterySaleApi extends LotteryEvent {
  BuildContext context;
  bool? isAdvancePlay;
  int? noOfDraws;
  List<Map<String, String>>? listAdvanceDraws;
  List<PanelBean>? listPanel;
  GameRespVOs? gameObjectsList;
  List<PanelData>? thaiListPanelData;
  bool? isUpdatedPayoutConfirmed;
  UrlDrawGameBean? apiUrlDetails;

  LotterySaleApi({required this.context, this.isAdvancePlay, this.noOfDraws, this.listAdvanceDraws, this.listPanel, this.gameObjectsList, this.thaiListPanelData, this.isUpdatedPayoutConfirmed, this.apiUrlDetails});
}

class CancelTicketApi extends LotteryEvent {
  BuildContext context;
  UrlDrawGameBean? apiUrlDetails;
  String? ticketNo; // this used when any error occurred during print

  CancelTicketApi({required this.context, required this.apiUrlDetails,this.ticketNo});
}

