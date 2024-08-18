import 'package:flutter/material.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class Forward extends StatefulWidget {
  final VoidCallback onTap;

  const Forward({Key? key, required this.onTap})
      : super(key: key);

  @override
  State<Forward> createState() => _ForwardState();
}

class _ForwardState extends State<Forward> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: const BoxDecoration(
          color: WlsPosColor.orangey_red,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_forward_ios,
          color: WlsPosColor.white,
        ),
      ),
    );
  }
}