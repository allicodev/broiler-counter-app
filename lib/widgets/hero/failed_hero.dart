import 'package:flutter/material.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/widgets/button.dart';

class HeroFailed extends StatelessWidget {
  final Function onRetry;
  const HeroFailed({Key? key, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Network is offline. Cannot Proceed"),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
                backgroundColor: Colors.transparent,
                borderColor: ACCENT_SECONDARY,
                textColor: ACCENT_SECONDARY,
                borderRadius: 100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                icon: Icons.replay_outlined,
                label: "Retry",
                onPress: () => onRetry()),
          ],
        ),
      ],
    );
  }
}
