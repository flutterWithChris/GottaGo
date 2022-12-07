import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/place/edit_places_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/cubit/lists/list_sort_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/view/widgets/lists/delete_list_dialog.dart';
import 'package:leggo/view/widgets/lists/invite_dialog.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/places/add_place_card.dart';
import 'package:leggo/view/widgets/places/blank_place_card.dart';
import 'package:leggo/view/widgets/places/place_card.dart';
import 'package:leggo/view/widgets/places/search_places_sheet.dart';
import 'package:leggo/view/widgets/places/view_place_sheet.dart';
import 'package:leggo/view/widgets/premium_offer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Widget> rows = [];
  List<PlaceCard> placeCards = [];
  late final ScrollController mainScrollController;
  final StreamController<int> controller = StreamController.broadcast();
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  late ConfettiController confettiController;
  int selectionType = 0;
  final GlobalKey _addPlaceShowcase = GlobalKey();
  final GlobalKey _checklistShowcase = GlobalKey();
  final GlobalKey _randomWheelShowcase = GlobalKey();
  final GlobalKey _inviteCollaboratorShowcase = GlobalKey();
  final GlobalKey _visitedFilterShowcase = GlobalKey();
  final GlobalKey _avatarStackShowcase = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    mainScrollController = ScrollController();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    BuildContext? buildContext;
    final TextEditingController textEditingController = TextEditingController();
    List<Place> selectedPlaces = context.watch<EditPlacesBloc>().selectedPlaces;
    return FutureBuilder<bool?>(
        future: getShowcaseStatus('categoryPageShowcaseComplete'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data == null || snapshot.data == false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              await Future.delayed(const Duration(milliseconds: 400));
              ShowCaseWidget.of(buildContext!).startShowCase([
                _addPlaceShowcase,
                _visitedFilterShowcase,
                _inviteCollaboratorShowcase,
                _avatarStackShowcase,
                _randomWheelShowcase,
                _checklistShowcase
              ]);
            });
          }
          return ShowCaseWidget(onFinish: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('categoryPageShowcaseComplete', true);
          }, builder: Builder(
            builder: (context) {
              buildContext = context;
              return Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                bottomNavigationBar: MainBottomNavBar(),
                floatingActionButton: Showcase(
                  targetBorderRadius: BorderRadius.circular(50),
                  targetPadding: const EdgeInsets.all(8.0),
                  key: _addPlaceShowcase,
                  description: 'Search & add places with this button!',
                  child: FloatingActionButton(
                    shape: const StadiumBorder(),
                    // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                    child: const Icon(Icons.add_location_alt_outlined),
                    onPressed: () {
                      showModalBottomSheet(
                          backgroundColor: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.8),
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return SearchPlacesSheet(mounted: mounted);
                          });
                    },
                  ),
                ),
                body: BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
                  // buildWhen: (previous, current) =>
                  //     previous.placeList != current.placeList,
                  builder: (context, state) {
                    if (state is SavedPlacesLoading ||
                        state is SavedPlacesUpdated) {
                      rows = [
                        for (int i = 0; i < 5; i++)
                          Opacity(
                            opacity: 0.4,
                            child: Animate(
                              effects: const [
                                FadeEffect(),
                                ShimmerEffect(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut),
                                // SlideEffect(curve: Curves.easeOutBack)
                              ],
                              child: const BlankPlaceCard(),
                            ),
                          )
                      ];

                      return CustomScrollView(
                        controller: mainScrollController,
                        slivers: [
                          SliverAppBar.medium(
                            expandedHeight: 125,
                            // leading: Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            //   child: IconButton(
                            //     onPressed: () {},
                            //     icon: const Icon(Icons.menu),
                            //   ),
                            // ),
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LoadingAnimationWidget.beat(
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color!,
                                    size: 20.0),
                              ],
                            ),
                            actions: [
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.more_vert)),
                            ],
                          ),
                          ReorderableSliverList(
                            enabled: false,
                            onReorder: (oldIndex, newIndex) {},
                            delegate: ReorderableSliverChildBuilderDelegate(
                                childCount: rows.length, (context, index) {
                              return rows[index];
                            }),
                          )
                        ],
                      );
                    }
                    if (state is SavedPlacesFailed) {
                      return const Center(
                        child: Text('Error Loading List!'),
                      );
                    }

                    if (state is SavedPlacesLoaded) {
                      User listOwner = state.listOwner;
                      PlaceList currentPlaceList = state.placeList;
                      List<User>? contributors =
                          context.watch<SavedPlacesBloc>().state.contributors;
                      List<String> contributorAvatars = [];
                      List<Place> places = state.places;

                      contributorAvatars.add(state.listOwner.profilePicture!);
                      if (contributors != null) {
                        for (User user in contributors) {
                          contributorAvatars.add(user.profilePicture!);
                        }
                      }

                      void _onReorder(int oldIndex, int newIndex) {
                        Place place = state.places.removeAt(oldIndex);
                        state.places.insert(newIndex, place);
                        setState(() {
                          Widget row = rows.removeAt(oldIndex);
                          rows.insert(newIndex, row);
                        });
                      }

                      if (places.isNotEmpty) {
                        rows = [
                          for (Place place in places)
                            Animate(
                              effects: const [
                                SlideEffect(
                                    curve: Curves.easeOutBack,
                                    duration: Duration(milliseconds: 600)),
                                ShimmerEffect(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: PlaceCard(
                                    place: place,
                                    placeList: currentPlaceList,
                                    imageUrl: place.mainPhoto,
                                    memoryImage: place.mainPhoto,
                                    placeName: place.name!,
                                    ratingsTotal: place.rating,
                                    placeDescription: place.reviews![0]['text'],
                                    closingTime: place.hours![0],
                                    placeLocation: place.city!),
                              ),
                            )
                        ];
                        if (state.places.length < 5) {
                          for (int i = 0; i < 5 - state.places.length; i++) {
                            rows.add(Opacity(
                              opacity: 0.4,
                              child: Animate(effects: const [
                                ShimmerEffect(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut),
                                SlideEffect(curve: Curves.easeOutBack)
                              ], child: const BlankPlaceCard()),
                            ));
                          }
                        }
                      } else {
                        rows = [
                          for (int i = 0; i < 5; i++)
                            Opacity(
                              opacity: 0.4,
                              child: Animate(effects: const [
                                ShimmerEffect(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut),
                                SlideEffect(
                                  curve: Curves.easeOutBack,
                                )
                              ], child: const BlankPlaceCard()),
                            )
                        ];
                        rows.insert(
                          0,
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Animate(
                              effects: const [
                                SlideEffect(
                                  curve: Curves.easeOutBack,
                                ),
                                ShimmerEffect(
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.easeInOut)
                              ],
                              child: const AddPlaceCard(),
                            ),
                          ),
                        );
                      }

                      return BlocConsumer<EditPlacesBloc, EditPlacesState>(
                        listener: (context, state) async {
                          if (state is EditPlacesSubmitted) {
                            context.read<ListSortCubit>().state.status ==
                                    'Visited'
                                ? context.read<SavedPlacesBloc>().add(
                                    LoadVisitedPlaces(
                                        placeList: currentPlaceList))
                                : context.read<SavedPlacesBloc>().add(
                                    LoadPlaces(placeList: currentPlaceList));
                            context
                                .read<SavedListsBloc>()
                                .add(LoadSavedLists());
                          }
                        },
                        builder: (context, state) {
                          return Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                              CustomScrollView(
                                controller: mainScrollController,
                                slivers: [
                                  CategoryPageAppBar(
                                      avatarStackKey: _avatarStackShowcase,
                                      listOwner: listOwner,
                                      contributors: contributors,
                                      placeList: currentPlaceList,
                                      scrollController: mainScrollController),
                                  RandomPlaceBar(
                                      keys: [
                                        _visitedFilterShowcase,
                                        _inviteCollaboratorShowcase,
                                        _randomWheelShowcase,
                                        _checklistShowcase
                                      ],
                                      currentPlaceList: currentPlaceList,
                                      controller: controller,
                                      places: places),
                                  ReorderableSliverList(
                                    enabled: false,
                                    onReorder: _onReorder,
                                    delegate:
                                        ReorderableSliverChildBuilderDelegate(
                                            childCount: rows.length,
                                            (context, index) {
                                      return rows[index];
                                    }),
                                  )
                                ],
                              ),
                              if (state is EditPlacesStarted ||
                                  state is PlaceAdded ||
                                  state is PlaceRemoved)
                                Positioned(
                                  bottom: 12.0,
                                  child: Animate(
                                    effects: const [
                                      SlideEffect(
                                          begin: Offset(0.0, 3.0),
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.easeOutSine)
                                    ],
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: selectionType == 0
                                                ? ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red.shade600,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      context
                                                                  .read<
                                                                      ListSortCubit>()
                                                                  .state
                                                                  .status ==
                                                              'Visited'
                                                          ? context
                                                              .read<
                                                                  EditPlacesBloc>()
                                                              .add(DeleteVisitedPlaces(
                                                                  placeList:
                                                                      currentPlaceList))
                                                          : context
                                                              .read<
                                                                  EditPlacesBloc>()
                                                              .add(DeletePlaces(
                                                                  placeList:
                                                                      currentPlaceList));
                                                      // context.read<EditPlacesBloc>().add(
                                                      //     FinishEditing(places: places, placeList: placeList));
                                                    },
                                                    child: Text.rich(
                                                        TextSpan(children: [
                                                      const TextSpan(
                                                          text: 'Delete '),
                                                      TextSpan(
                                                          text:
                                                              '${selectedPlaces.length} ',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const TextSpan(
                                                          text: 'Places'),
                                                    ])))
                                                : ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: FlexColor
                                                          .bahamaBlueLightPrimary,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      context
                                                          .read<
                                                              EditPlacesBloc>()
                                                          .add(MarkVisitedPlaces(
                                                              placeList:
                                                                  currentPlaceList));
                                                      // context.read<EditPlacesBloc>().add(
                                                      //     FinishEditing(places: places, placeList: placeList));
                                                    },
                                                    child: Text.rich(
                                                        TextSpan(children: [
                                                      const TextSpan(
                                                          text: 'Mark '),
                                                      TextSpan(
                                                          text:
                                                              '${selectedPlaces.length} ',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const TextSpan(
                                                          text:
                                                              'Places Visited'),
                                                    ])))),
                                        selectionType == 0
                                            ? context
                                                        .read<ListSortCubit>()
                                                        .state
                                                        .status ==
                                                    'Visited'
                                                ? const SizedBox()
                                                : PopupMenuButton(
                                                    position:
                                                        PopupMenuPosition.under,
                                                    icon: const CircleAvatar(
                                                        child: Icon(Icons
                                                            .keyboard_arrow_down_sharp)),
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                          onTap: () {
                                                            setState(() {
                                                              selectionType = 1;
                                                            });
                                                          },
                                                          child: const Text(
                                                              'Mark Visited'))
                                                    ],
                                                  )
                                            : PopupMenuButton(
                                                position:
                                                    PopupMenuPosition.under,
                                                icon: const CircleAvatar(
                                                    child: Icon(Icons
                                                        .keyboard_arrow_down_sharp)),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                      onTap: () {
                                                        setState(() {
                                                          selectionType = 0;
                                                        });
                                                      },
                                                      child: const Text(
                                                          'Delete Places'))
                                                ],
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      );
                    } else {
                      return const Center(
                          child: Text('Something Went Wrong...'));
                    }
                  },
                ),
              );
            },
          ));
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    draggableScrollableController.dispose();
    super.dispose();
  }
}

