import 'package:flutter/cupertino.dart';
abstract class SportsLotteryGameEvent {}

class GetSportsLotteryGameApiData extends SportsLotteryGameEvent {
  BuildContext context;

  GetSportsLotteryGameApiData({required this.context});
}
class RePrintApi extends SportsLotteryGameEvent {
  BuildContext context;
  RePrintApi({required this.context});
}
