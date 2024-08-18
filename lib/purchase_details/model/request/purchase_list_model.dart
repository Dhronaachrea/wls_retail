class PurchaseListItemModel {
  String? venueName;
  String? startTime;
  String? homeTeam;
  String? awayTeam;
  String? marketName;
  var eventGameName;
  List<String> selectedOptionList;
  List<String> selectedOptionNameList;

  PurchaseListItemModel({
    required this.venueName,
    required this.startTime,
    required this.homeTeam,
    required this.awayTeam,
    required this.marketName,
    required this.eventGameName,
    required this.selectedOptionList,
    required this.selectedOptionNameList,
  });
}
