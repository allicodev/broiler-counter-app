import 'package:flutter/material.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/widgets/button.dart';

class RadioGroup extends StatelessWidget {
  final List<dynamic> choices;
  final dynamic currentValue;
  final Function onChange;
  final Color? color;
  final EdgeInsets? padding;
  final bool? isColumn;
  const RadioGroup(
      {Key? key,
      required this.choices,
      required this.currentValue,
      this.color,
      this.padding,
      this.isColumn,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _choices = choices
        .map((e) => RadioButton(
            label: e is RadioOption ? e.label : e,
            color: color,
            padding: padding,
            margin: EdgeInsets.only(
                bottom: (isColumn ?? false) ? 10 : 0,
                right: !(isColumn ?? false) ? 10 : 0),
            isSelected:
                (e.runtimeType == RadioOption ? e.value : e.toLowerCase()) ==
                    currentValue,
            onPress: () =>
                onChange(e is RadioOption ? e.value : e.toLowerCase())))
        .toList();

    if (isColumn ?? false) {
      return Column(children: _choices);
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Row(children: _choices)]);
  }
}

class RadioOption {
  dynamic value;
  String label;
  RadioOption({required this.value, required this.label});
}

class RadioButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function onPress;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const RadioButton(
      {Key? key,
      required this.label,
      required this.isSelected,
      this.color,
      this.padding,
      this.margin,
      required this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(right: 10),
      child: Button(
          padding: padding,
          borderColor: color ?? ACCENT_PRIMARY,
          backgroundColor:
              isSelected ? color ?? ACCENT_PRIMARY : Colors.transparent,
          textColor: !isSelected ? (color ?? ACCENT_PRIMARY) : Colors.white,
          label: label,
          onPress: onPress),
    );
  }
}
