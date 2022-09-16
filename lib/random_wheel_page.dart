import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';

class RandomWheelPage extends StatelessWidget {
  const RandomWheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StreamController<int> controller = StreamController<int>();
    return Scaffold(
      //  floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const MainBottomNavBar(),
      // floatingActionButton: FloatingActionButton(
      //   shape: const StadiumBorder(),
      //   // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
      //   child: const Icon(Icons.add_location_rounded),
      //   onPressed: () {
      //     showModalBottomSheet(
      //         backgroundColor:
      //             Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
      //         isScrollControlled: true,
      //         context: context,
      //         builder: (context) {
      //           return SearchPlacesSheet(
      //               googlePlace: googlePlace, mounted: mounted);
      //         });
      //   },
      // ),
      body: CustomScrollView(slivers: [
        SliverAppBar.medium(
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu),
            ),
          ),
          title: Wrap(
            spacing: 18.0,
            children: const [
              Icon(FontAwesomeIcons.buildingCircleCheck),
              Text(
                'GottaGo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          expandedHeight: 120,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 24.0),
            child: SizedBox(
              height: 300,
              child: FortuneWheel(
                  selected: controller.stream,
                  onFling: () {
                    controller.add(1);
                  },
                  animateFirst: false,
                  items: const [
                    FortuneItem(
                      child: Text('Test'),
                    ),
                    FortuneItem(
                      child: Text('Test'),
                    ),
                    FortuneItem(
                      child: Text('Test'),
                    ),
                  ]),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(fixedSize: const Size(100, 42)),
              child: const Text('Spin The Wheel'),
              onPressed: () {},
            ),
          ),
        )
      ]),
    );
  }
}
