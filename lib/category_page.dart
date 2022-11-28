import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:confetti/confetti.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/place/edit_places_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/cubit/lists/list_sort_cubit.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/widgets/lists/invite_dialog.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
import 'package:leggo/widgets/places/add_place_card.dart';
import 'package:leggo/widgets/places/blank_place_card.dart';
import 'package:leggo/widgets/places/place_card.dart';
import 'package:leggo/widgets/places/search_places_sheet.dart';
import 'package:leggo/widgets/places/view_place_sheet.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:reorderables/reorderables.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    mainScrollController = ScrollController();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const MainBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        shape: const StadiumBorder(),
        // backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
        child: const Icon(Icons.add_location_rounded),
        onPressed: () {
          showModalBottomSheet(
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return SearchPlacesSheet(mounted: mounted);
              });
        },
      ),
      body: BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
        // buildWhen: (previous, current) =>
        //     previous.placeList != current.placeList,
        builder: (context, state) {
          if (state is SavedPlacesLoading || state is SavedPlacesUpdated) {
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
                          color: Theme.of(context).primaryIconTheme.color!,
                          size: 20.0),
                    ],
                  ),
                  actions: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.more_vert)),
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

            print('Places loaded: ${places.length}');

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
                  context.read<ListSortCubit>().state.status == 'Visited'
                      ? context
                          .read<SavedPlacesBloc>()
                          .add(LoadVisitedPlaces(placeList: currentPlaceList))
                      : context
                          .read<SavedPlacesBloc>()
                          .add(LoadPlaces(placeList: currentPlaceList));
                  context.read<SavedListsBloc>().add(LoadSavedLists());
                }
              },
              builder: (context, state) {
                List<Place> selectedPlaces =
                    context.watch<EditPlacesBloc>().selectedPlaces;
                return Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    CustomScrollView(
                      controller: mainScrollController,
                      slivers: [
                        CategoryPageAppBar(
                            listOwner: listOwner,
                            contributors: contributors,
                            placeList: currentPlaceList,
                            scrollController: mainScrollController),
                        RandomPlaceBar(
                            currentPlaceList: currentPlaceList,
                            controller: controller,
                            places: places),
                        ReorderableSliverList(
                          enabled: false,
                          onReorder: _onReorder,
                          delegate: ReorderableSliverChildBuilderDelegate(
                              childCount: rows.length, (context, index) {
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: selectionType == 0
                                      ? ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade600,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            context
                                                        .read<ListSortCubit>()
                                                        .state
                                                        .status ==
                                                    'Visited'
                                                ? context
                                                    .read<EditPlacesBloc>()
                                                    .add(DeleteVisitedPlaces(
                                                        placeList:
                                                            currentPlaceList))
                                                : context
                                                    .read<EditPlacesBloc>()
                                                    .add(DeletePlaces(
                                                        placeList:
                                                            currentPlaceList));
                                            // context.read<EditPlacesBloc>().add(
                                            //     FinishEditing(places: places, placeList: placeList));
                                          },
                                          child: Text.rich(TextSpan(children: [
                                            const TextSpan(text: 'Delete '),
                                            TextSpan(
                                                text:
                                                    '${selectedPlaces.length} ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const TextSpan(text: 'Places'),
                                          ])))
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: FlexColor
                                                .bahamaBlueLightPrimary,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            print('pressed');
                                            context.read<EditPlacesBloc>().add(
                                                MarkVisitedPlaces(
                                                    placeList:
                                                        currentPlaceList));
                                            // context.read<EditPlacesBloc>().add(
                                            //     FinishEditing(places: places, placeList: placeList));
                                          },
                                          child: Text.rich(TextSpan(children: [
                                            const TextSpan(text: 'Mark '),
                                            TextSpan(
                                                text:
                                                    '${selectedPlaces.length} ',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const TextSpan(
                                                text: 'Places Visited'),
                                          ])))),
                              selectionType == 0
                                  ? context
                                              .read<ListSortCubit>()
                                              .state
                                              .status ==
                                          'Visited'
                                      ? const SizedBox()
                                      : PopupMenuButton(
                                          position: PopupMenuPosition.under,
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
                                                child:
                                                    const Text('Mark Visited'))
                                          ],
                                        )
                                  : PopupMenuButton(
                                      position: PopupMenuPosition.under,
                                      icon: const CircleAvatar(
                                          child: Icon(
                                              Icons.keyboard_arrow_down_sharp)),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            onTap: () {
                                              setState(() {
                                                selectionType = 0;
                                              });
                                            },
                                            child: const Text('Delete Places'))
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
            return const Center(child: Text('Something Went Wrong...'));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    draggableScrollableController.dispose();
    super.dispose();
  }
}

class RandomPlaceBar extends StatelessWidget {
  final PlaceList currentPlaceList;
  const RandomPlaceBar({
    super.key,
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
                      print(
                          'Selected Place: ${context.read<RandomWheelCubit>().selectedPlace!.name}');
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
            places: places,
            currentPlaceList: currentPlaceList,
          );
        }
      },
    );
  }
}

class PlaceListButtonBar extends StatefulWidget {
  const PlaceListButtonBar({
    super.key,
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
              child: DropdownButton<String>(
                isDense: true,
                underline: const SizedBox(),
                value: dropdownValue,
                items: [
                  DropdownMenuItem(
                    value: 'Not Visited',
                    child: const Text('Not Visited'),
                    onTap: () {
                      context
                          .read<ListSortCubit>()
                          .sortByVisitedStatus('Not Visited');
                      context
                          .read<SavedPlacesBloc>()
                          .add(LoadPlaces(placeList: widget.currentPlaceList));
                    },
                  ),
                  DropdownMenuItem(
                    value: 'Visited',
                    child: const Text('Visited'),
                    onTap: () {
                      context
                          .read<ListSortCubit>()
                          .sortByVisitedStatus('Visited');
                      context.read<SavedPlacesBloc>().add(LoadVisitedPlaces(
                          placeList: widget.currentPlaceList));
                    },
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    dropdownValue = value!;
                  });
                },
              ),
            ),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EditButton(
                      places: widget.places,
                      placeList:
                          context.read<SavedPlacesBloc>().state.placeList!),
                  // const SizedBox(
                  //   width: 8.0,
                  // ),
                  GoButton(
                    places: widget.places,
                  ),
                  // const SizedBox(
                  //   width: 8.0,
                  // ),
                  InviteButton(
                      placeList:
                          context.read<SavedPlacesBloc>().state.placeList!),
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
    required this.scrollController,
    required this.listOwner,
  }) : super(key: key);

  final List<User>? contributors;
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
                    Animate(effects: const [
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
                    ], child: const Icon(FontAwesomeIcons.earthAmericas)),
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
                      return AvatarStack(
                        settings: RestrictedPositions(
                            align: StackAlign.right, laying: StackLaying.first),
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
          color: Theme.of(context).scaffoldBackgroundColor,
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  showDialog(
                    useRootNavigator: false,
                    context: context,
                    builder: (dialogContext) {
                      return InviteDialog(
                          placeList: widget.placeList,
                          dialogContext: dialogContext);
                    },
                  );
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 18,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Invite Contributor'),
                  )
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
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
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Animate(
        effects: const [SlideEffect()],
        child: ElevatedButton(
          onPressed: places.isEmpty && places.length < 2
              ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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
