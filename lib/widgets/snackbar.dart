import 'package:flutter/material.dart';

launchSnackbar(
    {required BuildContext context,
    required String mode,
    IconData? icon,
    int? duration,
    required String message}) {
  Color? color;
  IconData? icon0;

  if (mode == "SUCCESS") {
    color = Colors.teal;
    icon0 = Icons.check_box_outlined;
  }
  if (mode == "ERROR") {
    color = Colors.red;
    icon0 = Icons.warning_amber_rounded;
  }

  final snackBar = SnackBar(
    duration: Duration(milliseconds: duration ?? 3000),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? icon0, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(message,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        )
      ],
    ),
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
