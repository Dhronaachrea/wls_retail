import 'package:wls_pos/lottery/zoo_lotto/mihar_screen.dart';

import 'bankerBean.dart';

class PanelBean {
  String? gameName;
  String? betCode;
  String? betName;
  String? pickCode;
  String? pickName;
  String? pickConfig;
  String? pickedValue;
  String? winMode;
  String? sideBetHeader;
  String? colorCode;
  int? betAmountMultiple;
  int? betAmountMultipleNumber;
  int? totalNumber;
  int? selectBetAmount;
  int? numberOfDraws;
  int? numberOfLines;
  bool? isQuickPick;
  bool? isQpPreGenerated;
  bool? isMainBet;
  double? amount;
  double? unitPrice;
  bool? isPowerBallPlus;
  List<Map<String, List<String>>>? listSelectedNumber;
  List<Map<String, List<BankerBean>>>? listSelectedNumberUpperLowerLine;
  List<ZooPickDataList>? selectedPickDataList;
  double? panelPrice; // only for twoDMyanmar
  double? doubleJackpotCost;
  double? secureJackpotCost;
  bool? isDoubleJackpotEnabled;
  bool? isSecureJackpotEnabled;

  PanelBean(
      {this.gameName,
        this.betCode,
        this.betName,
        this.pickCode,
        this.pickName,
        this.pickConfig,
        this.pickedValue,
        this.winMode,
        this.sideBetHeader,
        this.colorCode,
        this.betAmountMultiple,
        this.betAmountMultipleNumber,
        this.totalNumber,
        this.selectBetAmount,
        this.numberOfDraws,
        this.numberOfLines,
        this.isQuickPick,
        this.isQpPreGenerated,
        this.isMainBet,
        this.amount,
        this.unitPrice,
        this.listSelectedNumber,
        this.listSelectedNumberUpperLowerLine,
        this.selectedPickDataList,
        this.panelPrice,
        this.doubleJackpotCost,
        this.secureJackpotCost,
        this.isSecureJackpotEnabled,
        this.isDoubleJackpotEnabled,
      });

  PanelBean.fromJson(Map<String, dynamic> json) {
    gameName = json['gameName'];
    betCode = json['betCode'];
    betName = json['betName'];
    pickCode = json['pickCode'];
    pickName = json['pickName'];
    pickConfig = json['PickConfig'];
    pickedValue = json['pickedValue'];
    winMode = json['winMode'];
    sideBetHeader = json['sideBetHeader'];
    colorCode = json['colorCode'];
    betAmountMultiple = json['betAmountMultiple'];
    betAmountMultipleNumber = json['betAmountMultipleNumber'];
    totalNumber = json['totalNumber'];
    selectBetAmount = json['selectBetAmount'];
    numberOfDraws = json['numberOfDraws'];
    numberOfLines = json['numberOfLines'];
    isQuickPick = json['isQuickPick'];
    isQpPreGenerated = json['isQpPreGenerated'];
    isMainBet = json['isMainBet'];
    amount = json['amount'];
    unitPrice = json['unitPrice'];
    listSelectedNumber = json['listSelectedNumber'];
    listSelectedNumberUpperLowerLine = json['listSelectedNumberUpperLowerLine'];
    selectedPickDataList = json['selectedPickDataList'];
    panelPrice = json['panelPrice'];
    doubleJackpotCost = json['doubleJackpotCost'];
    secureJackpotCost = json['secureJackpotCost'];
    isDoubleJackpotEnabled = json['isDoubleJackpotEnabled'];
    isSecureJackpotEnabled = json['isSecureJackpotEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['gameName'] = this.gameName;
    data['betCode'] = this.betCode;
    data['betName'] = this.betName;
    data['pickCode'] = this.pickCode;
    data['pickName'] = this.pickName;
    data['PickConfig'] = this.pickConfig;
    data['pickedValue'] = this.pickedValue;
    data['winMode'] = this.winMode;
    data['sideBetHeader'] = this.sideBetHeader;
    data['colorCode'] = this.colorCode;
    data['betAmountMultiple'] = this.betAmountMultiple;
    data['betAmountMultipleNumber'] = this.betAmountMultipleNumber;
    data['totalNumber'] = this.totalNumber;
    data['selectBetAmount'] = this.selectBetAmount;
    data['numberOfDraws'] = this.numberOfDraws;
    data['numberOfLines'] = this.numberOfLines;
    data['isQuickPick'] = this.isQuickPick;
    data['isQpPreGenerated'] = this.isQpPreGenerated;
    data['isMainBet'] = this.isMainBet;
    data['amount'] = this.amount;
    data['unitPrice'] = this.unitPrice;
    data['listSelectedNumber'] = this.listSelectedNumber;
    data['listSelectedNumberUpperLowerLine'] = this.listSelectedNumberUpperLowerLine;
    data['selectedPickDataList'] = this.selectedPickDataList;
    data['panelPrice'] = this.panelPrice;
    data['doubleJackpotCost'] = this.doubleJackpotCost;
    data['secureJackpotCost'] = this.secureJackpotCost;
    data['isDoubleJackpotEnabled'] = this.isDoubleJackpotEnabled;
    data['isSecureJackpotEnabled'] = this.isSecureJackpotEnabled;
    return data;
  }
}
