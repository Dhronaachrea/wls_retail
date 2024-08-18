import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/game_result/models/response/soccerGameResultApiResponse.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class SoccerDrawResult extends StatefulWidget {
  SoccerContent? contentValue;

  SoccerDrawResult({Key? key, this.contentValue}) : super(key: key);

  @override
  _SoccerDrawResultState createState() => _SoccerDrawResultState();
}

class _SoccerDrawResultState extends State<SoccerDrawResult> {
  List<OneXTwo>? fullTime;
  List<OneXTwo>? halfTime;

  @override
  Widget build(BuildContext context) {
    fullTime = widget.contentValue!.marketWiseEventList.oneXTwo;
    halfTime = widget.contentValue!.marketWiseEventList.halfTimeOneXTwo;
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: context.screenWidth * 0.46,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: WlsPosColor.white_two.withOpacity(0.4),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Draw Time',
                        style: TextStyle(
                            color: WlsPosColor.brownish_grey,
                            fontWeight: FontWeight.normal,
                            fontFamily: "Roboto",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0)),
                    Text(
                        formatDate(
                          date: widget.contentValue!.drawDate.toString() ??
                              '14:30',
                          inputFormat: Format.apiDateFormat2,
                          outputFormat: Format.dateFormat11,
                        ),
                        style: TextStyle(
                            color: WlsPosColor.brownish_grey,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Roboto",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0)),
                  ],
                )),
            Container(
                width: context.screenWidth * 0.46,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: WlsPosColor.white_two.withOpacity(0.4),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Draw No',
                        style: TextStyle(
                            color: WlsPosColor.brownish_grey,
                            fontWeight: FontWeight.normal,
                            fontFamily: "Roboto",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0)),
                    Text('${widget.contentValue!.drawNo}',
                        style: TextStyle(
                            color: WlsPosColor.brownish_grey,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Roboto",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0)),
                  ],
                )),
          ],
        ).pOnly(left: 10, right: 10),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              border: Border.all(color: WlsPosColor.white_two, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: WlsPosColor.white_two.withOpacity(0.4),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Text('Draw Result',
                      style: TextStyle(
                          color: WlsPosColor.brownish_grey,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Roboto",
                          fontStyle: FontStyle.normal,
                          fontSize: 14.0))),
              Container(
                // alignment: Alignment.center,
                height: 62,
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    halfTime != null
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(halfTime![0].marketName),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: halfTime!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0)),
                                            border: Border.all(
                                                color: WlsPosColor.white_two,
                                                width: 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment: Alignment.center,
                                                  color: WlsPosColor.white_two,
                                                  width: 25,
                                                  child: Text(
                                                      halfTime![index].eventId,
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 10.0))),
                                              Container(
                                                width: 25,
                                                height: 1,
                                                color: WlsPosColor.white_two,
                                              ),
                                              Container(
                                                  width: 25,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      getResultFirstLetter(
                                                          halfTime![index]
                                                              .result),
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.black,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 14.0),
                                                      maxLines: 1)),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                    fullTime != null
                        ? Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullTime![0].marketName),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: fullTime!.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 1),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(0)),
                                            border: Border.all(
                                                color: WlsPosColor.white_two,
                                                width: 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment: Alignment.center,
                                                  color: WlsPosColor.white_two,
                                                  width: 25,
                                                  child: Text(
                                                      fullTime![index].eventId,
                                                      style: TextStyle(
                                                          color: WlsPosColor
                                                              .brownish_grey,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 10.0))),
                                              Container(
                                                width: 25,
                                                height: 1,
                                                color: WlsPosColor.white_two,
                                              ),
                                              Container(
                                                  width: 25,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      getResultFirstLetter(
                                                          fullTime![index]
                                                              .result),
                                                      style: TextStyle(
                                                          color:
                                                              WlsPosColor.black,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily: "Roboto",
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          fontSize: 14.0),
                                                      maxLines: 1)),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              )
            ],
          ),
        ).pOnly(left: 10, right: 10),
      ],
    );
  }

  String getResultFirstLetter(Result1 result) {
    if (result.name.isNotEmpty) {
      return result.name[0];
    } else {
      return '';
    }
  }
}
