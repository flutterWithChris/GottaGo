import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/globals.dart';

class MainBottomNavBar extends StatefulWidget {
  // const MainBottomNavBar({super.key});

  static const MainBottomNavBar _bottomNavBar = MainBottomNavBar._internal();

  factory MainBottomNavBar() {
    return _bottomNavBar;
  }

  const MainBottomNavBar._internal();
  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar>
    with AutomaticKeepAliveClientMixin<MainBottomNavBar> {
  void changePage(int? index) {
    Globals().setCurrentIndex = index!;

    switch (index) {
      case 0:
        context.goNamed('profile');
        break;
      case 1:
        context.go('/');
        break;
      case 2:
        context.goNamed('settings');
        break;
      default:
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 80,
      child: BubbleBottomBar(
          tilesPadding: const EdgeInsets.only(top: 8.0),
          backgroundColor: FlexColor.materialDarkScaffoldBackground,
          hasNotch: true,
          opacity: .2,
          fabLocation: BubbleBottomBarFabLocation.end,
          // showUnselectedLabels: false,
          onTap: changePage,
          currentIndex: Globals.currentIndex,
          items: const [
            BubbleBottomBarItem(
                backgroundColor: FlexColor.materialDarkSecondaryHc,
                icon: Icon(Icons.person,
                    color: FlexColor.materialDarkTertiaryContainer),
                activeIcon: Icon(
                  Icons.person,
                ),
                title: Text('Profile')),
            BubbleBottomBarItem(
                backgroundColor: FlexColor.materialDarkSecondaryHc,
                icon: Icon(Icons.list_alt_rounded,
                    color: FlexColor.materialDarkTertiaryContainer),
                activeIcon: Icon(Icons.list_alt_rounded),
                title: Text('Lists')),
            BubbleBottomBarItem(
                backgroundColor: FlexColor.materialDarkSecondaryHc,
                icon: Icon(Icons.settings,
                    color: FlexColor.materialDarkTertiaryContainer),
                activeIcon: Icon(Icons.settings),
                title: Text('Settings')),
          ]),
    );
  }
}
