class CardModel {
  late List<String> cardNumberList;
  late String numberString;
  late bool isSelected;

  CardModel({
    required this.cardNumberList,
    required this.numberString,
    this.isSelected = false,
  });

  CardModel.fromJson(Map<String, dynamic> json) {
    cardNumberList = json['cardNumberList'];
    isSelected = json['isSelected'];
    numberString = json['numberString'];
  }

  toJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cardNumberList'] = cardNumberList;
    data['isSelected'] = isSelected;
    data['numberString'] = numberString;
    return data;
  }
}
