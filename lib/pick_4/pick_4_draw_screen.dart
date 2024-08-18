import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/my_timer.dart';
import 'package:wls_pos/utility/widgets/pick4Draw.dart';
import 'package:wls_pos/utility/widgets/race_container.dart';
import 'package:wls_pos/utility/widgets/wls_pos_scaffold.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

class Pick4DrawScreen extends StatefulWidget {
  List<dynamic>? args;

  Pick4DrawScreen({Key? key, required this.args}) : super(key: key);

  @override
  _Pick4DrawScreenState createState() => _Pick4DrawScreenState();
}

class _Pick4DrawScreenState extends State<Pick4DrawScreen> {
  GameType gameType = GameType.game;
  List<DrawData>? drawData = [];

  @override
  Widget build(BuildContext context) {
    drawData = widget.args![1];
    var responseData = widget.args![0];
    return WlsPosScaffold(
        showAppBar: true,
        centerTitle: false,
        appBarTitle: Text(responseData.gameName ?? "Pick 4",
            style: TextStyle(fontSize: 18, color: WlsPosColor.white)),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: WlsPosColor.navy_blue,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: context.screenWidth * 0.46,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(5),
                        ),
                        color: WlsPosColor.white),
                    child: Row(
                      children: [
                        Text('No Played Text'),
                        SizedBox(
                          height: 15,
                          child: VerticalDivider(
                            color: WlsPosColor.black.withOpacity(0.4),
                            thickness: 1,
                          ),
                        ),
                        Text('0'),
                      ],
                    ),
                  ),
                  Container(
                    width: context.screenWidth * 0.46,
                    height: context.screenHeight * 0.06,
                    padding: EdgeInsets.only(left: 10, right: 2),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5),
                      ),
                      border: Border.all(color: WlsPosColor.white, width: 1),
                      // color:  WlsPosColor.white
                    ),
                    child: Row(
                      children: [
                        Text('Current\nDraw',
                            style: TextStyle(
                              color: WlsPosColor.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Roboto",
                              fontStyle: FontStyle.normal,
                              fontSize: 12.0,
                            )),
                        MyTimer(
                            pick4: 'pick',
                            createdAt: drawData![0].drawFreezeTime,
                            // updatedAt: responseData![index].updatedAt
                            updatedAt: '2020-10-14T03:04:39.000+00:00')

                        // Expanded(
                        //   child: ListView.builder(
                        //       shrinkWrap: true,
                        //       itemCount: 4,
                        //       scrollDirection: Axis.horizontal,
                        //       itemBuilder: (context, index) {
                        //         return RaceContainer();
                        //       }),
                        // )
                      ],
                    ),
                  )
                ],
              ).pOnly(left: 10, right: 10, bottom: 10),
            ),
            Text(
              'Draw'.toUpperCase(),
              style: TextStyle(
                // color: WlsPosColor.white,
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                fontSize: 16.0,
              ),
            ).pOnly(left: 15, top: 10),
            AnimationLimiter(
              child: Expanded(
                child: ListView.builder(
                    itemCount: drawData!.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        duration: const Duration(milliseconds: 300),
                        position: index,
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Pick4Draw(
                              drawData: drawData![index],
                              responseData: widget.args![0],
                              onGameTap: () {
                                Navigator.pushNamed(
                                  context,
                                  WlsPosScreen.sportsCricketScreen,
                                  arguments: [
                                    widget.args![0],
                                    drawData![index]
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ));
  }
}
