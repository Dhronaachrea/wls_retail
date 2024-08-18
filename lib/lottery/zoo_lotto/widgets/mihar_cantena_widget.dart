import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/lottery/models/response/fetch_game_data_response.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';
import 'package:wls_pos/utility/wls_pos_screens.dart';

class MiharCantenaWidget extends StatefulWidget {
  bool tickValue;
  BetRespVOs? drawData;
  final VoidCallback? onTapData;

  MiharCantenaWidget(
      {Key? key,
      required this.tickValue,
      required this.drawData,
      required this.onTapData})
      : super(key: key);

  @override
  _MiharCantenaWidgetState createState() => _MiharCantenaWidgetState();
}

class _MiharCantenaWidgetState extends State<MiharCantenaWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            widget.onTapData!();
          },
          child: Container(
            width: context.screenWidth * 0.35,
            height: context.screenHeight * 0.08,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(width: 1, color: WlsPosColor.red)),
            child: Text(widget.drawData!.betDispName!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: WlsPosColor.red,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Roboto",
                  fontStyle: FontStyle.normal,
                  fontSize: 13.0,
                )),
          ),
        ),
        // Align(
        //     alignment: Alignment.topLeft,
        //     child: Container(
        //         margin: EdgeInsets.only(left: 5, top: 2),
        //         child: SvgPicture.asset("assets/icons/check.svg",width: 15,height: 15,))
        // )
      ],
    ).pOnly(right: 10);
  }
}
