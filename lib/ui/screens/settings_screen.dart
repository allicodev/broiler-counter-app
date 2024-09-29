import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scanner/models/user_model.dart';
import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/utilities/shared_pref.dart';
import 'package:scanner/widgets/button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    AppProvider app = context.watch<AppProvider>();

    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello ${(app.currentUser as User).name}, Have a nice Day 👋',
            style: const TextStyle(fontSize: 24.0),
          ),
          Column(
            children: [
              // Button(
              //   label: "SETTINGS",
              //   onPress: () => context.pushNamed("settings"),
              //   textColor: Colors.black87,
              // ),
              Button(
                label: "Chicken Price: $PESO${app.price}",
                textColor: Colors.black87,
                borderColor: Colors.transparent,
                mainAxisAlignment: MainAxisAlignment.start,
                padding: const EdgeInsets.all(0),
              ),
              const SizedBox(height: 5.0),
              Button(
                label: "ABOUT US",
                onPress: () {},
                textColor: Colors.black87,
              ),
              const SizedBox(height: 5),
              Button(
                label: "LOGOUT",
                borderColor: Colors.transparent,
                textColor: Colors.redAccent,
                icon: Icons.logout,
                onPress: () {
                  setKeyValue('isLoggedIn', '');
                  setKeyValue('userId', '');
                  context.goNamed('login');
                },
              ),
              const Text(
                "App Version 1.0.0",
                style: TextStyle(color: Colors.black45),
              )
            ],
          ),
        ],
      ),
    );
  }
}
