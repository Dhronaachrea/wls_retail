import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/game_result/models/response/gameResultApiResponse.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/draw_result.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class GameResultDetailsScreen extends StatefulWidget {
  Content? contentValue;

  GameResultDetailsScreen({Key? key, this.contentValue}) : super(key: key);

  @override
  _GameResultDetailsScreenState createState() =>
      _GameResultDetailsScreenState();
}

class _GameResultDetailsScreenState extends State<GameResultDetailsScreen> {
  var _mIsShimmerLoading = false;
  List<OneXTwo>? oneXTwo;
  List<OneXTwo>? halfTimeOneXTwo;

  @override
  Widget build(BuildContext context) {
    oneXTwo = widget.contentValue!.marketWiseEventList.oneXTwo;
    halfTimeOneXTwo = widget.contentValue!.marketWiseEventList.tossWinner;
    return WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        backgroundColor: _mIsShimmerLoading
            ? WlsPosColor.light_dark_white
            : WlsPosColor.white,
        appBarTitle: const Text("Detailed Last Result",
            style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DrawResult(contentValue: widget.contentValue).pOnly(top: 10),
              Flexible(
                  child: Container(
                      padding: const EdgeInsets.all(15),
                      margin: EdgeInsets.only(
                          top: 8, left: 10, right: 10, bottom: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: WlsPosColor.white_two),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(2))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ListView.builder(
                                itemCount: oneXTwo!.length,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                color: WlsPosColor.navy_blue,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  oneXTwo![index].eventId,
                                                  style: TextStyle(
                                                      color: WlsPosColor.white),
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(oneXTwo![index]
                                                      .marketName),
                                                  Text(
                                                      formatDate(
                                                        date: oneXTwo![index]
                                                                .eventDate
                                                                .toString() ??
                                                            '14:30',
                                                        inputFormat: Format
                                                            .apiDateFormat2,
                                                        outputFormat:
                                                            Format.dateFormat13,
                                                      ),
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 14.0)),
                                                ],
                                              ).pOnly(left: 5)
                                            ],
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            color: WlsPosColor.tomato,
                                            alignment: Alignment.center,
                                            child: Text(
                                              getResultFirstLetter(
                                                  oneXTwo![index].result),
                                              style: TextStyle(
                                                  color: WlsPosColor.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      FittedBox(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(oneXTwo![index].homeTeam,
                                                    style: TextStyle(
                                                        color: WlsPosColor
                                                            .navy_blue,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: WlsPosColor
                                                        .yellow_orange_three,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'vs',
                                                  ),
                                                ).pOnly(left: 5, right: 5),
                                                Text(oneXTwo![index].awayTeam,
                                                    style: TextStyle(
                                                        color: WlsPosColor
                                                            .navy_blue,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ).pOnly(top: 5, bottom: 15),
                                      ),
                                      MySeparator(
                                        width: 5,
                                        color: WlsPosColor.pinkish_grey_two,
                                      )
                                    ],
                                  ).pOnly(bottom: 15);
                                }),
                          ),
                          Flexible(
                            child: ListView.builder(
                                itemCount: halfTimeOneXTwo!.length,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 30,
                                                height: 30,
                                                color: WlsPosColor.navy_blue,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  halfTimeOneXTwo![index]
                                                      .eventId,
                                                  style: TextStyle(
                                                      color: WlsPosColor.white),
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(halfTimeOneXTwo![index]
                                                      .marketName),
                                                  Text(
                                                      formatDate(
                                                        date: halfTimeOneXTwo![
                                                                    index]
                                                                .eventDate
                                                                .toString() ??
                                                            '14:30',
                                                        inputFormat: Format
                                                            .apiDateFormat2,
                                                        outputFormat:
                                                            Format.dateFormat13,
                                                      ),
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 14.0)),
                                                ],
                                              ).pOnly(left: 5)
                                            ],
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            color: WlsPosColor.tomato,
                                            alignment: Alignment.center,
                                            child: Text(
                                              getResultFirstLetter(
                                                  halfTimeOneXTwo![index]
                                                      .result),
                                              style: TextStyle(
                                                  color: WlsPosColor.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      FittedBox(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                    halfTimeOneXTwo![index]
                                                        .homeTeam,
                                                    style: TextStyle(
                                                        color: WlsPosColor
                                                            .navy_blue,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: WlsPosColor
                                                        .yellow_orange_three,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'vs',
                                                  ),
                                                ).pOnly(left: 5, right: 5),
                                                Text(
                                                    halfTimeOneXTwo![index]
                                                        .awayTeam,
                                                    style: TextStyle(
                                                        color: WlsPosColor
                                                            .navy_blue,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ).pOnly(top: 5, bottom: 15),
                                      ),
                                      MySeparator(
                                        width: 5,
                                        color: WlsPosColor.pinkish_grey_two,
                                      )
                                    ],
                                  ).pOnly(bottom: 15);
                                }),
                          )
                        ],
                      ))),
            ],
          ),
        ));
  }

  String getResultFirstLetter(Result1 result) {
    if (result.name.isNotEmpty) {
      return result.name[0];
    } else {
      return '';
    }
  }
}
