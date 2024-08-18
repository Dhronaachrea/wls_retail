class PickNumberRequestModel {
  String? betCode;
  List<int>? drawIdList;
  String? format;
  int? noOfLines;
  String? numbersPicked;

  PickNumberRequestModel(
      {this.betCode,
      this.drawIdList,
      this.format,
      this.noOfLines,
      this.numbersPicked});

  PickNumberRequestModel.fromJson(Map<String, dynamic> json) {
    betCode = json['betCode'];
    drawIdList = json['drawIdList'].cast<int>();
    format = json['format'];
    noOfLines = json['noOfLines'];
    numbersPicked = json['numbersPicked'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['betCode'] = this.betCode;
    data['drawIdList'] = this.drawIdList;
    data['format'] = this.format;
    data['noOfLines'] = this.noOfLines;
    data['numbersPicked'] = this.numbersPicked;
    return data;
  }
}
