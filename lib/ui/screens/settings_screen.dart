import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scanner/widgets/button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Button(
                label: "SETTINGS",
                onPress: () => context.pushNamed("settings"),
                textColor: Colors.black87,
              ),
              const SizedBox(height: 5.0),
              Button(
                label: "ABOUT US",
                onPress: () {},
                textColor: Colors.black87,
              )
            ],
          ),
          const Text(
            "App Version 1.0.0",
            style: TextStyle(color: Colors.black45),
          )
        ],
      ),
    );
  }
}