class RandomPlaceBar extends StatelessWidget {
  final List<GlobalKey> keys;
  final PlaceList currentPlaceList;
  const RandomPlaceBar({
    super.key,
    required this.keys,
    required this.currentPlaceList,
    required this.controller,
    required this.places,
  });

  final StreamController<int> controller;
  final List<Place> places;

  @override
  Widget build(BuildContext context) {
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
                    onFling: () async {
                      Random random = Random();
                      int randomInt = random.nextInt(places.length);
                      controller.add(randomInt);
                      Place place = places[randomInt];
                      context.read<RandomWheelCubit>().wheelHasChosen(place);
                      await Future.delayed(const Duration(seconds: 8),
                          () => context.read<RandomWheelCubit>().resetWheel());
                    },
                    onAnimationEnd: () {
                      context.read<ViewPlaceCubit>().viewPlace(
                          context.read<RandomWheelCubit>().selectedPlace!);
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return ViewPlaceSheet(
                              place: context
                                  .read<RandomWheelCubit>()
                                  .selectedPlace!,
                              scrollController: scrollController);
                        },
                      );
                    },
                    animateFirst: false,
                    items: [
                      for (Place place in places)
                        FortuneItem(
                          child: SizedBox(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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

  final List<Place> places;
  final PlaceList currentPlaceList;

  @override
  State<PlaceListButtonBar> createState() => _PlaceListButtonBarState();
}

class _PlaceListButtonBarState extends State<PlaceListButtonBar> {
  @override
  Widget build(BuildContext context) {
    String dropdownValue = context.watch<ListSortCubit>().state.status!;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
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
                  onChanged: (value) {
                    if (value != dropdownValue) {
                      setState(() {
                        dropdownValue = value!;
                      });
                      switch (value) {
                        case 'Visited':
                          context
                              .read<ListSortCubit>()
                              .sortByVisitedStatus('Visited');
                          context.read<SavedPlacesBloc>().add(LoadVisitedPlaces(
                              placeList: widget.currentPlaceList));
                          break;

                        case 'Not Visited':
                          context
                              .read<ListSortCubit>()
                              .sortByVisitedStatus('Not Visited');
                          context.read<SavedPlacesBloc>().add(
                              LoadPlaces(placeList: widget.currentPlaceList));
                          break;
                      }
                    }
                  },
                ),
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
                        placeList:
                            context.read<SavedPlacesBloc>().state.placeList!),
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
                      places: widget.places,
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
                    child: InviteButton(
                        placeList:
                            context.read<SavedPlacesBloc>().state.placeList!),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CategoryPageAppBar extends StatefulWidget {
  const CategoryPageAppBar({
    Key? key,
    required this.contributors,
    required this.placeList,
    required this.avatarStackKey,
    required this.scrollController,
    required this.listOwner,
  }) : super(key: key);

  final List<User>? contributors;
  final GlobalKey avatarStackKey;
  final PlaceList placeList;
  final User listOwner;
  final ScrollController scrollController;

  @override
  State<CategoryPageAppBar> createState() => _CategoryPageAppBarState();
}

class _CategoryPageAppBarState extends State<CategoryPageAppBar> {
  EdgeInsets avatarStackPadding = const EdgeInsets.only(right: 4.0);

  @override
  void initState() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.addListener(
        () {
          if (widget.scrollController.offset > 65) {
            if (!mounted) return;
            setState(() {
              Platform.isIOS
                  ? avatarStackPadding =
                      const EdgeInsets.symmetric(horizontal: 28.0)
                  : avatarStackPadding = const EdgeInsets.only(right: 28.0);
            });
          } else if (widget.scrollController.hasClients &&
              widget.scrollController.offset < 65) {
            if (!mounted) return;
            setState(() {
              avatarStackPadding = const EdgeInsets.only(right: 4.0);
            });
          }
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      leadingWidth: 50,
      expandedHeight: 125,
      // leading: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //   child: IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Icons.menu),
      //   ),
      // ),
      actionsIconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : FlexColor.bahamaBlueLightPrimary),
      title: AnimatedPadding(
        curve: Curves.easeOutSine,
        duration: const Duration(milliseconds: 300),
        padding: avatarStackPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 4,
              child: FittedBox(
                child: Wrap(
                  spacing: 16.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Animate(
                        effects: const [
                          FadeEffect(),
                          SlideEffect(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeOutSine,
                              begin: Offset(-1.0, 0),
                              end: Offset(0, 0))
                          // RotateEffect(
                          //     curve: Curves.easeOutBack,
                          //     duration: Duration(milliseconds: 500),
                          //     begin: -0.25,
                          //     end: 0.0,
                          //     alignment: Alignment.centerLeft)
                        ],
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                deserializeIcon(widget.placeList.icon) ??
                                    Icons.list_alt_rounded,
                                size: widget.placeList.icon
                                        .containsValue('fontAwesomeIcons')
                                    ? 28
                                    : 32,
                              )),
                        )),
                    Animate(
                      effects: const [
                        FadeEffect(),
                        RotateEffect(
                            curve: Curves.easeOutBack,
                            duration: Duration(milliseconds: 500),
                            begin: -0.25,
                            end: 0.0,
                            alignment: Alignment.centerLeft)
                      ],
                      child: Text(
                        widget.placeList.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Animate(
                effects: const [
                  FadeEffect(),
                  SlideEffect(
                      duration: Duration(milliseconds: 700),
                      curve: Curves.easeOutQuart,
                      begin: Offset(0.5, 0.0),
                      end: Offset(0.0, 0.0)),
                ],
                child: BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
                  builder: (context, state) {
                    if (state is SavedPlacesLoading) {
                      return LoadingAnimationWidget.beat(
                          color: FlexColor.bahamaBlueDarkSecondary, size: 18.0);
                    }
                    if (state is SavedPlacesLoaded) {
                      return Showcase(
                        key: widget.avatarStackKey,
                        targetBorderRadius: BorderRadius.circular(50),
                        targetPadding: const EdgeInsets.all(8.0),
                        descriptionAlignment: TextAlign.center,
                        description: 'Contributor avatars will show up here!',
                        child: AvatarStack(
                          settings: RestrictedPositions(
                              align: StackAlign.right,
                              laying: StackLaying.first),
                          borderWidth: 2.0,
                          borderColor:
                              Theme.of(context).chipTheme.backgroundColor,
                          width: 70,
                          height: 40,
                          avatars: [
                            CachedNetworkImageProvider(
                                widget.listOwner.profilePicture!),
                            for (User user in state.contributors)
                              CachedNetworkImageProvider(user.profilePicture!),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('Error Loading Avatars!'),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton(
            position: PopupMenuPosition.under,
            icon: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).brightness == Brightness.light
                  ? FlexColor.bahamaBlueLightPrimary
                  : Colors.white,
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () => WidgetsBinding.instance
                        .addPostFrameCallback((timeStamp) {
                      showDialog(
                        context: context,
                        builder: (context) => EditListDialog(
                          placeList: widget.placeList,
                        ),
                      ).then((value) {
                        if (value == true) {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) => const PremiumOffer(),
                          );
                        }
                      });
                    }),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_note_rounded),
                        SizedBox(
                          width: 4.0,
                        ),
                        Text('Edit List'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return DeleteListDialog(
                              placeList: widget.placeList,
                            );
                          },
                        );
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete_forever_rounded),
                        SizedBox(
                          width: 4.0,
                        ),
                        Text('Delete List'),
                      ],
                    ),
                  )
                ]),
      ],
    );
  }
}

