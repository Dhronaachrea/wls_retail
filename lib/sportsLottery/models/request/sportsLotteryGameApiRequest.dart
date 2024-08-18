  class SportsLotteryGameApiRequest {
  String? domain;
  String? currency;
  String? merchant;

  SportsLotteryGameApiRequest(
  {this.domain, this.currency, this.merchant});

  SportsLotteryGameApiRequest.fromJson(Map<String, dynamic> json) {
  domain = json['domain'];
  currency = json['currency'];
  merchant = json['merchant'];
  }

  Map<String, String> toJson() {
  final Map<String, String> data = <String, String>{};
  data['domain'] = domain ?? "";
  data['currency'] = currency ?? "";
  data['merchant'] = merchant ?? "";
  return data;
  }
  }
