// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

class BoundingBox {
  String className;
  double top;
  double left;
  double width;
  double height;
  double confidence;
  BoundingBox(
      {required this.className,
      required this.top,
      required this.left,
      required this.width,
      required this.height,
      required this.confidence});

  Widget drawableContainer(double w, double h, bool? withLabel) {
    return Positioned(
      top: top * h,
      left: left * w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              color: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "${(confidence * 100).toStringAsFixed(2)}%",
                style: const TextStyle(color: Colors.white, fontSize: 10.0),
              )),
          Container(
            width: width * w,
            height: height * h,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal, width: 2.0),
            ),
          ),
        ],
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
