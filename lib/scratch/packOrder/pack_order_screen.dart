import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/home/models/response/UserMenuApiResponse.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_bloc.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_event.dart';
import 'package:wls_pos/scratch/packOrder/bloc/pack_state.dart';
import 'package:wls_pos/scratch/packOrder/model/PackOrderRequest.dart';
import 'package:wls_pos/scratch/packOrder/model/game_details_response.dart';
import 'package:wls_pos/scratch/packOrder/model/pack_order_response.dart';
import 'package:wls_pos/utility/user_info.dart';
import 'package:wls_pos/utility/widgets/alert_dialog.dart';
import 'package:wls_pos/utility/widgets/alert_type.dart';
import 'package:wls_pos/utility/widgets/primary_button.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class PackOrderScreen extends StatefulWidget {
  final MenuBeanList? scratchList;

  const PackOrderScreen({Key? key, required this.scratchList}) : super(key: key);

  @override
  State<PackOrderScreen> createState() => _PackOrderScreenState();
}

class _PackOrderScreenState extends State<PackOrderScreen> {
  var isLoading = false;
  int? gameId;
  double bottomViewHeight = 110;
  List<Games>? gamesList = [];
  List<int> _counter = [];
  double? totalAmount = 0;
  List<GameOrderList>? gameOrderList = [];


