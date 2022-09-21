import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
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
import 'package:leggo/model/user.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
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

  @override
  Widget build(BuildContext context) {
    final ScrollController mainScrollController = ScrollController();
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
          builder: (context, state) {
            print('Current State: ${state.toString()}');
            if (state is SavedPlacesLoading || state is SavedPlacesUpdated) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar.medium(
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
                        LoadingAnimationWidget.prograssiveDots(
                            color: Theme.of(context).primaryColor, size: 18.0),
                      ],
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_vert)),
                    ],
                  ),
                  SliverFillRemaining(
                    child: Center(
                      child: LoadingAnimationWidget.inkDrop(
                          color: FlexColor.materialDarkSecondaryHc, size: 40.0),
                    ),
                  ),
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

              rows = [
                for (Place place in state.places)
                  Animate(
                    effects: const [SlideEffect(curve: Curves.easeInOutBack)],
                    child: PlaceCard(
                        place: place,
                        imageUrl: place.mainPhoto,
                        memoryImage: place.mainPhoto,
                        placeName: place.name,
                        ratingsTotal: place.rating,
                        placeDescription: place.description,
                        closingTime: place.closingTime,
                        placeLocation: place.city),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 12.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(FontAwesomeIcons.egg),
                            Text(
                              state.placeList.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        AvatarStack(
                          settings: RestrictedPositions(
                              align: StackAlign.right,
                              laying: StackLaying.first),
                          borderWidth: 2.0,
                          borderColor:
                              Theme.of(context).chipTheme.backgroundColor,
                          width: 70,
                          height: 40,
                          avatars: [
                            for (User user in contributors.reversed)
                              CachedNetworkImageProvider(user.profilePicture),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.more_vert)),
                    ],
                  ),
                  const GoButton(),
                  ReorderableSliverList(
                    enabled: false,
                    onReorder: _onReorder,
                    delegate: ReorderableSliverChildBuilderDelegate(
                        childCount: state.places.length, (context, index) {
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
                  textFieldConfiguration: TextFieldConfiguration(
                      autofocus: true,
                      decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(50.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 3.0),
                              borderRadius: BorderRadius.circular(50.0)),
                          contentPadding: const EdgeInsets.all(0),
                          filled: true,
                          fillColor:
                              Theme.of(context).chipTheme.backgroundColor,
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
                          horizontal: 4.0, vertical: 2.0),
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
                    await scrollableController!.animateTo(0.8,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack);

                    if (!widget.mounted) return;
                  },
                ),
              ),
              BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
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
                                              if (snapshot.hasData) {
                                                return AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: Image.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              } else {
                                                return AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child: Center(
                                                    child: Animate(
                                                      onPlay: (controller) {
                                                        controller.repeat();
                                                      },
                                                      effects: const [
                                                        ShimmerEffect(
                                                            duration: Duration(
                                                                seconds: 2))
                                                      ],
                                                      child: Container(
                                                        height: 300,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
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
                                              '${placeDetails.addressComponents![2].shortName}, ${placeDetails.addressComponents![6].shortName}',
                                          type: placeDetails.types![0],
                                          mainPhoto: placeDetails
                                              .photos!.first.photoReference!)));
                                  Navigator.pop(context);
                                },
                                icon:
                                    const Icon(Icons.add_location_alt_outlined),
                                label: Text(
                                    'Add to ${context.read<SavedPlacesBloc>().state.placeList!.name}')),
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

class PlaceCard extends StatefulWidget {
  final String? memoryImage;
  final String? imageUrl;
  final String placeName;
  final String? placeDescription;
  final String? closingTime;
  final String placeLocation;
  final double? ratingsTotal;
  final Place place;
  const PlaceCard({
    Key? key,
    required this.place,
    this.memoryImage,
    this.imageUrl,
    required this.placeName,
    this.placeDescription,
    this.closingTime,
    this.ratingsTotal,
    required this.placeLocation,
  }) : super(key: key);

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard> {
  final GooglePlace googlePlace =
      GooglePlace(dotenv.env['GOOGLE_PLACES_API_KEY']!);
  Future<Uint8List?> getPhotos(String photoReference) async {
    Uint8List? photo = await googlePlace.photos.get(photoReference, 1080, 1920);

    return photo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: LimitedBox(
        maxWidth: 375,
        maxHeight: 200,
        child: Card(
          //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: SizedBox(
                    width: 120,
                    height: 175,
                    child: Expanded(
                        child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${widget.place.mainPhoto}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
                        fit: BoxFit.cover,
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            child: const SizedBox(child: Text('Error')),
                          );
                        },
                      ),
                    )),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ListTile(
                    visualDensity: const VisualDensity(vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 4.0),
                    //tileColor: Colors.white,

                    title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Wrap(
                        //spacing: 24.0,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            widget.placeName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 5.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_pin,
                                size: 13,
                              ),
                              Text(
                                widget.place.city,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FutureBuilder(
                                future: googlePlace.details
                                    .get(widget.place.googlePlaceId),
                                builder: (context, snapshot) {
                                  var data = snapshot.data;
                                  if (data == null) {
                                    return const SizedBox();
                                  } else {
                                    if (data.result!.openingHours!.openNow ==
                                        true) {
                                      return Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6.0,
                                        children: [
                                          const CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Colors.lightGreen,
                                          ),
                                          Text(
                                            'Open Now',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Wrap(
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          spacing: 6.0,
                                          children: [
                                            const CircleAvatar(
                                              radius: 3,
                                              backgroundColor: Colors.red,
                                            ),
                                            Text(
                                              'Closed Now',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ]);
                                    }
                                  }
                                }),
                            widget.ratingsTotal != null
                                ? SizedBox(
                                    height: 28,
                                    child: FittedBox(
                                      child: Chip(
                                        backgroundColor: Colors.transparent,
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                        visualDensity: VisualDensity.compact,
                                        label: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8.0,
                                            children: [
                                              RatingBar.builder(
                                                  itemSize: 18.0,
                                                  initialRating:
                                                      widget.place.rating!,
                                                  allowHalfRating: true,
                                                  ignoreGestures: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return const Icon(
                                                      Icons.star,
                                                      size: 18.0,
                                                      color: Colors.amber,
                                                    );
                                                  },
                                                  onRatingUpdate: (rating) {}),
                                              Text(widget.ratingsTotal
                                                  .toString())
                                            ]),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 28,
                                    child: FittedBox(
                                      child: Chip(
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                        visualDensity: VisualDensity.compact,
                                        label: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8.0,
                                            children: const [
                                              Icon(
                                                Icons.star,
                                                size: 18.0,
                                                color: Colors.amber,
                                              ),
                                              Text('5.0')
                                            ]),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        widget.placeDescription != null
                            ? Text(
                                widget.placeDescription!,
                                maxLines: 3,
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
