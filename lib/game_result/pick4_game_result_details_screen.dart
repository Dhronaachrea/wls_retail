import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/game_result/models/response/pick4GameResultApiResponse.dart';
import 'package:wls_pos/game_result/widgets/game4DrawResult.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class Pick4GameResultDetailsScreen extends StatefulWidget {
  Pick4Content? contentValue;

  Pick4GameResultDetailsScreen({Key? key, this.contentValue}) : super(key: key);

  @override
  _Pick4GameResultDetailsScreenState createState() =>
      _Pick4GameResultDetailsScreenState();
}

class _Pick4GameResultDetailsScreenState
    extends State<Pick4GameResultDetailsScreen> {
  var _mIsShimmerLoading = false;
  List<Winner>? winner;

  @override
  Widget build(BuildContext context) {
    winner = widget.contentValue!.marketWiseEventList.winner;
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
              Game4DrawResult(contentValue: widget.contentValue).pOnly(top: 10),
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
                                itemCount: winner!.length,
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
                                                  winner![index].eventId,
                                                  style: TextStyle(
                                                      color: WlsPosColor.white),
                                                ),
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(winner![index].eventName,
                                                      style: TextStyle(
                                                          // color: WlsPosColor .brownish_grey,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 14.0)),
                                                  Container(
                                                    width: context.screenWidth *
                                                        0.55,
                                                    child: Text(
                                                        getWinnersName(
                                                            winner![index]
                                                                .results,
                                                            'winnername'),
                                                        style: TextStyle(
                                                            // color: WlsPosColor .brownish_grey,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                "Roboto",
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            fontSize: 12.0)),
                                                  ),
                                                  Text(
                                                      formatDate(
                                                        date: winner![index]
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
                                                          fontSize: 12.0)),
                                                ],
                                              ).pOnly(left: 5)
                                            ],
                                          ),
                                          Container(
                                            width: context.screenWidth * 0.2,
                                            child: Container(
                                              padding: EdgeInsets.all(7),
                                              color: WlsPosColor.tomato,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                getWinnersName(
                                                    winner![index].results,
                                                    'winnernumber'),
                                                // getResultFirstLetter(
                                                //     winner![index].result),
                                                style: TextStyle(
                                                    color: WlsPosColor.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      MySeparator(
                                        width: 5,
                                        color: WlsPosColor.pinkish_grey_two,
                                      ).pOnly(top: 15)
                                    ],
                                  ).pOnly(bottom: 15);
                                }),
                          ),
                        ],
                      ))),
            ],
          ),
        ));
  }

  String getWinnersName(List<String> results, String winnerType) {
    String winnersName = '';
    String winnersNumber = '';
    results.asMap().forEach((index, element) {
      if (index == 0) {
        winnersNumber = element.split('-')[0];
        winnersName = element.split('-')[1];
      } else {
        winnersNumber = winnersNumber + ',' + element.split('-')[0];
        winnersName = winnersName + ',' + element.split('-')[1];
      }
    });
    return winnerType == 'winnername' ? winnersName : winnersNumber;
  }
}
