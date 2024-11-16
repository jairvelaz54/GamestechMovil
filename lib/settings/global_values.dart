import 'package:flutter/material.dart';

class GlobalValues {
  static ValueNotifier banThemeDark = ValueNotifier(false);
  static ValueNotifier banUpdListMovie = ValueNotifier(false);
  static ValueNotifier<int> themeMode =
      ValueNotifier(0); // 0 = light, 1 = dark, 2 = custom
}
