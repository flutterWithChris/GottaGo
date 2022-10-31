import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';
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
  final FloatingSearchBarController controller = FloatingSearchBarController();

  @override
  void initState() {
    scrollableController = DraggableScrollableController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: scrollableController,
      initialChildSize: 0.7,
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 8.0),
                  child: BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
                    builder: (context, state) {
                      if (state.status == Status.loading) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          height: 400,
                          width: 400,
                          child: PlaceSearchBar(
                            controller: controller,
                          ),
                        );
                      }
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: 78,
                        width: 300,
                        child: PlaceSearchBar(controller: controller),
                      );
                    },
                  )),
              // BlocConsumer<PlaceSearchBloc, PlaceSearchState>(
              //   listener: (context, state) {
              //     if (state.status == Status.loaded) {
              //       scrollableController!.animateTo(0.72,
              //           duration: const Duration(milliseconds: 150),
              //           curve: Curves.easeOutBack);
              //     }
              //   },
              //   builder: (context, state) {
              //     if (state.status == Status.initial) {
              //       return const SizedBox();
              //     }
              //     if (state.status == Status.loaded) {
              //       return const SizedBox(
              //         child: Text('Loaded'),
              //       );
              //       return StreamBuilder<Object>(
              //           stream: context
              //               .read<PlaceSearchBloc>()
              //               .selectedLocation
              //               .stream,
              //           builder: (context, snapshot) {
              //             var data = snapshot.data;
              //             if (data == null) {
              //               return const SizedBox();
              //             } else {
              //               GooglePlace googlePlace = data as GooglePlace;

              //               return Padding(
              //                 padding: const EdgeInsets.all(2.0),
              //                 child: Column(
              //                   children: [
              //                     Padding(
              //                       padding: const EdgeInsets.all(4.0),
              //                       child: Card(
              //                         child: Column(
              //                           children: [
              //                             Padding(
              //                               padding: const EdgeInsets.symmetric(
              //                                   vertical: 16.0,
              //                                   horizontal: 24.0),
              //                               child: FittedBox(
              //                                 child: Text(
              //                                   'name',
              //                                   // placeDetails!.name!,
              //                                   textAlign: TextAlign.center,
              //                                   style: Theme.of(context)
              //                                       .textTheme
              //                                       .titleLarge!
              //                                       .copyWith(
              //                                           fontWeight:
              //                                               FontWeight.bold),
              //                                 ),
              //                               ),
              //                             ),
              //                             // Padding(
              //                             //   padding: const EdgeInsets.symmetric(
              //                             //       vertical: 8.0),
              //                             //   child: BlocBuilder<PlaceSearchBloc,
              //                             //       PlaceSearchState>(

              //                             //     builder: (context, state) {
              //                             //       return AspectRatio(
              //                             //         aspectRatio: 16 / 9,
              //                             //         child: CachedNetworkImage(
              //                             //           placeholder: (context, url) {
              //                             //             return AspectRatio(
              //                             //               aspectRatio: 16 / 9,
              //                             //               child: Center(
              //                             //                 child: Animate(
              //                             //                   onPlay: (controller) {
              //                             //                     controller.repeat();
              //                             //                   },
              //                             //                   effects: const [
              //                             //                     ShimmerEffect(
              //                             //                         duration: Duration(
              //                             //                             seconds: 2))
              //                             //                   ],
              //                             //                   child: Container(
              //                             //                     height: 300,
              //                             //                     width:
              //                             //                         MediaQuery.of(context)
              //                             //                             .size
              //                             //                             .width,
              //                             //                     color: Theme.of(context)
              //                             //                         .primaryColor,
              //                             //                   ),
              //                             //                 ),
              //                             //               ),
              //                             //             );
              //                             //           },
              //                             //           imageUrl:
              //                             //               'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${placeDetails.photos![0].photoReference}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
              //                             //           fit: BoxFit.cover,
              //                             //         ),
              //                             //       );
              //                             //     },
              //                             //   ),
              //                             // ),
              //                             OutlinedButton.icon(
              //                                 style: OutlinedButton.styleFrom(
              //                                     minimumSize:
              //                                         const Size(150, 30)),
              //                                 onPressed: () {},
              //                                 icon: const Icon(
              //                                     Icons.web_rounded,
              //                                     size: 18),
              //                                 label:
              //                                     const Text('Visit Website')),
              //                             Padding(
              //                               padding: const EdgeInsets.symmetric(
              //                                   horizontal: 4.0),
              //                               child: FittedBox(
              //                                 child: Wrap(
              //                                   spacing: 4.0,
              //                                   crossAxisAlignment:
              //                                       WrapCrossAlignment.center,
              //                                   children: const [
              //                                     Icon(
              //                                       Icons.place_rounded,
              //                                       size: 18,
              //                                     ),
              //                                     Text('address'),
              //                                   ],
              //                                 ),
              //                               ),
              //                             ),
              //                             Padding(
              //                               padding: const EdgeInsets.all(8.0),
              //                               child: Wrap(
              //                                 spacing: 6.0,
              //                                 crossAxisAlignment:
              //                                     WrapCrossAlignment.center,
              //                                 children: const [
              //                                   // placeDetails.rating != null
              //                                   //     ? RatingBar.builder(
              //                                   //         ignoreGestures: true,
              //                                   //         itemSize: 20.0,
              //                                   //         allowHalfRating: true,
              //                                   //         initialRating:
              //                                   //             placeDetails.rating!,
              //                                   //         itemBuilder: (context, index) {
              //                                   //           return const Icon(
              //                                   //             Icons.star,
              //                                   //             size: 12.0,
              //                                   //             color: Colors.amber,
              //                                   //           );
              //                                   //         },
              //                                   //         onRatingUpdate: (value) {},
              //                                   //       )
              //                                   //     : const SizedBox(),
              //                                   Text('rating'),
              //                                 ],
              //                               ),
              //                             ),
              //                             // Padding(
              //                             //   padding: const EdgeInsets.only(bottom: 6.0),
              //                             //   child: Chip(
              //                             //     label: Text('type'
              //                             //         .capitalizeString()),
              //                             //     avatar: Image.network(
              //                             //       placeDetails.icon!,
              //                             //       height: 18,
              //                             //     ),
              //                             //   ),
              //                             // ),
              //                           ],
              //                         ),
              //                       ),
              //                     ),
              //                     Padding(
              //                       padding: const EdgeInsets.all(8.0),
              //                       child: ElevatedButton.icon(
              //                           onPressed: () {
              //                             // print('Place Added: ${placeDetails.name}');
              //                             context
              //                                 .read<SavedListsBloc>()
              //                                 .add(UpdateSavedLists());
              //                             context.read<SavedPlacesBloc>().add(
              //                                 AddPlace(
              //                                     placeList: context
              //                                         .read<SavedPlacesBloc>()
              //                                         .state
              //                                         .placeList!,
              //                                     place:
              //                                         Place(
              //                                             website: googlePlace
              //                                                     .name ??
              //                                                 '',
              //                                             closingTime: '',
              //                                             review: '',
              //                                             rating: 0,
              //                                             name:
              //                                                 googlePlace.name,
              //                                             address: googlePlace
              //                                                     .name ??
              //                                                 '',
              //                                             description: '',
              //                                             city: 'city',
              //                                             type: googlePlace
              //                                                 .types[0],
              //                                             mainPhoto: 'nah')));
              //                             Navigator.pop(context);
              //                           },
              //                           icon: const Icon(
              //                               Icons.add_location_alt_outlined),
              //                           label: Text.rich(TextSpan(
              //                             children: [
              //                               const TextSpan(text: 'Add to '),
              //                               TextSpan(
              //                                   text: context
              //                                       .read<SavedPlacesBloc>()
              //                                       .state
              //                                       .placeList!
              //                                       .name,
              //                                   style: const TextStyle(
              //                                       fontWeight:
              //                                           FontWeight.bold)),
              //                             ],
              //                           ))),
              //                     ),
              //                   ],
              //                 ),
              //               );
              //             }
              //           });
              //     } else {
              //       return const Center(
              //         child: Text('Something Went Wrong..'),
              //       );
              //     }
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }
}

