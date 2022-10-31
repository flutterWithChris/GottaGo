import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/model/place.dart';

class WheelResultSheet extends StatelessWidget {
  final ScrollController scrollController;
  const WheelResultSheet({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RandomWheelCubit, RandomWheelState>(
      builder: (context, state) {
        if (state is RandomWheelChosen) {
          final Place selectedPlace =
              context.watch<RandomWheelCubit>().state.selectedPlace!;

          return ListView(
              controller: scrollController,
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 250,
                  child: CachedNetworkImage(
                    imageUrl: 'nah',
                    placeholder: (context, url) {
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                          child: Animate(
                            onPlay: (controller) {
                              controller.repeat();
                            },
                            effects: const [
                              ShimmerEffect(duration: Duration(seconds: 2))
                            ],
                            child: Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      );
                    },
                    fit: BoxFit.cover,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListTile(
                          visualDensity: VisualDensity.compact,
                          // minVerticalPadding: 8,
                          title: Text(
                            selectedPlace.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          subtitle: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4.0,
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  size: 16,
                                ),
                                Text(selectedPlace.city)
                              ]),
                        ),
                      ),
                    ),
                    //     googlePlaceDetails.openingHours!.openNow!
                    //         ? Flexible(
                    //             flex: 1,
                    //             child: Wrap(
                    //               crossAxisAlignment: WrapCrossAlignment.center,
                    //               spacing: 8.0,
                    //               children: const [
                    //                 CircleAvatar(
                    //                   // minRadius: 1,
                    //                   radius: 3,
                    //                   backgroundColor: Colors.green,
                    //                 ),
                    //                 Text('Open'),
                    //               ],
                    //             ),
                    //           )
                    //         : Flexible(
                    //             flex: 1,
                    //             child: Wrap(
                    //               crossAxisAlignment: WrapCrossAlignment.center,
                    //               spacing: 8.0,
                    //               children: const [
                    //                 CircleAvatar(
                    //                   // minRadius: 1,
                    //                   radius: 3,
                    //                   backgroundColor: Colors.redAccent,
                    //                 ),
                    //                 Text('Closed'),
                    //               ],
                    //             ),
                    //           ),
                    //   ],
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Chip(
                              label: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8.0,
                                  children: [
                                RatingBar.builder(
                                    allowHalfRating: true,
                                    itemSize: 14,
                                    itemCount: 5,
                                    ignoreGestures: true,
                                    initialRating: 5,
                                    itemBuilder: (context, index) {
                                      return const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      );
                                    },
                                    onRatingUpdate: (value) {}),
                                const Text('Rating')
                              ])),
                          // Chip(
                          //     avatar: CachedNetworkImage(
                          //       imageUrl: googlePlaceDetails.icon!,
                          //       height: 16,
                          //     ),
                          //     label: Text(googlePlaceDetails.types![0]))
                        ],
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 225,
                          ),
                          child: ListView.builder(
                              itemExtent: 250,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              //controller: scrollController,
                              shrinkWrap: true,
                              itemCount: 0,
                              itemBuilder: (context, index) {
                                return Align(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: Card(
                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '"Reveiws"',
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(
                                              height: 40,
                                              width: 125,
                                              child: FittedBox(
                                                child: Wrap(
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    spacing: 8.0,
                                                    children: [
                                                      RatingBar.builder(
                                                          allowHalfRating: true,
                                                          itemSize: 12,
                                                          itemCount: 5,
                                                          ignoreGestures: true,
                                                          initialRating: 4,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return const Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.amber,
                                                            );
                                                          },
                                                          onRatingUpdate:
                                                              (value) {}),
                                                      Text(
                                                        4.0.toStringAsFixed(1),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      )
                                                    ]),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Wrap(
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                spacing: 12.0,
                                                children: [
                                                  CircleAvatar(
                                                    child: CachedNetworkImage(
                                                        imageUrl: 'url'),
                                                  ),
                                                  const Text(
                                                    'author',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign: TextAlign.left,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 8.0),
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 40),
                              minimumSize: const Size(100, 40)),
                          onPressed: () {},
                          icon: const Icon(Icons.directions),
                          label: const Text('Let\'s Go')),
                    )
                  ],
                )
              ]);
        } else {
          return const Center(
            child: Text('Something is Wrong!'),
          );
        }
      },
    );
  }
}
