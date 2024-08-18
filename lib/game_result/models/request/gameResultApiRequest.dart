class GameResultApiRequest {
  String? gameId;
  String? fromDate;
  String? toDate;
  String? page;
  String? size;

  GameResultApiRequest(
      {this.gameId, this.fromDate, this.toDate, this.page, this.size});

  GameResultApiRequest.fromJson(Map<String, dynamic> json) {
    gameId = json['gameId'];
    fromDate = json['fromDate'];
    toDate = json['toDate'];
    page = json['page'];
    size = json['size'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['gameId'] = gameId ?? "";
    data['fromDate'] = fromDate ?? "";
    data['toDate'] = toDate ?? "";
    data['page'] = page ?? "";
    data['size'] = size ?? "";
    return data;
  }
}
