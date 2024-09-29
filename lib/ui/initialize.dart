import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/utilities/shared_pref.dart';
import 'package:scanner/widgets/hero/failed_hero.dart';
import 'package:scanner/widgets/icon_loaders.dart';
import 'package:scanner/widgets/icon_text.dart';

class InitializeScreen extends StatefulWidget {
  const InitializeScreen({super.key});

  @override
  State<InitializeScreen> createState() => _InitializeState();
}

class _InitializeState extends State<InitializeScreen> {
  var initialState = "loading";
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();
    getCheckenPrice();
    checkConnectivity();

    subscription =
        Connectivity().onConnectivityChanged.listen((_) => checkConnectivity());
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> getCheckenPrice() async {
    Provider.of<AppProvider>(context, listen: false).getChickenPrice();
  }

  Future<void> checkConnectivity() async {
    setState(() => initialState = "loading");
    await Future.delayed(const Duration(milliseconds: 500));

    var connectivityResult = await Connectivity().checkConnectivity();
    if ([ConnectivityResult.mobile, ConnectivityResult.wifi]
        .contains(connectivityResult)) {
      setState(() => initialState = 'online');

      String isLoggedIn = await getValue('isLoggedIn');
      if (mounted) {
        if (isLoggedIn == 'true') {
          await getValue('userId').then((id) {
            if (mounted) {
              Provider.of<AppProvider>(context, listen: false).getUser(id: id);
              context.goNamed("home");
            }
          });
        } else {
          context.goNamed('login');
        }
      }
    } else {
      setState(() => initialState = "offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (["loading", "offline"].contains(initialState)) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light),
        ),
        body: Column(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: initialState == "loading"
                  ? [
                      const SizedBox(height: 10),
                      showGridLoader(),
                      const SizedBox(height: 10),
                      const Text("Checking Network. Please Wait")
                    ]
                  : [HeroFailed(onRetry: () => checkConnectivity())],
            )),
            IconText(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 15),
                mainAxisAlignment: MainAxisAlignment.center,
                color: Colors.grey,
                fontFamily: 'Abel',
                size: 18.0,
                label: "Broiler Counter App")
          ],
        ),
      );
    }

    return Container();
  }
}
