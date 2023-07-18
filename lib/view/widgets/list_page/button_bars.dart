import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/cubit/lists/list_sort_cubit.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/list_page/buttons.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../bloc/bloc/purchases/purchases_bloc.dart';
import '../../../bloc/saved_places/bloc/saved_places_bloc.dart';
import '../../../cubit/cubit/cubit/view_place_cubit.dart';
import '../../../model/place.dart';
import '../places/view_place_sheet.dart';

class RandomPlaceBar extends StatelessWidget {
  final List<GlobalKey> keys;
  final PlaceList? currentPlaceList;
  const RandomPlaceBar({
    super.key,
    required this.keys,
    required this.currentPlaceList,
    required this.controller,
    required this.places,
  });

  final StreamController<int> controller;
  final List<Place>? places;

  @override
  Widget build(BuildContext context) {
    bool placeListLoaded = currentPlaceList != null && places != null;
    return BlocBuilder<RandomWheelCubit, RandomWheelState>(
      builder: (context, state) {
        ScrollController scrollController = ScrollController();

        if (state is RandomWheelLoading) {
          return const SliverToBoxAdapter(child: SizedBox());
        }
        if (state is RandomWheelLoaded ||
            state is RandomWheelSpun ||
            state is RandomWheelChosen) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Animate(
                effects: const [SlideEffect()],
                child: FortuneBar(
                    styleStrategy: const AlternatingStyleStrategy(),
                    selected: controller.stream,
                    onFling: placeListLoaded == false
                        ? () {}
                        : () async {
                            Random random = Random();
                            int randomInt = random.nextInt(places!.length);
                            controller.add(randomInt);
                            Place place = places![randomInt];
                            context
                                .read<RandomWheelCubit>()
                                .wheelHasChosen(place);
                            await Future.delayed(
                                const Duration(seconds: 8),
                                () => context
                                    .read<RandomWheelCubit>()
                                    .resetWheel());
                          },
                    onAnimationEnd: () async {
                      context.read<ViewPlaceCubit>().viewPlace(
                          context.read<RandomWheelCubit>().selectedPlace!);
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.75,
                              maxChildSize: 0.9,
                              builder: (context, controller) {
                                return ViewPlaceSheet(
                                    place: context
                                        .read<RandomWheelCubit>()
                                        .selectedPlace!,
                                    scrollController: scrollController);
                              });
                        },
                      );
                    },
                    animateFirst: false,
                    items: placeListLoaded == false
                        ? []
                        : [
                            for (Place place in places!)
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
          );
        } else {
          return PlaceListButtonBar(
            keys: keys,
            places: places,
            currentPlaceList: currentPlaceList,
          );
        }
      },
    );
  }
}

class PlaceListButtonBar extends StatefulWidget {
  final List<GlobalKey> keys;
  const PlaceListButtonBar({
    super.key,
    required this.keys,
    required this.currentPlaceList,
    required this.places,
  });

  final List<Place>? places;
  final PlaceList? currentPlaceList;

  @override
  State<PlaceListButtonBar> createState() => _PlaceListButtonBarState();
}

