import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_place/google_place.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/widgets/lists/invite_dialog.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
import 'package:leggo/widgets/places/add_place_card.dart';
import 'package:leggo/widgets/places/blank_place_card.dart';
import 'package:leggo/widgets/places/place_card.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GooglePlace googlePlace =
        GooglePlace(dotenv.env['GOOGLE_PLACES_API_KEY']!);

    final TextEditingController textEditingController = TextEditingController();

    Future<Uint8List?> getPhotos(String photoReference) async {
      var photo = await googlePlace.photos.get(photoReference, 1080, 1920);
      return photo;
    }

    return SafeArea(
      child: Scaffold(
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
                  return SearchPlacesSheet(
                      googlePlace: googlePlace, mounted: mounted);
                });
          },
        ),
        body: BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
          buildWhen: (previous, current) =>
              previous.placeList != current.placeList,
          builder: (context, state) {
            print('Current State: ${state.toString()}');
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
                        SlideEffect(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            begin: Offset(-0.5, 0),
                            end: Offset(0, 0))
                      ],
                      child: const BlankPlaceCard(),
                    ),
                  )
              ];
              rows.insert(
                0,
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Animate(
                    effects: const [
                      SlideEffect(
                        curve: Curves.easeInOutBack,
                        // begin: Offset(-0.5, 0),
                      )
                    ],
                    child: const AddPlaceCard(),
                  ),
                ),
              );
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
              List<User> contributors = state.contributors;
              List<String> contributorAvatars = [];

              contributorAvatars.add(state.listOwner.profilePicture);
              for (User user in contributors) {
                contributorAvatars.add(user.profilePicture);
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
                    PlaceCard(
                        place: place,
                        imageUrl: place.mainPhoto,
                        memoryImage: place.mainPhoto,
                        placeName: place.name,
                        ratingsTotal: place.rating,
                        placeDescription: place.description,
                        closingTime: place.closingTime,
                        placeLocation: place.city)
                ];
              } else {
                rows = [
                  for (int i = 0; i < 5; i++)
                    const Opacity(
                      opacity: 0.4,
                      child: BlankPlaceCard(),
                    )
                ];
                rows.insert(
                  0,
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: AddPlaceCard(),
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
                      ? const GoButton()
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

  final List<User> contributors;
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
          if (widget.scrollController.offset > 70) {
            setState(() {
              avatarStackPadding = const EdgeInsets.only(right: 28.0);
            });
          } else if (widget.scrollController.hasClients &&
              widget.scrollController.offset < 70) {
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
                    curve: Curves.easeOutQuint,
                    begin: Offset(-0.5, 0),
                    end: Offset(0, 0))
                // RotateEffect(
                //     curve: Curves.easeOutBack,
                //     duration: Duration(milliseconds: 500),
                //     begin: -0.25,
                //     end: 0.0,
                //     alignment: Alignment.centerLeft)
              ], child: const Icon(FontAwesomeIcons.plane)),
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
              child: AvatarStack(
                settings: RestrictedPositions(
                    align: StackAlign.right, laying: StackLaying.first),
                borderWidth: 2.0,
                borderColor: Theme.of(context).chipTheme.backgroundColor,
                width: 70,
                height: 40,
                avatars: [
                  CachedNetworkImageProvider(widget.listOwner.profilePicture),
                  for (User user in widget.contributors.reversed)
                    CachedNetworkImageProvider(user.profilePicture),
                ],
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
                    context: context,
                    builder: (context) {
                      return InviteDialog(placeList: widget.placeList);
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

class SearchPlacesSheet extends StatefulWidget {
  const SearchPlacesSheet({
    Key? key,
    required this.googlePlace,
    required this.mounted,
  }) : super(key: key);

  final GooglePlace googlePlace;
  final bool mounted;

  @override
  State<SearchPlacesSheet> createState() => _SearchPlacesSheetState();
}

class _SearchPlacesSheetState extends State<SearchPlacesSheet> {
  Future<Uint8List?> getPhotos(DetailsResult detailsResult) async {
    var placeDetails = detailsResult;
    var photo = await widget.googlePlace.photos
        .get(placeDetails.photos!.first.photoReference!, 1080, 1920);
    return photo;
  }

  DraggableScrollableController? scrollableController;

  @override
  void initState() {
    scrollableController = DraggableScrollableController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: scrollableController,
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListView(
            shrinkWrap: true,
            controller: scrollController,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: TypeAheadField(
                  // keepSuggestionsOnSuggestionSelected: true,
                  textFieldConfiguration: TextFieldConfiguration(
                      style: const TextStyle(color: Colors.black87),
                      autofocus: true,
                      decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Colors.black87),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(50.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(50.0)),
                          contentPadding: const EdgeInsets.all(0),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          hintText: 'Search Places...',
                          prefixIcon: const Icon(Icons.search_rounded))),
                  suggestionsCallback: (pattern) async {
                    List<AutocompletePrediction> predictions = [];
                    if (pattern.isEmpty) return predictions;
                    var place =
                        await widget.googlePlace.autocomplete.get(pattern);
                    predictions = place!.predictions!;
                    return predictions;
                  },
                  itemBuilder: (context, itemData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 4.0),
                      child: ListTile(
                        title: Text(itemData.description!),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    var placeDetails = await widget.googlePlace.details
                        .get(suggestion.placeId!);
                    placeDetails!.result!.name;
                    context.read<PlaceSearchBloc>().add(
                        PlaceSelected(detailsResult: placeDetails.result!));
                    // await scrollController.animateTo(1.5,
                    //     duration: const Duration(milliseconds: 500),
                    //     curve: Curves.easeOut);
                    // await scrollableController!.animateTo(0.8,
                    //     duration: const Duration(milliseconds: 150),
                    //     curve: Curves.easeOutBack);

                    if (!widget.mounted) return;
                  },
                ),
              ),
              BlocConsumer<PlaceSearchBloc, PlaceSearchState>(
                listener: (context, state) {
                  if (state.status == Status.loaded) {
                    scrollableController!.animateTo(0.72,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack);
                  }
                },
                buildWhen: (previous, current) =>
                    previous.detailsResult != current.detailsResult,
                builder: (context, state) {
                  if (state.status == Status.initial) {
                    return const SizedBox();
                  }
                  if (state.status == Status.loaded) {
                    var placeDetails = state.detailsResult;

                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 24.0),
                                    child: FittedBox(
                                      child: Text(
                                        placeDetails!.name!,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: BlocBuilder<PlaceSearchBloc,
                                        PlaceSearchState>(
                                      buildWhen: (previous, current) =>
                                          previous.detailsResult !=
                                          current.detailsResult,
                                      builder: (context, state) {
                                        return FutureBuilder(
                                            future: getPhotos(placeDetails),
                                            builder: (context, snapshot) {
                                              return AspectRatio(
                                                aspectRatio: 16 / 9,
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) {
                                                    return AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: Center(
                                                        child: Animate(
                                                          onPlay: (controller) {
                                                            controller.repeat();
                                                          },
                                                          effects: const [
                                                            ShimmerEffect(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            2))
                                                          ],
                                                          child: Container(
                                                            height: 300,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  imageUrl:
                                                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${placeDetails.photos![0].photoReference}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            });
                                      },
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(150, 30)),
                                      onPressed: () {},
                                      icon: const Icon(Icons.web_rounded,
                                          size: 18),
                                      label: const Text('Visit Website')),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: FittedBox(
                                      child: Wrap(
                                        spacing: 4.0,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.place_rounded,
                                            size: 18,
                                          ),
                                          Text(placeDetails.formattedAddress!),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      spacing: 6.0,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        RatingBar.builder(
                                          ignoreGestures: true,
                                          itemSize: 20.0,
                                          allowHalfRating: true,
                                          initialRating: placeDetails.rating!,
                                          itemBuilder: (context, index) {
                                            return const Icon(
                                              Icons.star,
                                              size: 12.0,
                                              color: Colors.amber,
                                            );
                                          },
                                          onRatingUpdate: (value) {},
                                        ),
                                        Text(placeDetails.rating.toString()),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Chip(
                                      label: Text(placeDetails.types!.first
                                          .capitalizeString()),
                                      avatar: Image.network(
                                        placeDetails.icon!,
                                        height: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                                onPressed: () {
                                  print('Place Added: ${placeDetails.name}');
                                  context
                                      .read<SavedListsBloc>()
                                      .add(UpdateSavedLists());
                                  context.read<SavedPlacesBloc>().add(AddPlace(
                                      placeList: context
                                          .read<SavedPlacesBloc>()
                                          .state
                                          .placeList!,
                                      place: Place(
                                          googlePlaceId:
                                              placeDetails.placeId ?? '',
                                          website: placeDetails.website ?? '',
                                          closingTime: placeDetails
                                                  .openingHours?.openNow
                                                  .toString() ??
                                              '',
                                          review:
                                              placeDetails.reviews![0].text ??
                                                  '',
                                          rating: placeDetails.rating ?? 0,
                                          name: placeDetails.name!,
                                          address:
                                              placeDetails.formattedAddress ??
                                                  '',
                                          description: placeDetails.reviews !=
                                                  null
                                              ? placeDetails.reviews![0].text
                                              : '',
                                          city:
                                              '${placeDetails.addressComponents![0].shortName}',
                                          type: placeDetails.types![0],
                                          mainPhoto: placeDetails
                                              .photos!.first.photoReference!)));
                                  Navigator.pop(context);
                                },
                                icon:
                                    const Icon(Icons.add_location_alt_outlined),
                                label: Text.rich(TextSpan(
                                  children: [
                                    const TextSpan(text: 'Add to '),
                                    TextSpan(
                                        text: context
                                            .read<SavedPlacesBloc>()
                                            .state
                                            .placeList!
                                            .name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ))),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('Something Went Wrong..'),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class GoButton extends StatelessWidget {
  const GoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
        child: FractionallySizedBox(
          widthFactor: 0.65,
          child: ElevatedButton(
            onPressed: () {
              context.goNamed('random-wheel');
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
    );
  }
}
