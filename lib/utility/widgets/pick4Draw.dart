import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/sportsLottery/models/response/sportsLotteryGameApiResponse.dart';
import 'package:wls_pos/sportsLottery/sports_game_widget/sports_game_widget.dart';
import 'package:wls_pos/utility/app_constant.dart';
import 'package:wls_pos/utility/date_format.dart';
import 'package:wls_pos/utility/utils.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class Pick4Draw extends StatelessWidget {
  final VoidCallback onGameTap;
  final DrawData drawData;
  final ResponseData responseData;

  const Pick4Draw(
      {Key? key,
      required this.onGameTap,
      required this.drawData,
      required this.responseData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
            border: Border.all(color: WlsPosColor.cherry, width: 1),
            color: WlsPosColor.white),
        duration: const Duration(milliseconds: 500),
        curve: Curves.bounceInOut,
        child: InkWell(
          onTap: () {
            onGameTap();
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.only(left: 10, top: 2, bottom: 2, right: 5),
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        // border: Border.all(color: WlsPosColor.cherry, width: 1),
                        color: WlsPosColor.cherry),
                    child: Text(
                      // 'DEC\n31\n14:00',
                      getDateTime(),
                      style: TextStyle(
                        color: WlsPosColor.white,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Roboto",
                        fontStyle: FontStyle.normal,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    drawData.drawName!,
                    style: TextStyle(
                      color: WlsPosColor.cherry,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ).pOnly(left: 5)
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PoolSize(
                      minimumPoolAmount: drawData.minimumPoolAmount,
                      totalSaleTillNow: drawData.totalSaleTillNow,
                      prizePayoutPercentage: responseData.prizePayoutPercentage,
                      color: WlsPosColor.white
                      // : WlsPosColor.tangerine,
                      ),
                  Text(
                    "Pool Size",
                    style: TextStyle(
                      // color: WlsPosColor.cherry,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      fontStyle: FontStyle.normal,
                      fontSize: 12.0,
                    ),
                  )
                ],
              ).pOnly(right: 10)
            ],
          ),
        )).pOnly(left: 10, right: 10, top: 10);
  }

  String getDateTime() {
    String dateValue = formatDate(
      date: drawData.drawDateTime ?? '14:30',
      inputFormat: Format.apiDateFormat2,
      outputFormat: Format.dateFormat11,
    );

    return dateValue.split(' ')[0] +
        '\n' +
        (dateValue.split(' ')[1]).replaceAll(',', '') +
        '\n' +
        dateValue.split(' ')[2];
  }
}