class _PlaceListButtonBarState extends State<PlaceListButtonBar> {
  @override
  Widget build(BuildContext context) {
    bool placeListLoaded =
        widget.currentPlaceList != null && widget.places != null;
    String dropdownValue = context.watch<ListSortCubit>().state.status!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 24.0),
            //   child: Theme(
            //     data: ThemeData(
            //         inputDecorationTheme: const InputDecorationTheme()),
            //     child: SearchBar(
            //         leading: const Icon(Icons.search),
            //         elevation: const MaterialStatePropertyAll(0.0),
            //         overlayColor:
            //             const MaterialStatePropertyAll(Colors.transparent),
            //         backgroundColor:
            //             MaterialStatePropertyAll(Theme.of(context).cardColor),
            //         surfaceTintColor:
            //             const MaterialStatePropertyAll(Colors.transparent),
            //         shape: const MaterialStatePropertyAll(
            //             RoundedRectangleBorder(
            //                 borderRadius:
            //                     BorderRadius.all(Radius.circular(24.0)),
            //                 side: BorderSide.none)),
            //         side: const MaterialStatePropertyAll(
            //           BorderSide(color: Colors.transparent),
            //         )),
            //   ),
            // ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Showcase(
                      targetPadding: const EdgeInsets.all(12.0),
                      targetBorderRadius: BorderRadius.circular(24.0),
                      description:
                          'Filter between places you have or haven\'t visited!',
                      key: widget.keys[0],
                      child: DropdownButton<String>(
                        borderRadius: BorderRadius.circular(24),
                        isDense: true,
                        underline: const SizedBox(),
                        value: dropdownValue,
                        items: const [
                          DropdownMenuItem(
                            value: 'Not Visited',
                            child: Text('Not Visited'),
                          ),
                          DropdownMenuItem(
                            value: 'Visited',
                            child: Text('Visited'),
                          ),
                        ],
                        onChanged: placeListLoaded == false
                            ? (value) {}
                            : (value) {
                                if (value != dropdownValue) {
                                  setState(() {
                                    dropdownValue = value!;
                                  });
                                  switch (value) {
                                    case 'Visited':
                                      context
                                          .read<ListSortCubit>()
                                          .sortByVisitedStatus('Visited');
                                      context.read<SavedPlacesBloc>().add(
                                          LoadVisitedPlaces(
                                              placeList:
                                                  widget.currentPlaceList!));
                                      break;

                                    case 'Not Visited':
                                      context
                                          .read<ListSortCubit>()
                                          .sortByVisitedStatus('Not Visited');
                                      context.read<SavedPlacesBloc>().add(
                                          LoadPlaces(
                                              placeList:
                                                  widget.currentPlaceList!));
                                      break;
                                  }
                                }
                              },
                      )
                          .animate()
                          .slideX(
                              begin: -1.0,
                              curve: Curves.easeOutSine,
                              duration: 400.ms)
                          .fadeIn(curve: Curves.easeOutSine),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Showcase(
                          key: widget.keys[3],
                          descriptionAlignment: TextAlign.center,
                          targetBorderRadius: BorderRadius.circular(24.0),
                          targetPadding: const EdgeInsets.only(
                              top: -20, bottom: -12, left: 8.0, right: 8.0),
                          description:
                              'Select multiple places to mark visited, delete, etc.',
                          child: EditButton(
                              places: widget.places,
                              placeList: widget.currentPlaceList),
                        ),
                        // const SizedBox(
                        //   width: 8.0,
                        // ),
                        Showcase(
                          key: widget.keys[2],
                          descriptionAlignment: TextAlign.center,
                          targetBorderRadius: BorderRadius.circular(24.0),
                          targetPadding: const EdgeInsets.only(
                              top: -20, bottom: -12, left: 8.0, right: 8.0),
                          description: context
                                      .watch<PurchasesBloc>()
                                      .state
                                      .isSubscribed ==
                                  true
                              ? 'Use the random wheel to easily choose a place.'
                              : 'Use the random wheel to easily choose a place.\n(Requires Premium)',
                          child: GoButton(
                            places:
                                context.read<SavedPlacesBloc>().state.places,
                          ),
                        ),
                        // const SizedBox(q
                        //   width: 8.0,
                        // ),
                        Showcase(
                          key: widget.keys[1],
                          descriptionAlignment: TextAlign.center,
                          targetBorderRadius: BorderRadius.circular(24.0),
                          targetPadding: const EdgeInsets.only(
                              top: -20, bottom: -12, left: 8.0, right: 8.0),
                          description: context
                                      .watch<PurchasesBloc>()
                                      .state
                                      .isSubscribed ==
                                  true
                              ? 'Invite friends to join your list & help adding places!'
                              : 'Invite friends to join your list & help adding places!\n(Requires Premium)',
                          child:
                              InviteButton(placeList: widget.currentPlaceList),
                        ),
                      ]
                          .animate(interval: 200.ms)
                          .slideX(
                              begin: 1.618,
                              curve: Curves.easeOutSine,
                              duration: 400.ms)
                          .fadeIn(curve: Curves.easeOutSine),
                    ),
                  )
                ]
                // .animate(interval: 200.ms)
                // .slideX(begin: 1.0, curve: Curves.easeOutSine, duration: 600.ms)
                // .fadeIn(curve: Curves.easeOutSine),
                ),
          ],
        ),
      ),
    );
  }
}
