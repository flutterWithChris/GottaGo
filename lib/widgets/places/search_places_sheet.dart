import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_place/google_place.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';
import 'package:leggo/category_page.dart';

import '../../bloc/saved_categories/bloc/saved_lists_bloc.dart';
import '../../bloc/saved_places/bloc/saved_places_bloc.dart';
import '../../model/place.dart';

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
                                        placeDetails.rating != null
                                            ? RatingBar.builder(
                                                ignoreGestures: true,
                                                itemSize: 20.0,
                                                allowHalfRating: true,
                                                initialRating:
                                                    placeDetails.rating!,
                                                itemBuilder: (context, index) {
                                                  return const Icon(
                                                    Icons.star,
                                                    size: 12.0,
                                                    color: Colors.amber,
                                                  );
                                                },
                                                onRatingUpdate: (value) {},
                                              )
                                            : const SizedBox(),
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
