import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/purchase_details/model/response/sale_response_model.dart' as sleResponse;
import 'package:wls_pos/sportsLottery/bloc/ledger_report_state.dart';
import 'package:wls_pos/sportsLottery/bloc/sports_lottery_game_bloc.dart';
import 'package:wls_pos/sportsLottery/bloc/sports_lottery_game_event.dart';
import 'package:wls_pos/sportsLottery/models/response/reprint_main_addOn_response.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';
import 'package:wls_pos/utility/my_timer.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/widgets/primary_button.dart';
import 'package:wls_pos/utility/widgets/show_snackbar.dart';
import 'package:wls_pos/utility/widgets/wls_pos_divider.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

import '../lottery/widgets/printing_dialog.dart';
import '../utility/utils.dart';
import 'models/response/sp_reprint_response.dart' as spPrintResponse;

class SportsLotteryScreen extends StatefulWidget {
  const SportsLotteryScreen({Key? key}) : super(key: key);

  @override
  State<SportsLotteryScreen> createState() => _SportsLotteryScreenState();
}

class _SportsLotteryScreenState extends State<SportsLotteryScreen> {
  final bool _mIsShimmerLoading = false;

  @override
  void initState() {
    BlocProvider.of<SportsLotteryGameBloc>(context)
        .add(GetSportsLotteryGameApiData(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = (orientation == Orientation.landscape);
    double bottomButtonWidth = context.screenWidth * 0.25;
    return WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        backgroundColor: _mIsShimmerLoading
            ? WlsPosColor.light_dark_white
            : WlsPosColor.white,
        appBarTitle: const Text("Sports Lottery",
            style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: BlocConsumer<SportsLotteryGameBloc, SportsLotteryGameState>(
          listener: (context, state){
            if(state is RePrintSuccess){
              spPrintResponse.SpRePrintResponse response = state.response;
              String? selectionString = response.responseData?.selectionJson;
              if(selectionString!= null){
                String formattedSelectionString = selectionString.replaceAll("\\","",);
                var selectionJson = json.decode(formattedSelectionString);
               var reprintMainAndAddOnDraw =  ReprintMainAndAddOnDraw.fromJson(selectionJson);
                // ReprintMainAndAddOnDraw reprintMainAndAddOnDraw = ReprintMainAndAddOnDraw(
                //   mainDraw: selectionJson["mainDraw"],
                //   addOnDraw: selectionJson["addOnDraw"],
                // );
                //ReprintMainAndAddOnDraw reprintMainAndAddOnDraw = selectionJson as ReprintMainAndAddOnDraw;

                sleResponse.SaleResponseModel saleResponseModel = sleResponse.SaleResponseModel(
                  responseData: sleResponse.ResponseData(
                    transactionDateTime: response.responseData?.createdAt,// for reprint only
                    ticketNumber: response.responseData?.ticketNo ?? "",
                    drawDateTime: response.responseData?.drawDateTime ?? "",
                    drawNo: response.responseData?.drawNo,
                      totalSaleAmount: response.responseData?.saleAmount,
                    gameCode:  response.responseData?.merchantGameCode,
                    mainDrawData: sleResponse.MainDrawData(
                      boards: reprintMainAndAddOnDraw.mainDraw,
                    ),
                    addOnDrawData: sleResponse.MainDrawData(
                      boards: reprintMainAndAddOnDraw.addOnDraw,
                    ),
                  )

                );
                Map<String,dynamic> printingDataArgs = {};
                log("saleResponseModel: $saleResponseModel");
                printingDataArgs["saleResponse"]  = jsonEncode(saleResponseModel);
                printingDataArgs["username"]      = UserInfo.userName;
                printingDataArgs["currencyCode"]  = getDefaultCurrency(getLanguage());
                printingDataArgs["reprint"] = true;
                PrintingDialog().show(context: context, title: "Printing started", isCloseButton: true, buttonText: 'Retry', printingDataArgs: printingDataArgs, isSportsPoolSale: true, isRePrint: true, onPrintingDone:() {
                }, isPrintingForSale: false);
              }

            } else if (state is RePrintError){
              log("reprint error custom");
              ShowToast.showToast(context, state.errorMessage, type: ToastType.ERROR);
            }
          },
            buildWhen: (previous, current){
            if(current is RePrintSuccess || current is RePrintError || current is RePrintLoading){
              return false;
            } else {
              return true;
            }
            },
            builder: (context, state) {
          if (state is SportsLotteryGameLoading) {
            return Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            ).p(10);
          } else if (state is SportsLotteryGameSuccess) {
            SportsLotteryGameApiResponse sportsLotteryGameApiResponse =
                state.sportsLotteryGameApiResponse;
            List<ResponseData>? responseData =
                sportsLotteryGameApiResponse.responseData;
            List<ResponseData>? gameListData = <ResponseData>[];
            for (var gameList in responseData!) {
              if (gameList.drawData!.isNotEmpty) {
                gameListData.add(gameList);
              }
            }
            return Stack(
              children: [
                SingleChildScrollView(
                  child: gameListData.isNotEmpty
                      ? Column(
                          children: [
                            GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: isLandscape ? 0.7 : 0.6,
                                  crossAxisCount: isLandscape ? 7 : 2,
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 20,
                                ),
                                padding: EdgeInsets.zero,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: gameListData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Ink(
                                    decoration: const BoxDecoration(
                                      color: WlsPosColor.white,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: WlsPosColor.warm_grey_six,
                                          blurRadius: 2.0,
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        // if (gameListData[index].hasAddOnDraw !=
                                        //         null &&
                                        //     gameListData[index].hasAddOnDraw == 1) {

                                        gameListData[index].drawData!.length > 1
                                            ? Navigator.pushNamed(
                                                context,
                                                WlsPosScreen.pick4DrawScreen,
                                                arguments: [
                                                  gameListData[index],
                                                  gameListData[index].drawData!
                                                ],
                                              )
                                            : Navigator.pushNamed(
                                                context,
                                                WlsPosScreen
                                                    .sportsCricketScreen,
                                                arguments: [
                                                  gameListData[index],
                                                  gameListData[index]
                                                      .drawData![0]
                                                ],
                                              );
                                        // }
                                        // else {
                                        //   Navigator.pushNamed(
                                        //     context,
                                        //     WlsPosScreen.sportsGameScreen,
                                        //     arguments: gameListData[index],
                                        //   );
                                        // }
                                      },
                                      customBorder: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Ink(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Container(
                                            //   padding: EdgeInsets.all(5),
                                            //   width: context.screenWidth,
                                            //   alignment: Alignment.center,
                                            //   decoration: BoxDecoration(
                                            //       color:
                                            //           WlsPosColor.butterscotch,
                                            //       border: Border.all(
                                            //           color: WlsPosColor.tomato,
                                            //           width: 3),
                                            //       borderRadius:
                                            //           BorderRadius.only(
                                            //               topLeft:
                                            //                   Radius.circular(
                                            //                       10),
                                            //               topRight:
                                            //                   Radius.circular(
                                            //                       10))),
                                            //   child: Column(
                                            //     mainAxisSize: MainAxisSize.min,
                                            //     children: [
                                            //       Text('jackpot'.toUpperCase(),
                                            //               style: TextStyle(
                                            //                   fontSize: 11,
                                            //                   color: WlsPosColor
                                            //                       .dark_green))
                                            //           .pOnly(bottom: 2),
                                            //       Text(
                                            //           gameListData![index]
                                            //               .drawData![0]
                                            //               .jackpotAmount
                                            //               .toString(),
                                            //           style: TextStyle(
                                            //               fontSize: 15,
                                            //               fontWeight:
                                            //                   FontWeight.bold,
                                            //               color: WlsPosColor
                                            //                   .dark_red))
                                            //     ],
                                            //   ),
                                            // ),
                                            const SizedBox(height: 20,),
                                            Image.asset(
                                              width: 100,
                                              height: 100,
                                              "assets/images/game_${gameListData[index].gameCode?.toUpperCase()}.png",
                                              errorBuilder: (context, exception,
                                                  stackTrace) {
                                                return Image.asset(
                                                  "assets/sports_pool/sports_image.png",
                                                  width: 100,
                                                  height: 100,
                                                );
                                              },
                                            ),
                                            WlsDivider(
                                                dividerWidth: isLandscape ? 0.04 : 0.18,
                                                dividerHeight: 1,
                                                thickness: 1),
                                            Text(
                                                    gameListData[index]
                                                        .drawData![0]
                                                        .gameName!,
                                                    style: const TextStyle(
                                                        color:
                                                            WlsPosColor.black,
                                                        fontWeight:
                                                            FontWeight.bold))
                                                .pOnly(top: 10),
                                            WlsDivider(
                                              dividerColor:
                                                  WlsPosColor.light_grey,
                                              dividerHeight: 1,
                                              thickness: 1,
                                              dividerWidth: 0.001,
                                            ),
                                            Column(
                                              children: [
                                                const Text('Starts in: ',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: WlsPosColor
                                                            .light_grey)),
                                                MyTimer(
                                                  updatedAt: DateTime.now().toString(),
                                                    createdAt: gameListData[index]
                                                          .drawData![0]
                                                          .drawFreezeTime,
                                                    // createdAt:
                                                    //     gameListData![index]
                                                    //         .drawData![0]
                                                    //         .drawFreezeTime,
                                                    // updatedAt: responseData![index].updatedAt
                                                    // updatedAt:
                                                    //     '2020-10-14T03:04:39.000+00:00',
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).p(10),
                          ],
                        ).pOnly(bottom: context.screenHeight * 0.2)
                      : Container(
                          height: context.screenHeight - 200,
                          alignment: Alignment.center,
                          child: const Text('No Games Available!',
                              style: TextStyle(
                                  fontSize: 16, color: WlsPosColor.black)),
                        ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: WlsPosColor.light_grey,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PrimaryButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, WlsPosScreen.gameResultScreen,
                                  arguments: gameListData);
                            },
                            width: bottomButtonWidth,
                            height: 40,
                            text: 'View Results',
                            borderRadius: 10,
                            textSize: 16,
                            fontWeight: FontWeight.normal,
                            fillEnableColor: Colors.transparent,
                            borderColor: Colors.transparent,
                            textColor: WlsPosColor.black,
                          ),
                          SizedBox(
                            height: 30,
                            child: VerticalDivider(
                              color: WlsPosColor.black.withOpacity(0.4),
                              thickness: 2,
                            ),
                          ),
                          PrimaryButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, WlsPosScreen.qrScanScreen,
                                  arguments: 'Win Claim');
                            },
                            width: bottomButtonWidth,
                            height: 40,
                            text: 'Win Claim',
                            textSize: 16,
                            fontWeight: FontWeight.normal,
                            borderRadius: 10,
                            fillEnableColor: Colors.transparent,
                            borderColor: Colors.transparent,
                            textColor: WlsPosColor.black,
                          ),
                          SizedBox(
                            height: 30,
                            child: VerticalDivider(
                              color: WlsPosColor.black.withOpacity(0.4),
                              thickness: 2,
                            ),
                          ),
                          PrimaryButton(
                            onPressed: () async {
                              log("on reprint");
                              String? storedOrderId = await UserInfo.getSportsPoolLastOrderId;
                              String? storedItemId = await UserInfo.getSportsPoolLastItemId;
                              log("storedOrderId $storedOrderId storedItemId $storedItemId");
                             if (storedOrderId.isNotEmptyAndNotNull && storedItemId.isNotEmptyAndNotNull ) {
                                BlocProvider.of<SportsLotteryGameBloc>(context).add(
                                    RePrintApi(
                                        context:context,
                                    )
                                );
                              } else{
                                ShowToast.showToast(context, "Last ticket already cancelled.", type: ToastType.ERROR);
                              }
                            },
                            width: bottomButtonWidth,
                            height: 40,
                            text: 'Reprint',
                            textSize: 16,
                            fontWeight: FontWeight.normal,
                            borderRadius: 10,
                            fillEnableColor: Colors.transparent,
                            borderColor: Colors.transparent,
                            textColor: WlsPosColor.black,
                          )
                        ],
                      ).pOnly(left: 10, right: 10),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is SportsLotteryGameError) {
            // var errorMsg = state.errorMessage;
            return Container(
              alignment: Alignment.center,
              child: Text('errorMsg'),
            ).p(10);
          }
          return SingleChildScrollView(
            child: Column(
              children: [Text('Loading...')],
            ),
          );
        }));
  }
}
