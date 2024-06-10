import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:scanner/utilities/constants.dart';

showGridLoader({double? size}) {
  return SpinKitCubeGrid(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: index.isEven
              ? ACCENT_SECONDARY.withOpacity(0.7)
              : ACCENT_PRIMARY.withOpacity(0.7),
        ),
      );
    },
  );
}
