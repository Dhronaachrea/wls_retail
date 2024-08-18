import 'package:flutter/material.dart';
import 'package:wls_pos/utility/wls_pos_color.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      color: WlsPosColor.orangey_red,
    );
  }
}
