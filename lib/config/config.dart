import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SizeConfig {
  static getHeight(context) {
    return MediaQuery.of(context).size.height;
  }

  static getWidth(context) {
    return MediaQuery.of(context).size.width;
  }
}

class AppColors {
  static Color primary = Colors.red;
  static Color secondary = Colors.redAccent;
}
