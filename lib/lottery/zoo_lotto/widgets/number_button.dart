import 'package:flutter/material.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class NumberButton extends StatelessWidget {
  final String number;
  final double widthsize;
  final double heightsize;
  final Color color;
  final TextEditingController controller;
  // VoidCallback(String)? numberClick;
  final Function(String)? numberClick;

  const NumberButton({
    Key? key,
    required this.number,
    required this.widthsize,
    required this.heightsize,
    required this.color,
    required this.controller,
    this.numberClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthsize,
      height: heightsize,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: BorderSide(color: WlsPosColor.warm_grey_three),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: () {
          // controller.text += number.toString();
          if(number.toUpperCase() == 'CLEAR')
            {
              controller.text = '';
              numberClick!('');
            }
          else
            {
              controller.text = number.toString();
              numberClick!(number.toString());
            }
        },
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: WlsPosColor.warm_grey_three),
          ),
        ),
      ),
    );
  }
}