class EditListDialog extends StatefulWidget {
  final PlaceList placeList;
  const EditListDialog({
    required this.placeList,
    Key? key,
  }) : super(key: key);

  @override
  State<EditListDialog> createState() => _EditListDialogState();
}

class _EditListDialogState extends State<EditListDialog> {
  final TextEditingController listNameController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    listNameController.text = widget.placeList.name;
    super.initState();
  }

  IconData? selectedIcon;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 160,
        height: 210,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Edit List',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: BlocBuilder<PurchasesBloc, PurchasesState>(
                      builder: (context, state) {
                        if (state is PurchasesLoading) {
                          return LoadingAnimationWidget.staggeredDotsWave(
                              color: FlexColor.bahamaBlueDarkSecondary,
                              size: 20.0);
                        }
                        if (state is PurchasesLoaded) {
                          if (state.isSubscribed == false) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size.fromHeight(50),
                                  side: BorderSide(
                                      width: 2.0,
                                      color: Theme.of(context)
                                          .inputDecorationTheme
                                          .enabledBorder!
                                          .borderSide
                                          .color)),
                              onPressed: () async {
                                Navigator.pop(context, true);
                              },
                              child: selectedIcon == null
                                  ? Icon(
                                      deserializeIcon(widget.placeList.icon) ??
                                          Icons.list_alt_rounded)
                                  : Icon(selectedIcon),
                            );
                          }
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size.fromHeight(50),
                                side: BorderSide(
                                    width: 2.0,
                                    color: Theme.of(context)
                                        .inputDecorationTheme
                                        .enabledBorder!
                                        .borderSide
                                        .color)),
                            onPressed: () async {
                              IconData? icon = await pickIcon(context);

                              if (icon == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                    'No Icon Selected!',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              }
                            },
                            child: selectedIcon == null
                                ? Icon(deserializeIcon(widget.placeList.icon) ??
                                    Icons.list_alt_rounded)
                                : Icon(selectedIcon),
                          );
                        } else {
                          return const Center(
                            child: Text('Error'),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        // onChanged: (value) {
                        //   setState(() {
                        //     textLength = value.length;
                        //   });
                        // },
                        // maxLength: 20,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp("[A-Za-z0-9#+-. ]*")),
                        ],
                        textCapitalization: TextCapitalization.words,
                        controller: listNameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          // suffixText:
                          //     '${textLength.toString()}/${maxLength.toString()}',
                          // suffixStyle: Theme.of(context).textTheme.bodySmall,
                          //   counterText: "",
                          isDense: true,
                          filled: true,
                          hintText: "ex. Breakfast Ideas...",
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 2.0, color: Colors.redAccent)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(
                                  width: 2.0, color: Colors.redAccent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide(
                                  width: 2.0,
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .enabledBorder!
                                      .borderSide
                                      .color)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              BlocConsumer<SavedListsBloc, SavedListsState>(
                listener: (context, state) async {
                  if (state is SavedListsUpdated) {
                    await Future.delayed(const Duration(seconds: 1),
                        () => Navigator.pop(context));
                  }
                },
                builder: (context, state) {
                  if (state is SavedListsLoading) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: FlexColor.bahamaBlueDarkSecondary,
                            size: 18.0));
                  }
                  if (state is SavedListsUpdated) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: Icon(
                          Icons.check,
                          color: Colors.green.shade400,
                        ));
                  }
                  return ElevatedButton(
                      onPressed: () {
                        if (selectedIcon != null) {
                          context.read<SavedListsBloc>().add(UpdateSavedLists(
                              placeList: widget.placeList.copyWith(
                                  name: listNameController.value.text,
                                  icon: serializeIcon(selectedIcon!))));
                          // context
                          //     .read<SavedPlacesBloc>()
                          //     .add(LoadPlaces(placeList: widget.placeList));
                        } else {
                          context.read<SavedListsBloc>().add(UpdateSavedLists(
                              placeList: widget.placeList.copyWith(
                                  name: listNameController.value.text)));
                        }
                      },
                      child: const Text('Update List'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoButton extends StatelessWidget {
  final List<Place> places;
  const GoButton({
    Key? key,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        if (state is PurchasesLoading) {
          return LoadingAnimationWidget.staggeredDotsWave(
              color: FlexColor.bahamaBlueDarkSecondary, size: 20.0);
        }
        if (state is PurchasesLoaded) {
          if (state.isSubscribed != true) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Animate(
                effects: const [SlideEffect()],
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => const PremiumOffer(),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(60, 35),
                    minimumSize: const Size(30, 30),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 6.0),
                    child: Icon(
                      FontAwesomeIcons.dice,
                      size: 18,
                    ),
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Animate(
              effects: const [SlideEffect()],
              child: ElevatedButton(
                onPressed: places.isEmpty && places.length < 2
                    ? () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            'Add at least two places!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                        ))
                    : () {
                        context.read<RandomWheelCubit>().loadWheel(places);
                        //context.goNamed('random-wheel');
                      },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 30),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Icon(
                    FontAwesomeIcons.dice,
                    size: 18,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Error!'),
          );
        }
      },
    );
  }
}

class InviteButton extends StatelessWidget {
  final PlaceList placeList;
  const InviteButton({
    required this.placeList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        if (state is PurchasesLoading) {
          return LoadingAnimationWidget.staggeredDotsWave(
              color: FlexColor.bahamaBlueDarkSecondary, size: 20.0);
        }
        if (state is PurchasesLoaded && state.isSubscribed == true) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Animate(
              effects: const [SlideEffect()],
              child: ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    showDialog(
                      useRootNavigator: false,
                      context: context,
                      builder: (dialogContext) {
                        return InviteDialog(
                            placeList: placeList, dialogContext: dialogContext);
                      },
                    );
                  });
                  //context.goNamed('random-wheel');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 20),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.person_add_alt_rounded,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is PurchasesLoaded && state.isSubscribed != true) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Animate(
              effects: const [SlideEffect()],
              child: ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return const PremiumOffer();
                      },
                    );
                  });
                  //context.goNamed('random-wheel');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 20),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.person_add_alt_rounded,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Error!'),
          );
        }
      },
    );
  }
}

class EditButton extends StatelessWidget {
  final PlaceList placeList;
  final List<Place> places;
  const EditButton({
    required this.places,
    required this.placeList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Animate(
        effects: const [SlideEffect()],
        child: BlocBuilder<EditPlacesBloc, EditPlacesState>(
          builder: (context, state) {
            if (state is EditPlacesStarted) {
              return ElevatedButton(
                onPressed: () {
                  context.read<EditPlacesBloc>().add(CancelEditing());
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      width: 2.0,
                      color: FlexColor.bahamaBlueDarkPrimaryContainer),
                  fixedSize: const Size(80, 30),
                  minimumSize: const Size(30, 20),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.checklist_outlined,
                    size: 20,
                  ),
                ),
              );
            }
            return ElevatedButton(
              onPressed: places.isEmpty
                  ? () =>
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'Add a place first!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ))
                  : () {
                      context.read<EditPlacesBloc>().add(StartEditing());
                    },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(60, 35),
                minimumSize: const Size(30, 20),
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: Icon(
                  Icons.checklist_outlined,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
