import 'package:flutter/material.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class RaceContainer extends StatefulWidget {
  String? dayTime;
  String? dateType;

  RaceContainer(this.dayTime, this.dateType, {Key? key}) : super(key: key);

  @override
  _RaceContainerState createState() => _RaceContainerState();
}

class _RaceContainerState extends State<RaceContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 4, right: 4),
      margin: EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 5),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(5),
          ),
          // border: Border.all(color: WlsPosColor.cherry, width: 1),
          color: WlsPosColor.white),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.dayTime!,
              style: TextStyle(
                // color: WlsPosColor.white,
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                fontSize: 12.0,
              )),
          Text(widget.dateType!,
              style: TextStyle(
                // color: WlsPosColor.white,
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                fontSize: 12.0,
              )),
        ],
      ),
    );
  }
}
