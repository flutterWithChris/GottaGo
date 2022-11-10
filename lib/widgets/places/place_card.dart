import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/widgets/places/view_place_sheet.dart';

import '../../model/place.dart';

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
  titleCase(String string) {
    var splitStr = string.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
      // You do not need to check if i is larger than splitStr length, as your for does that for you
      // Assign it back to the array
      splitStr[i] =
          splitStr[i].characters.characterAt(0).toString().toUpperCase() +
              splitStr[i].substring(1);
    }
    // Directly return the joined string
    return splitStr.join(' ');
  }

  bool openNow = false;
  Color openNowContainerColor = Colors.white;
  Color ratingContainerColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    // var placeCity = data.result?.addressComponents
    //     ?.firstWhere((element) =>
    //         element.types?[0] == 'locality' ||
    //         element.types?[0] == 'administrative_area_level_3')
    //     .shortName!;
    // String? placeState = data.result?.addressComponents
    //     ?.singleWhere((element) =>
    //         element.types?[0] == 'administrative_area_level_1')
    //     .shortName;
    return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 170, maxHeight: 205),
        child: InkWell(
          onTap: () {
            context.read<ViewPlaceCubit>().viewPlace(widget.place);
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.85,
                    maxChildSize: 0.85,
                    builder: (context, scrollController) {
                      return ViewPlaceSheet(
                          place: widget.place,
                          scrollController: scrollController);
                    }));
          },
          child: Card(
              clipBehavior: Clip.antiAlias,
              //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
              child: Flex(direction: Axis.horizontal, children: [
                Flexible(
                    child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          minHeight: 202,
                          maxHeight: 205,
                          minWidth: 120,
                          maxWidth: 120),
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
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // data.result!.openingHours!.openNow == true
                        //     ? Animate(
                        //         effects: const [
                        //           SlideEffect(
                        //               duration: Duration(
                        //                 milliseconds: 400,
                        //               ),
                        //               curve: Curves.easeOutBack)
                        //         ],
                        //         child: Column(
                        //           crossAxisAlignment:
                        //               CrossAxisAlignment.end,
                        //           children: [
                        //             ClipRRect(
                        //               borderRadius:
                        //                   const BorderRadius.only(
                        //                       bottomLeft:
                        //                           Radius.circular(
                        //                               12.0)),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12.0))),
                          alignment: AlignmentDirectional.center,
                          height: 24.0,
                          width: 70.0,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 7.0,
                            children: [
                              const CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.lightGreen,
                              ),
                              Text(
                                'Open',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54),
                              ),
                            ],
                          ),
                        ),

                        //             ClipRRect(
                        //               borderRadius:
                        //                   const BorderRadius.only(
                        //                       bottomLeft:
                        //                           Radius.circular(
                        //                               12.0)),
                        //               child: Container(
                        //                 alignment: AlignmentDirectional
                        //                     .centerEnd,
                        //                 color: data.result?.openingHours
                        //                             ?.openNow ==
                        //                         true
                        //                     ? Colors.black87
                        //                     : Colors.white
                        //                         .withOpacity(0.9),
                        //                 height: 20.0,
                        //                 width: 50.0,
                        //                 child:
                        //                     widget.ratingsTotal != null
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.0))),
                          //color: Colors.black,
                          height: 20,
                          width: 45,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4.0,
                                children: [
                                  RatingBar.builder(
                                      itemCount: 1,
                                      itemSize: 12.0,
                                      initialRating: 1,
                                      // initialRating:
                                      //     widget.place.rating!,
                                      // allowHalfRating: true,
                                      ignoreGestures: true,
                                      itemBuilder: (context, index) {
                                        return const Icon(
                                          Icons.star,
                                          size: 12.0,
                                          color: Colors.amber,
                                        );
                                      },
                                      onRatingUpdate: (rating) {}),
                                  Text(widget.ratingsTotal.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .white, //data.result?.openingHours?.openNow == true

                                        // : Colors.black87),
                                      ))
                                ]),
                          ),
                        ),
                        //                         : const SizedBox(),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     : Animate(
                        //         effects: const [
                        //           SlideEffect(
                        //               duration: Duration(
                        //                 milliseconds: 400,
                        //               ),
                        //               curve: Curves.easeOutBack)
                        //         ],
                        //         child: Column(
                        //           crossAxisAlignment:
                        //               CrossAxisAlignment.end,
                        //           children: [
                        //             ClipRRect(
                        //               borderRadius:
                        //                   const BorderRadius.only(
                        //                       bottomLeft:
                        //                           Radius.circular(
                        //                               12.0)),
                        //               child: Container(
                        //                 alignment:
                        //                     AlignmentDirectional.center,
                        //                 color: Colors.black
                        //                     .withOpacity(0.9),
                        //                 height: 24.0,
                        //                 width: 70.0,
                        //                 child: Wrap(
                        //                     alignment:
                        //                         WrapAlignment.center,
                        //                     crossAxisAlignment:
                        //                         WrapCrossAlignment
                        //                             .center,
                        //                     spacing: 6.0,
                        //                     children: [
                        //                       const CircleAvatar(
                        //                         radius: 3,
                        //                         backgroundColor:
                        //                             Colors.red,
                        //                       ),
                        //                       Text(
                        //                         'Closed',
                        //                         style: Theme.of(context)
                        //                             .textTheme
                        //                             .bodySmall!
                        //                             .copyWith(
                        //                                 fontWeight:
                        //                                     FontWeight
                        //                                         .bold,
                        //                                 color: Colors
                        //                                     .white),
                        //                       ),
                        //                     ]),
                        //               ),
                        //             ),
                        //             ClipRRect(
                        //               borderRadius:
                        //                   const BorderRadius.only(
                        //                       bottomLeft:
                        //                           Radius.circular(
                        //                               12.0)),
                        //               child: Container(
                        //                 alignment: AlignmentDirectional
                        //                     .centerEnd,
                        //                 color: openNow
                        //                     ? Theme.of(context)
                        //                         .cardColor
                        //                     : Colors.white
                        //                         .withOpacity(0.9),
                        //                 height: 20.0,
                        //                 width: 50.0,
                        //                 child:
                        //                     widget.ratingsTotal != null
                        //                         ? SizedBox(
                        //                             height: 20,
                        //                             width: 40,
                        //                             child: Padding(
                        //                               padding:
                        //                                   const EdgeInsets
                        //                                           .only(
                        //                                       top: 2.0),
                        //                               child: Wrap(
                        //                                   crossAxisAlignment:
                        //                                       WrapCrossAlignment
                        //                                           .center,
                        //                                   spacing: 6.0,
                        //                                   children: [
                        //                                     RatingBar.builder(
                        //                                         itemCount: 1,
                        //                                         itemSize: 12.0,
                        //                                         initialRating: 1,
                        //                                         // initialRating:
                        //                                         //     widget.place.rating!,
                        //                                         // allowHalfRating: true,
                        //                                         ignoreGestures: true,
                        //                                         itemBuilder: (context, index) {
                        //                                           return const Icon(
                        //                                             Icons.star,
                        //                                             size:
                        //                                                 12.0,
                        //                                             color:
                        //                                                 Colors.amber,
                        //                                           );
                        //                                         },
                        //                                         onRatingUpdate: (rating) {}),
                        //                                     Text(
                        //                                       widget
                        //                                           .ratingsTotal
                        //                                           .toString(),
                        //                                       textAlign:
                        //                                           TextAlign
                        //                                               .center,
                        //                                       style: TextStyle(
                        //                                           fontSize:
                        //                                               10,
                        //                                           fontWeight: FontWeight
                        //                                               .w900,
                        //                                           color: openNow
                        //                                               ? Colors.white
                        //                                               : Colors.black87),
                        //                                     )
                        //                                   ]),
                        //                             ),
                        //                           )
                        //                         : const SizedBox(),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       )
                      ],
                    )
                  ],
                )),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: AlignmentDirectional.topEnd,
                          children: [
                            ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              //visualDensity: const VisualDensity(vertical: 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              // contentPadding: const EdgeInsets.symmetric(
                              //     horizontal: 12.0, vertical: 4.0),
                              //tileColor: Colors.white,

                              title: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Wrap(
                                  alignment: WrapAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      titleCase(widget.placeName),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Wrap(
                                    spacing: 5.0,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.location_pin,
                                        size: 13,
                                      ),
                                      Text(
                                        '${widget.place.city!}, ${widget.place.state}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(),
                                      ),
                                    ],
                                  ),
                                  // data.result!.icon != null
                                  //     ? SizedBox(
                                  //         height: 28,
                                  //         child: FittedBox(
                                  //             child: Chip(
                                  //                 padding: const EdgeInsets
                                  //                         .symmetric(
                                  //                     vertical: 4.0,
                                  //                     horizontal: 8.0),
                                  //                 avatar:
                                  //                     CachedNetworkImage(
                                  //                         color: Theme.of(
                                  //                                 context)
                                  //                             .iconTheme
                                  //                             .color,
                                  //                         height: 16,
                                  //                         imageUrl: data
                                  //                             .result!
                                  //                             .icon!),
                                  //                 visualDensity:
                                  //                     VisualDensity.compact,
                                  //                 label: Text(
                                  //                   titleCase(widget
                                  //                       .place.type
                                  //                       .replaceAll(
                                  //                           '_', ' ')),
                                  //                   style: const TextStyle(
                                  //                       color: Colors.white,
                                  //                       fontWeight:
                                  //                           FontWeight
                                  //                               .w900),
                                  //                 ))))
                                  //     : const SizedBox(),
                                  // data.result!.reviews!.isNotEmpty
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      '"${widget.place.reviews?[0]['text']}!"',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  )
                                  //     : Container()
                                ],
                              ),
                            ),
                            // Positioned(
                            //   top: -30,
                            //   child: Wrap(
                            //     crossAxisAlignment: WrapCrossAlignment.center,
                            //     spacing: 8.0,
                            //     children: [
                            //       IconButton(
                            //           onPressed: () {},
                            //           icon: const Icon(
                            //             Icons.directions,
                            //             size: 20,
                            //           )),
                            //       IconButton(
                            //           onPressed: () {},
                            //           icon: const Icon(
                            //             Icons.close,
                            //             size: 20,
                            //           )),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ])),
        ));
  }
}
