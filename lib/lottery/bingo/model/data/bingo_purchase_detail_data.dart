import 'package:wls_pos/lottery/bingo/model/data/card_model.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';

class BingoPurchaseDetailData {
  late List<CardModel> selectedCardList;

  late String betValue;
  late GameRespVOs? particularGameObjects;
  late Function(String) onComingToPreviousScreen;

  BingoPurchaseDetailData(
      {required this.selectedCardList,
      required this.betValue,
      required this.particularGameObjects, required this.onComingToPreviousScreen});

  BingoPurchaseDetailData.fromJson(Map<String, dynamic> json) {
    selectedCardList = json['selectedCardList'];
    betValue = json['betValue'];
    particularGameObjects = json['particularGameObjects'];
    onComingToPreviousScreen = json['onComingToPreviousScreen'];
  }

  toJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['selectedCardList'] = selectedCardList;
    data['betValue'] = betValue;
    data['particularGameObjects'] = particularGameObjects;
    data['onComingToPreviousScreen'] = onComingToPreviousScreen;
    return data;
  }
}
