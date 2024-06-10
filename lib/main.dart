import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:scanner/provider/app_provider.dart';
import 'package:scanner/utilities/go_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: MaterialApp.router(
          title: 'Broiler Counter using Object Detection App',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      );
}
