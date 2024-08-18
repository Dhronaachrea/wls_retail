import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/drawer/wls_pos_drawer.dart';
import 'package:wls_pos/lottery/models/response/ResultResponse.dart';
import 'package:wls_pos/lottery/widgets/printing_dialog.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class ResultPreview extends StatefulWidget {
  final List<ResponseData>? resultList;
  const ResultPreview({Key? key, required this.resultList}) : super(key: key);

  @override
  State<ResultPreview> createState() => _ResultPreviewState();
}

class _ResultPreviewState extends State<ResultPreview> {
  ResultData? resultInfo;

  @override
  void initState() {
    resultInfo = widget.resultList?[0].resultData?[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);

    return WlsPosScaffold(showAppBar: true,
      drawer: WlsPosDrawer(drawerModuleList: const []),
      appBarTitle: const Text("Result", style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
      backgroundColor: WlsPosColor.light_dark_white,
      body: ListView.builder(
          itemCount: resultInfo?.resultInfo?.length ?? 0,
          itemBuilder: (BuildContext ctx, int mainIndex) {
            return Align(
              alignment: Alignment.topCenter,
              child: FittedBox(
                child: Container(
                  alignment: Alignment.topCenter,
                  width: MediaQuery.of(context).size.width * (isLandscape ? 0.4 : 0.9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(width: 1),
                    color: WlsPosColor.light_dark_white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 10.0, // soften the shadow
                        spreadRadius: 2.0, //extend the shadow
                        offset: Offset(
                          1.0, // Move to right 5  horizontally
                          1.0, // Move to bottom 5 Vertically
                        ),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.black),
                                  color: WlsPosColor.white_two
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Draw Time",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: WlsPosColor.warm_grey_seven,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  Text(
                                    resultInfo?.resultInfo?[mainIndex].drawTime ?? "",
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                                ],
                              ).p(5),
                            ).pOnly(right: 10),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: Colors.black),
                                  color: WlsPosColor.white_two
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Draw No",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: WlsPosColor.warm_grey_seven,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  Text(
                                    "${resultInfo?.resultInfo?[mainIndex].drawId}",
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500
                                    ),
                                  )
                                ],
                              ).p(5),
                            ).pOnly(right: 10),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                Map<String,dynamic> printingDataArgs = {};
                                printingDataArgs["resultData"]            = jsonEncode(resultInfo?.resultInfo?[mainIndex] ?? []);
                                printingDataArgs["username"]              = UserInfo.userName;
                                printingDataArgs["currencyCode"]          = getDefaultCurrency(getLanguage());

                                PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isLastResult: true, onPrintingDone:(){
                                }, isPrintingForSale: false);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Colors.black),
                                    color: WlsPosColor.navy_blue
                                ),
                                child: const Icon(Icons.print, size: 45, color: Colors.white,),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          color: WlsPosColor.white_two,
                        ),
                        child: const Text(
                          "Draw Result",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: WlsPosColor.black),
                        ).p(5),
                      ).pOnly(top: 14),
                      (resultInfo?.resultInfo?[mainIndex].winningNo != null)
                          ? Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: const Text(
                                    "Main Bet",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 16),
                                  ).p(5),
                                ).pOnly(top: 12),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: Colors.black),
                                  ),
                                  child: Text(
                                    (resultInfo?.resultInfo?[mainIndex].winningNo ?? "").replaceAll(",", "  "),
                                    maxLines: 5,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(color: WlsPosColor.black),
                                  ).p(8),
                                ).pOnly(top: 6),
                              ],
                            )
                          : Container(),
                      (resultInfo?.resultInfo?[mainIndex].sideBetMatchInfo != null && resultInfo?.resultInfo?[mainIndex].sideBetMatchInfo?.length != 0 )
                          ? Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: const Text(
                              "Side Bet",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: WlsPosColor.black, fontWeight: FontWeight.bold, fontSize: 16),
                            ).p(5),
                          ).pOnly(top: 12),
                          Container(
                            height: 170,
                            decoration: BoxDecoration(
                                border: Border.all(width: 1)
                            ),
                            child: ListView.builder(
                                itemCount: resultInfo?.resultInfo?[mainIndex].sideBetMatchInfo?.length ?? 0,
                                padding: EdgeInsets.zero,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    children: [
                                      Text(resultInfo?.resultInfo?[mainIndex].sideBetMatchInfo?[index].betDisplayName ?? ""),
                                      Expanded(child: Container(),),
                                      Text(
                                        resultInfo?.resultInfo?[mainIndex].sideBetMatchInfo?[index].pickTypeName ?? "",
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ).pOnly(top: 4);
                                }
                            ).p(8),
                          ).pOnly(top: 6),
                        ],
                      )
                          : Container(),
                      (resultInfo?.resultInfo?[mainIndex].winningMultiplierInfo?.multiplierCode != null)
                          ? Row(
                              children: [
                                const Text("Winning Multiplier",style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16)),
                                Expanded(child: Container(),),
                                Text("${resultInfo?.resultInfo?[mainIndex].winningMultiplierInfo?.multiplierCode ?? ""} (${resultInfo?.resultInfo?[mainIndex].winningMultiplierInfo?.value ?? ""})",style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16))
                              ],
                            ).pOnly(top: 7)
                          : Container()
                    ],
                  ).p(10),
                ).pOnly(top: 10),
              ),
            ).pOnly(top: 9, bottom: 9);
          }
      ),
    );
  }
}
