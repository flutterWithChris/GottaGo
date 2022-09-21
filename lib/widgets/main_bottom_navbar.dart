import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainBottomNavBar extends StatefulWidget {
  const MainBottomNavBar({super.key});

  @override
  State<MainBottomNavBar> createState() => _MainBottomNavBarState();
}

class _MainBottomNavBarState extends State<MainBottomNavBar> {
  static late int currentIndex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = 1;
  }

  void changePage(int? index) {
    setState(() {
      currentIndex = index!;
    });
    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/');
        break;
      case 2:
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: BubbleBottomBar(
          backgroundColor: FlexColor.materialDarkScaffoldBackground,
          hasNotch: true,
          opacity: .2,
          fabLocation: BubbleBottomBarFabLocation.end,
          // showUnselectedLabels: false,
          onTap: changePage,
          currentIndex: currentIndex,
          items: [
            BubbleBottomBarItem(
                backgroundColor: FlexColor.materialDarkSecondaryHc,
                icon: const Icon(
                  Icons.person,
                  // color: Theme.of(context).p,
                ),
                activeIcon: Icon(
                  Icons.person,
                  color: Theme.of(context).iconTheme.color,
                ),
                title: const Text('Profile')),
            const BubbleBottomBarItem(
                backgroundColor: FlexColor.materialDarkSecondaryHc,
                icon: Icon(Icons.list_alt_rounded,
                    color: FlexColor.materialDarkTertiaryContainer),
                activeIcon: Icon(Icons.list_alt_rounded),
                title: Text('Lists')),
            const BubbleBottomBarItem(
                backgroundColor: FlexColor.materialDarkSecondaryHc,
                icon: Icon(Icons.settings),
                activeIcon: Icon(Icons.settings),
                title: Text('Settings')),
          ]),
    );
  }
}
