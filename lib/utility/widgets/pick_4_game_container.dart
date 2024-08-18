import 'package:flutter/material.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class Pick4GameContainer extends StatefulWidget {
  const Pick4GameContainer({Key? key}) : super(key: key);

  @override
  _Pick4GameContainerState createState() => _Pick4GameContainerState();
}

class _Pick4GameContainerState extends State<Pick4GameContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4),
          margin: EdgeInsets.only(top: 2, bottom: 2, left: 5, right: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(2),
              ),
              border: Border.all(color: WlsPosColor.warm_grey_seven, width: 1),
              color: WlsPosColor.white),
          child: Text('05',
              style: TextStyle(
                // color: WlsPosColor.white,
                fontWeight: FontWeight.w400,
                fontFamily: "Roboto",
                fontStyle: FontStyle.normal,
                fontSize: 12.0,
              )),
        ),
        Text('5%',
            style: TextStyle(
              color: WlsPosColor.navy_blue,
              fontWeight: FontWeight.bold,
              fontFamily: "Roboto",
              fontStyle: FontStyle.normal,
              fontSize: 12.0,
            )),
      ],
    );
  }
}
