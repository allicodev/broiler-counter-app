import 'package:flutter/widgets.dart';

class TextValue {
  String label;
  dynamic value;
  IconData? icon;
  Map? extraData;
  Function? onPress;

  TextValue({
    required this.label,
    this.icon,
    this.value,
    this.extraData,
    this.onPress,
  });
}
