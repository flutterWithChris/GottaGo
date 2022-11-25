import 'dart:async';
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
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
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
  ScrollController mainScrollController = ScrollController();
  final StreamController<int> controller = StreamController.broadcast();
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();
  late ConfettiController confettiController;

  @override
  void initState() {
    // TODO: implement initState
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

            if (state.places.isNotEmpty) {
              rows = [
                for (Place place in state.places)
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

            return CustomScrollView(
              controller: mainScrollController,
              slivers: [
                CategoryPageAppBar(
                    listOwner: state.listOwner,
                    contributors: contributors,
                    placeList: state.placeList,
                    scrollController: mainScrollController),
                state.places.isNotEmpty
                    ? BlocBuilder<RandomWheelCubit, RandomWheelState>(
                        builder: (context, state) {
                          ScrollController scrollController =
                              ScrollController();

                          if (state is RandomWheelLoading) {
                            return const SliverToBoxAdapter(child: SizedBox());
                          }
                          if (state is RandomWheelLoaded ||
                              state is RandomWheelSpun ||
                              state is RandomWheelChosen) {
                            return SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 16.0, bottom: 8.0),
                                child: Animate(
                                  effects: const [SlideEffect()],
                                  child: FortuneBar(
                                      styleStrategy:
                                          const AlternatingStyleStrategy(),
                                      selected: controller.stream,
                                      onFling: () async {
                                        Random random = Random();
                                        int randomInt =
                                            random.nextInt(places.length);
                                        controller.add(randomInt);
                                        Place place = places[randomInt];
                                        context
                                            .read<RandomWheelCubit>()
                                            .wheelHasChosen(place);
                                        await Future.delayed(
                                            const Duration(seconds: 8),
                                            () => context
                                                .read<RandomWheelCubit>()
                                                .resetWheel());
                                      },
                                      onAnimationEnd: () {
                                        context
                                            .read<ViewPlaceCubit>()
                                            .viewPlace(context
                                                .read<RandomWheelCubit>()
                                                .selectedPlace!);
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
                                                scrollController:
                                                    scrollController);
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: Text(
                                                  place.name!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                            return GoButton(
                              places: places,
                            );
                          }
                        },
                      )
                    : const SliverToBoxAdapter(child: SizedBox()),
                ReorderableSliverList(
                  enabled: false,
                  onReorder: _onReorder,
                  delegate: ReorderableSliverChildBuilderDelegate(
                      childCount: rows.length, (context, index) {
                    return rows[index];
                  }),
                )
              ],
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
              avatarStackPadding = const EdgeInsets.only(right: 28.0);
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Wrap(
            spacing: 16.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Animate(effects: const [
                FadeEffect(),
                SlideEffect(
                    duration: Duration(milliseconds: 1000),
                    curve: Curves.easeOutQuart,
                    begin: Offset(-0.5, 0),
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
          AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutSine,
            padding: avatarStackPadding,
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
                      borderColor: Theme.of(context).chipTheme.backgroundColor,
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
              child: Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: const [
                  Icon(Icons.person_add_alt_1_rounded),
                  Text('Invite Contributor')
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
        child: FractionallySizedBox(
          widthFactor: 0.65,
          child: Animate(
            effects: const [SlideEffect()],
            child: ElevatedButton(
              onPressed: () {
                context.read<RandomWheelCubit>().loadWheel(places);
                //context.goNamed('random-wheel');
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(125, 40),
                minimumSize: const Size(125, 40),
              ),
              child: const Text(
                'Let\'s Go Somewhere',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
