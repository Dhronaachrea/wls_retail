import 'package:flutter/cupertino.dart';

abstract class GameResultEvent {}

class GameResultApiData extends GameResultEvent {
  BuildContext context;
  String toDate;
  String fromDate;
  String gameId;
  String gameName;


  GameResultApiData({required this.context, required this.toDate, required this.fromDate, required this.gameId, required this.gameName});
}
