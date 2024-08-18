import 'package:wls_pos/lottery/zoo_lotto/mihar_screen.dart';

class ZooPanelBean1 {
  String? betType;
  String? pickType;
  String? pickConfig;
  dynamic? betAmountMultiple;
  bool? quickPick;
  String? pickedValues;
  bool? qpPreGenerated;
  List<ZooPickDataList>? selectedPickDataList;

  ZooPanelBean1({
        this.betType,
        this.pickType,
        this.pickConfig,
        this.betAmountMultiple,
        this.quickPick,
        this.pickedValues,
        this.qpPreGenerated,
        this.selectedPickDataList
      });

  ZooPanelBean1.fromJson(Map<String, dynamic> json) {
    betType = json['betType'];
    pickType = json['pickType'];
    pickConfig = json['pickConfig'];
    betAmountMultiple = json['betAmountMultiple'];
    quickPick = json['quickPick'];
    pickedValues = json['pickedValues'];
    qpPreGenerated = json['qpPreGenerated'];
    selectedPickDataList = json['selectedPickDataList'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['betType'] = this.betType;
    data['pickType'] = this.pickType;
    data['pickConfig'] = this.pickConfig;
    data['betAmountMultiple'] = this.betAmountMultiple;
    data['quickPick'] = this.quickPick;
    data['pickedValues'] = this.pickedValues;
    data['qpPreGenerated'] = this.qpPreGenerated;
    data['selectedPickDataList'] = this.selectedPickDataList;
    return data;
  }
}
