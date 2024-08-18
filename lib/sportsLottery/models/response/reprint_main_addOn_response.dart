import 'package:wls_pos/purchase_details/model/response/sale_response_model.dart';

class ReprintMainAndAddOnDraw {
  List<Boards>? mainDraw;
  List<Boards>? addOnDraw;

  ReprintMainAndAddOnDraw({this.mainDraw, this.addOnDraw});

  ReprintMainAndAddOnDraw.fromJson(Map<String, dynamic> json) {
    if (json['mainDraw'] != null) {
      mainDraw = <Boards>[];
      json['mainDraw'].forEach((v) {
        mainDraw!.add(Boards.fromJson(v));
      });
    }
    if (json['addOnDraw'] != null) {
      addOnDraw = <Boards>[];
      json['addOnDraw'].forEach((v) {
        addOnDraw!.add(new Boards.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mainDraw != null) {
      data['mainDraw'] = this.mainDraw!.map((v) => v.toJson()).toList();
    }
    if (this.addOnDraw != null) {
      data['addOnDraw'] = this.addOnDraw!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}