class PlaceSearchBar extends StatelessWidget {
  const PlaceSearchBar({
    super.key,
    required this.controller,
  });

  final FloatingSearchBarController controller;

  @override
  Widget build(BuildContext context) {
    return FloatingSearchBar(
      backdropColor: Colors.black54,
      automaticallyImplyDrawerHamburger: false,
      controller: controller,
      hint: 'Search Places..',
      openAxisAlignment: 0.0,
      width: 400,
      height: 48,
      scrollPadding: const EdgeInsets.only(top: 5, bottom: 5),
      elevation: 1.0,
      onFocusChanged: (focus) {
        if (focus == true) {
          //  context.read<PlaceSearchBloc>().add(PlaceSearchbarClicked());
          print("Searchbar Focused**");
        } else if (focus == false) {
          //   context.read<PlaceSearchBloc>().add(PlaceSearchbarClosed());
        }
      },
      onSubmitted: (query) {
        // context.read<PlaceSearchBloc>().setSelectedLocation(
        //     context.read<PlaceSearchBloc>().searchResults.first.placeId!);
        //context.read<PlaceSearchBloc>().add(LocationSearch());
        context.read<PlaceSearchBloc>().add(PlaceSearchSubmit());

        controller.close();
        //context.read<PlaceSearchBloc>().add(LocationSearchbarClosed());
      },
      onQueryChanged: (query) {
        if (query != '') {
          context.read<PlaceSearchBloc>().searchPlaces(query);
          context
              .read<PlaceSearchBloc>()
              .add(PlaceSearchStarted(searchTerm: query));
        }

        if (query == '') {
          controller.close();
        }
      },
      transition: CircularFloatingSearchBarTransition(),
      transitionCurve: Curves.easeInOut,
      transitionDuration: const Duration(milliseconds: 500),
      builder: (context, transition) {
        return Stack(
          children: [
            BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
              builder: (context, state) {
                if (state == PlaceSearchState.started()) {
                  return SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount:
                          context.read<PlaceSearchBloc>().searchResults.length,
                      itemBuilder: (context, index) {
                        if (state.searchResults!.isNotEmpty) {
                          print('SEARCH RESULTS NOT EMPTY');
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () => {
                                  context
                                      .read<PlaceSearchBloc>()
                                      .setSelectedLocation(context
                                          .read<PlaceSearchBloc>()
                                          .searchResults[index]
                                          .placeId!),
                                  context
                                      .read<PlaceSearchBloc>()
                                      .add(PlaceSearchSubmit()),
                                  controller.close(),
                                },
                                title: Text(
                                  context
                                      .read<PlaceSearchBloc>()
                                      .searchResults[index]
                                      .description!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                              ),
                            ],
                          );
                        }
                        return const SizedBox(
                          height: 300,
                          child: Center(
                              child: Text(
                            'No results found..',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                        );
                      },
                    ),
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        onTap: () => {
                          context.read<PlaceSearchBloc>().setSelectedLocation(
                              context
                                  .read<PlaceSearchBloc>()
                                  .searchResults[0]
                                  .placeId!),
                          context
                              .read<PlaceSearchBloc>()
                              .add(PlaceSearchSubmit()),
                          controller.close(),
                        },
                        title: Text(
                          context
                              .read<PlaceSearchBloc>()
                              .searchResults[0]
                              .description!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const Divider(
                        color: Colors.white,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