  @override
  void initState() {
    BlocProvider.of<PackBloc>(context).add(GameDetailsApi(
      context: context,
      scratchList: widget.scratchList,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WlsPosScaffold(
        resizeToAvoidBottomInset: false,
        showAppBar: true,
        centerTitle: false,
        appBarTitle: Text(widget.scratchList?.caption ?? "Pack Order"),
        body: BlocListener<PackBloc, PackState>(
          listener: (context, state) {
            if (state is PackLoading) {
              setState(() {
                isLoading = true;
              });
            }
            if(state is GameDetailsSuccess)
            {
              gameOrderList!.clear();
              setState(() {
                isLoading = false;
              });
              GameDetailsResponse gameDetailsResponse = state.response;
              gamesList = gameDetailsResponse.games;
              for(var gameData in gamesList!)
              {
                _counter.add(0);
                gameOrderList!.add(GameOrderList(
                    booksQuantity: 0,
                    gameId: gameData.gameId
                ));
              }
            }
            if (state is PackSuccess) {
              PackOrderResponse packOrderResponse = state.response;
              setState(() {
                isLoading = false;
              });
              Alert.show(
                isDarkThemeOn: false,
                type: AlertType.success,
                buttonClick: () {
                  Navigator.of(context).pop();
                },
                title: 'Success!',
                // subtitle: packOrderResponse.responseMessage!,
                subtitle: "Order is successfully placed.\n Order Number: ${packOrderResponse.orderId}",
                buttonText: 'ok'.toUpperCase(),
                context: context,
              );
            }
            if (state is PackError) {
              setState(() {
                isLoading = false;
              });
            }
          },
          child: !isLoading ?
          Column(
            children: [
              const Text(
                 "Select Game Pack Quantity from below List",
                  style: TextStyle(
                      color:  WlsPosColor.brownish_grey_six,
                      fontWeight: FontWeight.w400,
                      fontFamily: "",
                      fontStyle:  FontStyle.normal,
                      fontSize: 14.0
                  ),
                  textAlign: TextAlign.center
              ).p(16),
              Container(
                height: 2,
                width: context.screenWidth,
                color: WlsPosColor.white,
              ),
              Expanded(
                child: Stack(children: [
                  ListView.separated(
                    itemCount: gamesList!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: WlsPosColor.game_color_pink.withOpacity(0.1),
                          //WlsPosColor.warm_grey_new.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: SvgPicture.asset("assets/scratch/pack_order.svg"),
                            ).p(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${gamesList![index].gameType!}#${gamesList![index].gameNumber.toString()}",
                                      style: const TextStyle(
                                          color: WlsPosColor. brownish_grey,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "Arial",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0),
                                      textAlign: TextAlign.left),
                                  const SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                               const TextSpan(
                                                  text: "Price: ",
                                                  style: TextStyle(
                                                      color: WlsPosColor.greyish,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: "Arial",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 14.0),
                                              ),
                                              TextSpan(
                                                  text: (gamesList![index].ticketsPerBook * gamesList![index].ticketPrice).toString(),
                                                  style: const TextStyle(
                                                      color:  WlsPosColor.tomato,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "",
                                                      fontStyle:  FontStyle.normal,
                                                      fontSize: 14.0

                                                  ),),
                                            ]
                                          ),
                                        ),
                                      ),
                                      Expanded(flex:1, child: Container(),),
                                      Expanded(
                                        flex: 2,
                                        child: RichText(
                                          text: TextSpan(
                                              children: [
                                                 const TextSpan(
                                                  text: "Commission: ",
                                                  style: TextStyle(
                                                      color: WlsPosColor.greyish,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: "Arial",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 14.0),
                                                ),
                                                TextSpan(
                                                  text: "${gamesList![index].commissionPercentage.toString()}%",
                                                  style: const TextStyle(
                                                      color:  WlsPosColor.tomato,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: "",
                                                      fontStyle:  FontStyle.normal,
                                                      fontSize: 14.0

                                                  ),),
                                              ]
                                          ),
                                        ),
                                      ),
                                    // Text("Price: ${gamesList![index].ticketPrice.toString()}",
                                    //     style: const TextStyle(
                                    //         color: WlsPosColor.greyish,
                                    //         fontWeight: FontWeight.w400,
                                    //         fontFamily: "Arial",
                                    //         fontStyle: FontStyle.normal,
                                    //         fontSize: 14.0),
                                    //     textAlign: TextAlign.left),
                                    // Text("Commission: ${gamesList![index].commissionPercentage.toString()}%",
                                    //     style: const TextStyle(
                                    //         color: WlsPosColor.greyish,
                                    //         fontWeight: FontWeight.w400,
                                    //         fontFamily: "Arial",
                                    //         fontStyle: FontStyle.normal,
                                    //         fontSize: 14.0),
                                    //     textAlign: TextAlign.left),
                                  ],)
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                _decrementCounter(index);
                              },
                              child: SizedBox(
                                height: 3,
                                width: 15,
                                child: Image.asset("assets/scratch/minus.png", color: _counter[index] <= 0 ? WlsPosColor.light_grey : WlsPosColor.navy_blue),
                              ).pSymmetric(h: 16, v: 8),
                            ),
                             Text(_counter[index].toString(),
                                style: TextStyle(
                                    color: _counter[index] > 0 ? WlsPosColor.cherry: WlsPosColor.light_grey,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Arial",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0),
                                textAlign: TextAlign.center),
                            InkWell(
                              onTap: (){
                                _incrementCounter(index);
                              },
                              child: SizedBox(
                                height: 12,
                                width: 20,
                                child: Image.asset("assets/scratch/add.png",color : WlsPosColor.navy_blue),
                              ).pSymmetric(h: 16, v: 8),
                            ),
                          ],
                        ).p(8),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        height: 2,
                        width: context.screenWidth,
                        color: WlsPosColor.white,
                      );
                    },
                  ).pOnly(bottom:bottomViewHeight ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: bottomViewHeight,
                      width: context.screenWidth,
                      color: WlsPosColor.white,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                              RichText(
                                text: TextSpan(
                                    children: [
                                       const TextSpan(
                                        text: "Total Pack ",
                                        style: TextStyle(
                                            color: WlsPosColor.brownish_grey_two,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Arial",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                      ),
                                      TextSpan(
                                        text: getTotalPack(),
                                        style: const TextStyle(
                                            color:  WlsPosColor.tomato,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "",
                                            fontStyle:  FontStyle.normal,
                                            fontSize: 14.0

                                        ),),
                                    ]
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                    children: [
                                       const TextSpan(
                                        text: "Total Amount :",
                                        style: TextStyle(
                                            color: WlsPosColor.brownish_grey_two,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "Arial",
                                            fontStyle: FontStyle.normal,
                                            fontSize: 14.0),
                                      ),
                                      TextSpan(
                                        text: totalAmount.toString(),
                                        style: const TextStyle(
                                            color:  WlsPosColor.tomato,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "",
                                            fontStyle:  FontStyle.normal,
                                            fontSize: 14.0

                                        ),),
                                    ]
                                ),
                              ),
                            ],),
                            const SizedBox(height: 5,),
                            // Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       const Text("Total Amount :",
                            //           style: TextStyle(
                            //               color: WlsPosColor.greyish,
                            //               fontWeight: FontWeight.w400,
                            //               fontFamily: "Arial",
                            //               fontStyle: FontStyle.normal,
                            //               fontSize: 14),
                            //           textAlign: TextAlign.center),
                            //       Text(totalAmount.toString(),
                            //           style: const TextStyle(
                            //               color: WlsPosColor.greyish,
                            //               fontWeight: FontWeight.w700,
                            //               fontFamily: "Arial",
                            //               fontStyle: FontStyle.normal,
                            //               fontSize: 16),
                            //           textAlign: TextAlign.center),
                            //     ]).pOnly(bottom: 10),
                            PrimaryButton(
                              height: 50,
                              btnBgColor1: totalAmount! > 0 ? WlsPosColor.tomato : WlsPosColor.tomato.withOpacity(0.2),
                              btnBgColor2: totalAmount! > 0 ? WlsPosColor.tomato : WlsPosColor.tomato.withOpacity(0.2),
                              borderRadius: 10,
                              text: "Confirm",
                              width: context.screenWidth / 0.8,
                              textColor: WlsPosColor.white,
                              onPressed: () {
                                gameOrderList!.removeWhere((element) => element.booksQuantity == 0);
                                var requestData = PackOrderRequest(
                                    gameOrderList: gameOrderList,
                                    userName: UserInfo.userName,
                                    userSessionId: UserInfo.userToken
                                );
                                if(totalAmount! > 0) {
                                  BlocProvider.of<PackBloc>(context).add(PackApi(
                                    context: context,
                                    scratchList: widget.scratchList,
                                    requestData: requestData
                                ));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
              ),
            ],
          )
          : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  _incrementCounter(int index) {
    setState(() {
      _counter[index]++;
      totalAmount = totalAmount! + (gamesList![index].ticketsPerBook * gamesList![index].ticketPrice);
    });
      gameOrderList![index] = GameOrderList(
          booksQuantity: _counter[index],
          gameId: gamesList![index].gameId
      );
  }

  _decrementCounter(int index) {
    if (_counter[index] <= 0) {
      setState(() {
        _counter[index] = 0;
        totalAmount = totalAmount! - 0 ;
      });
      gameOrderList![index] = GameOrderList(
          booksQuantity: _counter[index],
          gameId: gamesList![index].gameId
      );
    } else {
      setState(() {
        _counter[index]--;
        totalAmount = totalAmount! - (gamesList![index].ticketsPerBook * gamesList![index].ticketPrice);
      });
      gameOrderList![index] = GameOrderList(
          booksQuantity: _counter[index],
          gameId: gamesList![index].gameId
      );
    }
  }

 String getTotalPack() {
    var totalPack = 0;
    for (var element in _counter) {
totalPack = totalPack + element;
    }
    return totalPack.toString();
  }

}
