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
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/model/place.dart';
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
                        Wrap(
                          spacing: 12.0,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(FontAwesomeIcons.egg),
                            Text(
                              'Breakfast',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              child: ClipOval(
                                child: Image.network(
                                  'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/305213660_5298775460244393_3700270719083305575_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=bMWpIPCteosAX8qjwkc&_nc_ht=scontent-lga3-1.xx&oh=00_AT86-u9G7umbF3INUcptE50pu8BtGUPBzycr9727gmiR4w&oe=632405F2',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 30,
                              child: CircleAvatar(
                                child: ClipOval(
                                  child: Image.network(
                                    'https://scontent-lga3-1.xx.fbcdn.net/v/t1.6435-9/193213907_4419559838077181_2959395753433319266_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=rkR7hr7w5fAAX_2k6sX&_nc_ht=scontent-lga3-1.xx&oh=00_AT_JTX03j8CNcJ0tdmD4iY7tY_Z8lJiv7Zv5DVgNlWIfAw&oe=63444DA4',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              'Breakfast',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              child: ClipOval(
                                child: Image.network(
                                  'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/305213660_5298775460244393_3700270719083305575_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=bMWpIPCteosAX8qjwkc&_nc_ht=scontent-lga3-1.xx&oh=00_AT86-u9G7umbF3INUcptE50pu8BtGUPBzycr9727gmiR4w&oe=632405F2',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 30,
                              child: CircleAvatar(
                                child: ClipOval(
                                  child: Image.network(
                                    'https://scontent-lga3-1.xx.fbcdn.net/v/t1.6435-9/193213907_4419559838077181_2959395753433319266_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=rkR7hr7w5fAAX_2k6sX&_nc_ht=scontent-lga3-1.xx&oh=00_AT_JTX03j8CNcJ0tdmD4iY7tY_Z8lJiv7Zv5DVgNlWIfAw&oe=63444DA4',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
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
    // TODO: implement initState
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
                          contentPadding: const EdgeInsets.all(0),
                          filled: true,
                          fillColor:
                              Theme.of(context).chipTheme.backgroundColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
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
                    await scrollableController!.animateTo(0.7,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack);

                    if (!widget.mounted) return;
                  },
                ),
              ),
              BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
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
                                    child: FutureBuilder(
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
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                  ),
                                  OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(150, 30)),
                                      onPressed: () {},
                                      icon: const Icon(Icons.web_rounded,
                                          size: 18),
                                      label: const Text('Visit Website')),
                                  Wrap(
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

                                  context.read<SavedPlacesBloc>().add(AddPlace(
                                      place: Place(
                                          rating: placeDetails.rating!,
                                          name: placeDetails.name!,
                                          address:
                                              placeDetails.formattedAddress!,
                                          description: placeDetails.reviews !=
                                                  null
                                              ? placeDetails.reviews![0].text
                                              : null,
                                          city:
                                              '${placeDetails.addressComponents![2].shortName}, ${placeDetails.addressComponents![6].shortName}',
                                          type: placeDetails.types![0],
                                          mainPhoto: placeDetails.photos != null
                                              ? placeDetails
                                                  .photos!.first.photoReference!
                                              : null)));
                                  Navigator.pop(context);
                                },
                                icon:
                                    const Icon(Icons.add_location_alt_outlined),
                                label: const Text('Add to Breakfast Ideas')),
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

// RichText(
//                       text: TextSpan(

//                           children: [
//                             TextSpan(text: 'Add to'),
//                             TextSpan(
//                                 text: ' Breakfast Ideas',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ))
//                           ]),
//                     )

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
        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
    var photo = await googlePlace.photos.get(photoReference, 1080, 1920);
    return photo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ListTile(
            visualDensity: const VisualDensity(vertical: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            //tileColor: Colors.white,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SizedBox(
                height: 100,
                width: 100,
                child: widget.memoryImage != null
                    ? FutureBuilder(
                        future: getPhotos(widget.memoryImage!),
                        builder: (context, snapshot) {
                          var data = snapshot;
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return Center(
                              child: LoadingAnimationWidget.discreteCircle(
                                  color: Theme.of(context).primaryColor,
                                  size: 30.0),
                            );
                          }
                          if (!snapshot.hasData) {
                            return Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                            );
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      )
                    : Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                        widget.placeLocation,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontWeight: FontWeight.bold),
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
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open \'Til ${widget.closingTime}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 6.0,
                        ),
                        const CircleAvatar(
                          radius: 3,
                          backgroundColor: Colors.lightGreen,
                        ),
                        const SizedBox(
                          width: 12.0,
                        ),
                      ],
                    ),
                    widget.ratingsTotal != null
                        ? SizedBox(
                            height: 28,
                            child: FittedBox(
                              child: Chip(
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                visualDensity: VisualDensity.compact,
                                label: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 8.0,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 18.0,
                                        color: Colors.amber,
                                      ),
                                      Text(widget.ratingsTotal.toString())
                                    ]),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 28,
                            child: FittedBox(
                              child: Chip(
                                labelPadding: const EdgeInsets.symmetric(
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
                          )
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
      ),
    );
  }
}
