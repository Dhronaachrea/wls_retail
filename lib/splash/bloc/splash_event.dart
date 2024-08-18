import 'package:flutter/material.dart';

abstract class SplashEvent {}


class GetConfigData extends SplashEvent {
  BuildContext context;

  GetConfigData({required this.context});
}
