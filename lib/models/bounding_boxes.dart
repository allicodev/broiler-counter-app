// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class BoundingBox {
  String className;
  double top;
  double left;
  double width;
  double height;
  BoundingBox({
    required this.className,
    required this.top,
    required this.left,
    required this.width,
    required this.height,
  });

  Widget drawableContainer(double imgWidth, double imgHeight, bool? withLabel) {
    return Positioned(
      top: top * imgHeight,
      left: left * imgWidth,
      child: Container(
        width: width * imgWidth,
        height: height * imgHeight,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2.0),
            color: Colors.blue.withOpacity(0.5)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'className': className,
      'top': top,
      'left': left,
      'width': width,
      'height': height,
    };
  }

  String toJson() => json.encode(toMap());
}
