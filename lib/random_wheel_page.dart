import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RandomWheelPage extends StatefulWidget {
  const RandomWheelPage({super.key});

  @override
  State<RandomWheelPage> createState() => _RandomWheelPageState();
}

class _RandomWheelPageState extends State<RandomWheelPage> {
  late final ConfettiController confettiController;
  @override
  void initState() {
    // TODO: implement initState
    confettiController =
        ConfettiController(duration: const Duration(seconds: 5));
    super.initState();
  }

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
      body: BlocBuilder<RandomWheelCubit, RandomWheelState>(
        builder: (context, state) {
          if (state is RandomWheelLoading) {
            return LoadingAnimationWidget.fourRotatingDots(
                color: Theme.of(context).primaryColor, size: 20.0);
          }
          if (state is RandomWheelLoaded) {
            List<Place> places = state.places;
            return CustomScrollView(slivers: [
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
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.more_vert))
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 80.0, 8.0, 24.0),
                  child: SizedBox(
                    height: 325,
                    child: FortuneBar(
                        styleStrategy: const AlternatingStyleStrategy(),
                        selected: controller.stream,
                        onFling: () {
                          Random random = Random();
                          int randomInt = random.nextInt(places.length);
                          controller.add(randomInt);
                        },
                        onAnimationEnd: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.5,
                                expand: false,
                                builder: (context, scrollController) {
                                  return ListView(
                                    controller: scrollController,
                                    shrinkWrap: true,
                                    children: [
                                      Text(
                                        'Place Name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          );
                          confettiController.play();
                        },
                        animateFirst: false,
                        items: [
                          for (Place place in places)
                            FortuneItem(
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Text(
                                    place.name!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(100, 42)),
                    child: const Text('Spin The Wheel'),
                    onPressed: () {
                      Random random = Random();
                      int randomInt = random.nextInt(places.length);
                      controller.add(randomInt);
                    },
                  ),
                ),
              )
            ]);
          } else {
            return const Center(
              child: Text('Something Went Wrong...'),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    confettiController.dispose();
    super.dispose();
  }
}
