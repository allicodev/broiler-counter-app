import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanner/ui/screens/detector_screen.dart';
import 'package:scanner/ui/screens/home_screen.dart';
import 'package:scanner/ui/screens/settings_screen.dart';
import 'package:scanner/utilities/constants.dart';
import 'package:scanner/widgets/select.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  String selectedGraphFilter = "daily";

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String getTitle() {
      switch (_selectedIndex) {
        case 0:
          return "DASHBOARD";
        case 1:
          return "CAMERA";
        case 2:
          return "SETTINGS";
        default:
          return "";
      }
    }

    Widget getBottomNavigationBar() {
      return ConvexAppBar(
        color: Colors.black87,
        activeColor: ACCENT_PRIMARY,
        backgroundColor: Colors.white,
        height: 50,
        initialActiveIndex: 0,
        controller: _tabController,
        top: -25,
        items: const [
          TabItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              title: 'Home'),
          TabItem(
              icon: Icons.camera_alt_outlined,
              activeIcon: Icons.camera_alt,
              title: "Camera"),
          TabItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              title: 'Settings'),
        ],
        onTap: (i) {
          setState(() {
            _selectedIndex = i;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.only(left: 20.0),
          child: Text(
            getTitle(),
            style: const TextStyle(
                fontSize: 28.0, color: Colors.white, fontFamily: 'abel'),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: ACCENT_PRIMARY.withOpacity(0.5),
        foregroundColor: Colors.black,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light),
        actions: _selectedIndex == 0
            ? [
                Container(
                    margin: const EdgeInsets.only(right: 5.0),
                    child: Select(
                        options: [
                          SelectValue(label: "Monthly", value: "monthly"),
                          SelectValue(label: "Daily", value: "daily")
                        ],
                        defaultValue: "daily",
                        onChange: (value) =>
                            setState(() => selectedGraphFilter = value)))
              ]
            : null,
      ),
      bottomNavigationBar: getBottomNavigationBar(),
      endDrawer: null,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          HomeScreen(graphFilter: selectedGraphFilter),
          const Detector(),
          const SettingsScreen()
        ],
      ),
    );
  }
}
