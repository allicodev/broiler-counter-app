import 'package:go_router/go_router.dart';
import 'package:scanner/ui/home_view.dart';
import 'package:scanner/ui/initialize.dart';
import 'package:scanner/ui/settings.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      name: "init",
      path: '/',
      builder: (context, state) => const InitializeScreen(),
    ),
    GoRoute(
      name: "home",
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: "settings",
      path: '/settings',
      builder: (context, state) => const Settings(),
    ),
  ],
);
