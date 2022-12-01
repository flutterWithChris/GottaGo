import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:leggo/bloc/autocomplete/bloc/autocomplete_bloc.dart';
import 'package:leggo/bloc/place/place_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';

import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/place.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchPlacesSheet extends StatefulWidget {
  const SearchPlacesSheet({
    Key? key,
    required this.mounted,
  }) : super(key: key);

  final bool mounted;

  @override
  State<SearchPlacesSheet> createState() => _SearchPlacesSheetState();
}

class _SearchPlacesSheetState extends State<SearchPlacesSheet> {
  DraggableScrollableController? scrollableController;
  // final FloatingSearchBarController controller = FloatingSearchBarController();

  @override
  void initState() {
    scrollableController = DraggableScrollableController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: scrollableController,
      initialChildSize:
          context.watch<PlaceBloc>().state is PlaceLoaded ? 0.89 : 0.6,
      maxChildSize: 0.89,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListView(
            shrinkWrap: true,
            controller: scrollController,
            // mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: IntrinsicHeight(
                    child: PlaceSearchBar(),
                  )),
              BlocConsumer<PlaceBloc, PlaceState>(
                listener: (context, state) {
                  if (state is PlaceLoaded) {
                    scrollableController!.animateTo(0.8,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOutBack);
                  }
                },
                builder: (context, state) {
                  if (state is PlaceLoading) {
                    return const SizedBox();
                  }
                  if (state is PlaceLoaded) {
                    GooglePlace googlePlace = state.googlePlace;
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                child: Column(
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional.topCenter,
                                      children: [
                                        AspectRatio(
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
                                            },
                                            imageUrl:
                                                'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${state.googlePlace.photos![0]['photo_reference']}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 8.0,
                                          top: 8.0,
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 12.0,
                                            children: [
                                              googlePlace.website != null
                                                  ? CircleAvatar(
                                                      radius: 18,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          launchWebView(Uri
                                                              .https(googlePlace
                                                                  .website!));
                                                        },
                                                        icon: const Icon(
                                                            Icons.web_rounded,
                                                            size: 16),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                              googlePlace.formattedPhoneNumber !=
                                                      null
                                                  ? CircleAvatar(
                                                      radius: 18,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          launchCall(Uri(
                                                              scheme: 'tel',
                                                              path: googlePlace
                                                                  .formattedPhoneNumber));
                                                        },
                                                        icon: const Icon(
                                                            Icons.phone,
                                                            size: 16),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        ),
                                        googlePlace.formattedAddress != null
                                            ? Positioned(
                                                bottom: 0,
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 24.0,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  color: FlexColor
                                                      .bahamaBlueDarkPrimaryContainer,
                                                  child: Wrap(
                                                    spacing: 4.0,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.place_rounded,
                                                        size: 16,
                                                      ),
                                                      Text(state.googlePlace
                                                          .formattedAddress!),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        Positioned(
                                          width: 350,
                                          bottom: 20.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                googlePlace.rating != null
                                                    ? Opacity(
                                                        opacity: 0.85,
                                                        child: SizedBox(
                                                          height: 40,
                                                          child: FittedBox(
                                                            child: Chip(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16)),
                                                              label: Wrap(
                                                                spacing: 6.0,
                                                                crossAxisAlignment:
                                                                    WrapCrossAlignment
                                                                        .center,
                                                                children: [
                                                                  RatingBar
                                                                      .builder(
                                                                    onRatingUpdate:
                                                                        (value) =>
                                                                            null,
                                                                    ignoreGestures:
                                                                        true,
                                                                    itemSize:
                                                                        16.0,
                                                                    allowHalfRating:
                                                                        true,
                                                                    initialRating: state
                                                                        .googlePlace
                                                                        .rating!,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return const Icon(
                                                                        Icons
                                                                            .star,
                                                                        size:
                                                                            12.0,
                                                                        color: Colors
                                                                            .amber,
                                                                      );
                                                                    },
                                                                  ),
                                                                  Text(state
                                                                      .googlePlace
                                                                      .rating
                                                                      .toString()),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                                googlePlace.type != null &&
                                                        googlePlace.icon != null
                                                    ? Opacity(
                                                        opacity: 0.85,
                                                        child: SizedBox(
                                                          height: 40,
                                                          child: FittedBox(
                                                            child: Chip(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16)),
                                                              label: Text(
                                                                state
                                                                    .googlePlace
                                                                    .type!
                                                                    .capitalizeString(),
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleSmall,
                                                              ),
                                                              avatar:
                                                                  Image.network(
                                                                state
                                                                    .googlePlace
                                                                    .icon!,
                                                                height: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 24.0),
                                      child: FittedBox(
                                        child: Text(
                                          state.googlePlace.name!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                            horizontal: 8.0, vertical: 0.0),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 210,
                                          ),
                                          child: ListView.builder(
                                              clipBehavior: Clip.antiAlias,
                                              itemExtent: 250,
                                              physics:
                                                  const BouncingScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              //controller: scrollController,
                                              shrinkWrap: true,
                                              itemCount: state.googlePlace
                                                      .reviews?.length ??
                                                  0,
                                              itemBuilder: (context, index) {
                                                var thisReview = state
                                                    .googlePlace
                                                    .reviews![index];
                                                return Align(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 4.0),
                                                    child: Card(
                                                      elevation: 1.6,
                                                      child: Center(
                                                          child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 12.0,
                                                                horizontal:
                                                                    16.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              '"${state.googlePlace.reviews![index]['text']}"',
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(
                                                              height: 40,
                                                              width: 125,
                                                              child: FittedBox(
                                                                child: Wrap(
                                                                    crossAxisAlignment:
                                                                        WrapCrossAlignment
                                                                            .center,
                                                                    spacing:
                                                                        8.0,
                                                                    children: [
                                                                      RatingBar.builder(
                                                                          allowHalfRating: true,
                                                                          itemSize: 12,
                                                                          itemCount: 5,
                                                                          ignoreGestures: true,
                                                                          initialRating: thisReview['rating'].toDouble(),
                                                                          itemBuilder: (context, index) {
                                                                            return const Icon(
                                                                              Icons.star,
                                                                              color: Colors.amber,
                                                                            );
                                                                          },
                                                                          onRatingUpdate: (value) {}),
                                                                      Text(
                                                                        '${thisReview['rating'].toString()}.0',
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodySmall!
                                                                            .copyWith(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 10,
                                                                            ),
                                                                      )
                                                                    ]),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          8.0),
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CircleAvatar(
                                                                      radius:
                                                                          16,
                                                                      child: CachedNetworkImage(
                                                                          imageUrl:
                                                                              thisReview['profile_photo_url']),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 12.0,
                                                                  ),
                                                                  Flexible(
                                                                    flex: 4,
                                                                    child:
                                                                        FittedBox(
                                                                      child:
                                                                          Text(
                                                                        thisReview[
                                                                            'author_name'],
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 16.0),
                                      child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 4.0,
                                          ),
                                          onPressed: () {
                                            var placeCity = state
                                                    .googlePlace.addressComponents
                                                    ?.firstWhere((element) =>
                                                        element['types']?[0] ==
                                                            'locality' ||
                                                        element['types']?[0] ==
                                                            'administrative_area_level_3')[
                                                'short_name'];
                                            String? placeState = state
                                                    .googlePlace.addressComponents
                                                    ?.firstWhere((element) =>
                                                        element['types']?[0] ==
                                                        'administrative_area_level_1')[
                                                'short_name'];
                                            context
                                                .read<SavedListsBloc>()
                                                .add(UpdateSavedLists());
                                            context.read<SavedPlacesBloc>().add(
                                                  AddPlace(
                                                    placeList: context
                                                        .read<SavedPlacesBloc>()
                                                        .state
                                                        .placeList!,
                                                    place: Place(
                                                      placeId:
                                                          googlePlace.placeId,
                                                      name: googlePlace.name,
                                                      type: googlePlace.type,
                                                      website:
                                                          googlePlace.website,
                                                      city: placeCity,
                                                      state: placeState,
                                                      rating:
                                                          googlePlace.rating,
                                                      address: googlePlace
                                                          .formattedAddress,
                                                      phoneNumber: googlePlace
                                                          .formattedPhoneNumber,
                                                      icon: googlePlace.icon,
                                                      mapsUrl: googlePlace.url,
                                                      mainPhoto: googlePlace
                                                              .photos?[0]
                                                          ['photo_reference'],
                                                      hours: googlePlace
                                                          .weekDayText,
                                                      reviews:
                                                          googlePlace.reviews,
                                                    ),
                                                  ),
                                                );
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                              Icons.add_location_alt_outlined),
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ))),
                                    ),
                                  ],
                                ),
                              ))
                        ]));
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

class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({
    super.key,
  });

  @override
  State<PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends State<PlaceSearchBar> {
  bool searchbarFocused = false;
  final FloatingSearchBarController controller = FloatingSearchBarController();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutocompleteBloc, AutocompleteState>(
      builder: (context, state) {
        if (state is AutocompleteLoading) {
          return LoadingAnimationWidget.inkDrop(color: Colors.blue, size: 30.0);
        }
        if (state is AutocompleteLoaded) {
          return FloatingSearchBar(
            backdropColor: Colors.black54,
            automaticallyImplyDrawerHamburger: false,
            controller: controller,
            isScrollControlled: true,
            hint: 'Search Places..',
            openAxisAlignment: 0.0,
            width: 400,
            height: 48,
            scrollPadding: const EdgeInsets.only(top: 5, bottom: 5),
            elevation: 1.0,
            onFocusChanged: (focus) {
              if (focus == true) {
                setState(() {
                  searchbarFocused = true;
                });
              } else if (focus == false) {
                setState(() {
                  searchbarFocused = false;
                });
              }
            },
            onSubmitted: (query) {
              controller.close();
            },
            onQueryChanged: (query) {
              if (query != '') {
                context
                    .read<AutocompleteBloc>()
                    .add(LoadAutocomplete(searchInput: query));
              }

              if (query == '') {
                // widget.controller.close();
              }
            },
            transition: CircularFloatingSearchBarTransition(),
            transitionCurve: Curves.easeInOut,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (context, transition) {
              return BlocBuilder<AutocompleteBloc, AutocompleteState>(
                builder: (context, state) {
                  if (state is AutocompleteLoading) {
                    return LoadingAnimationWidget.inkDrop(
                        color: Colors.blue, size: 30.0);
                  }
                  if (state is AutocompleteLoaded) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: state.autocomplete!.isNotEmpty ? 1.0 : 0,
                      child: AnimatedContainer(
                        curve: Curves.easeOutQuart,
                        duration: const Duration(milliseconds: 300),
                        height: searchbarFocused ? 300 : 0,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.autocomplete?.length ?? 1,
                          itemBuilder: (context, index) {
                            if (state.autocomplete != null) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: ListTile(
                                      onTap: () => {
                                        context.read<PlaceBloc>().add(LoadPlace(
                                            placeId: state.autocomplete![index]
                                                .placeId!)),
                                        controller.close(),
                                      },
                                      title: Text(
                                        state.autocomplete![index].description!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 320, child: Divider()),
                                ],
                              );
                            } else {
                              return const Center(
                                child: Text('No Search Results...'),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                          child: Text(
                        'No results found..',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                    );
                  }
                },
              );
            },
          );
        } else {
          return const Center(
            child: Text('Something Went Wrong...'),
          );
        }
      },
    );
  }
}
