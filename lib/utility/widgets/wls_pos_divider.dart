import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class WlsDivider extends StatefulWidget {
  double? dividerWidth;
  double? dividerHeight;
  double? thickness;
  Color? dividerColor;

  WlsDivider({Key? key, this.dividerWidth = 10, this.dividerHeight = 1, this.thickness = 1, this.dividerColor = WlsPosColor.black}) : super(key: key);

  @override
  _WlsDividerState createState() => _WlsDividerState();
}

class _WlsDividerState extends State<WlsDivider> {
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: widget.dividerColor,
      height: widget.dividerHeight,
      thickness: widget.thickness!, // 150
      indent: widget.dividerWidth != null ? context.screenWidth * widget.dividerWidth! : context.screenWidth * 0.001,
      endIndent: widget.dividerWidth != null ? context.screenWidth * widget.dividerWidth!: context.screenWidth * 0.001,
    );
  }
}
