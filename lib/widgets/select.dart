import 'package:flutter/material.dart';
import 'package:scanner/utilities/constants.dart';

// ignore: must_be_immutable
class Select extends StatefulWidget {
  List<SelectValue> options;
  Function(String) onChange;
  String? defaultValue;
  Select(
      {Key? key,
      required this.options,
      required this.onChange,
      this.defaultValue})
      : super(key: key);

  @override
  State<Select> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<Select> {
  String selectedValue = "";
  List<SelectValue> options = [];

  @override
  void initState() {
    setState(() {
      options = widget.options;
      selectedValue = widget.defaultValue != null
          ? widget.options
              .firstWhere((e) =>
                  e.value == widget.defaultValue ||
                  e.label == widget.defaultValue)
              .label
          : widget.options[0].label;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
          color: ACCENT_PRIMARY, borderRadius: BorderRadius.circular(8.0)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: DropdownButton<String>(
        value: selectedValue,
        onChanged: (String? value) {
          String _value = value ?? "";
          setState(() {
            selectedValue = _value;
          });
          widget.onChange(_value);
        },
        underline: const SizedBox(),
        isExpanded: true,
        style: const TextStyle(color: Colors.black),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        selectedItemBuilder: (BuildContext context) {
          return options.map((SelectValue val) {
            return Align(
              alignment: Alignment.center,
              child: Text(
                val.label,
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            );
          }).toList();
        },
        items: options
            .map((e) => e.label)
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SelectValue {
  String label;
  String value;
  SelectValue({required this.label, required this.value});
}
