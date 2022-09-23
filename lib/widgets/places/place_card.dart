import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/slide_effect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_place/google_place.dart';

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
  final GooglePlace googlePlace =
      GooglePlace(dotenv.env['GOOGLE_PLACES_API_KEY']!);
  Future<Uint8List?> getPhotos(String photoReference) async {
    Uint8List? photo = await googlePlace.photos.get(photoReference, 1080, 1920);

    return photo;
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 170),
        child: Card(
          clipBehavior: Clip.antiAlias,
          //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Stack(
              children: [
                Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Expanded(
                          child: Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 170,
                                maxHeight: 180,
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
                                        openNow = true;

                                        return Animate(
                                          effects: const [
                                            SlideEffect(
                                                duration:
                                                    Duration(milliseconds: 500))
                                          ],
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                12.0)),
                                                child: Container(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  height: 24.0,
                                                  width: 70.0,
                                                  child: Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    spacing: 7.0,
                                                    children: [
                                                      const CircleAvatar(
                                                        radius: 3,
                                                        backgroundColor:
                                                            Colors.lightGreen,
                                                      ),
                                                      Text(
                                                        'Open',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black54),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                12.0)),
                                                child: Container(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerEnd,
                                                  color: openNow
                                                      ? Colors.black87
                                                      : Colors.white
                                                          .withOpacity(0.9),
                                                  height: 20.0,
                                                  width: 50.0,
                                                  child:
                                                      widget.ratingsTotal !=
                                                              null
                                                          ? SizedBox(
                                                              height: 20,
                                                              width: 40,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            2.0),
                                                                child: Wrap(
                                                                    crossAxisAlignment:
                                                                        WrapCrossAlignment
                                                                            .center,
                                                                    spacing:
                                                                        4.0,
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
                                                                      Text(
                                                                        widget
                                                                            .ratingsTotal
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: openNow
                                                                                ? Colors.white
                                                                                : Colors.black87),
                                                                      )
                                                                    ]),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        openNow = false;

                                        return Animate(
                                          effects: const [
                                            SlideEffect(
                                                duration:
                                                    Duration(milliseconds: 500))
                                          ],
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                12.0)),
                                                child: Container(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  color: Colors.black
                                                      .withOpacity(0.9),
                                                  height: 24.0,
                                                  width: 70.0,
                                                  child: Wrap(
                                                      alignment:
                                                          WrapAlignment.center,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      spacing: 6.0,
                                                      children: [
                                                        const CircleAvatar(
                                                          radius: 3,
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                        Text(
                                                          'Closed',
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      ]),
                                                ),
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(
                                                                12.0)),
                                                child: Container(
                                                  alignment:
                                                      AlignmentDirectional
                                                          .centerEnd,
                                                  color: openNow
                                                      ? Theme.of(context)
                                                          .cardColor
                                                      : Colors.white
                                                          .withOpacity(0.9),
                                                  height: 20.0,
                                                  width: 50.0,
                                                  child:
                                                      widget.ratingsTotal !=
                                                              null
                                                          ? SizedBox(
                                                              height: 20,
                                                              width: 40,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top:
                                                                            2.0),
                                                                child: Wrap(
                                                                    crossAxisAlignment:
                                                                        WrapCrossAlignment
                                                                            .center,
                                                                    spacing:
                                                                        6.0,
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
                                                                      Text(
                                                                        widget
                                                                            .ratingsTotal
                                                                            .toString(),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight: FontWeight
                                                                                .w900,
                                                                            color: openNow
                                                                                ? Colors.white
                                                                                : Colors.black87),
                                                                      )
                                                                    ]),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  }),
                            ],
                          )
                        ],
                      )),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                            ),
                            child: ListTile(
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
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: FutureBuilder(
                                  future: googlePlace.details
                                      .get(widget.place.googlePlaceId),
                                  builder: (context, snap) {
                                    var data = snap.data;
                                    if (data is DetailsResult) {}
                                    return Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
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
                                              widget.place.city,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(),
                                            ),
                                          ],
                                        ),
                                        FutureBuilder(
                                            future: googlePlace.details.get(
                                                widget.place.googlePlaceId),
                                            builder: (context, snap) {
                                              var data = snap.data;
                                              if (snap.data
                                                  is DetailsResponse) {
                                                return SizedBox(
                                                    height: 28,
                                                    child: FittedBox(
                                                        child: Chip(
                                                            avatar: CachedNetworkImage(
                                                                color: Theme.of(
                                                                        context)
                                                                    .iconTheme
                                                                    .color,
                                                                height: 16,
                                                                imageUrl: snap
                                                                    .data!
                                                                    .result!
                                                                    .icon!),
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            label: Text(
                                                              titleCase(widget
                                                                  .place.type
                                                                  .replaceAll(
                                                                      '_',
                                                                      ' ')),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900),
                                                            ))));
                                              } else {
                                                return const SizedBox();
                                              }
                                            }),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                          widget.placeDescription != null
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0,
                                      right: 12.0,
                                      bottom: 10.0,
                                      top: 2.0),
                                  child: Text(
                                    '"${widget.place.review}!"',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
