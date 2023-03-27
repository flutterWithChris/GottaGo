import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../dialogs/review_card_dialog.dart';
import '../tweens/custom_rect_tween.dart';

class ViewPlaceSheet extends StatefulWidget {
  final Place place;
  final ScrollController scrollController;
  const ViewPlaceSheet({
    Key? key,
    required this.place,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<ViewPlaceSheet> createState() => _ViewPlaceSheetState();
}

class _ViewPlaceSheetState extends State<ViewPlaceSheet> {
  final GlobalKey _quickButtonsShowcase = GlobalKey();

  @override
  Widget build(BuildContext context) {
    BuildContext? buildContext;
    Future<void> _launchUrl(Uri url) async {
      if (!await launchUrl(url)) {
        throw 'Could not launch $url';
      }
    }

    return FutureBuilder<bool?>(
        future: getShowcaseStatus('viewPlacesShowcaseComplete'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data == null || snapshot.data == false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              await Future.delayed(const Duration(milliseconds: 400));
              ShowCaseWidget.of(buildContext!)
                  .startShowCase([_quickButtonsShowcase]);
            });
          }
          return ShowCaseWidget(onFinish: () async {
            var prefs = await SharedPreferences.getInstance();
            prefs.setBool('viewPlacesShowcaseComplete', true);
          }, builder: Builder(
            builder: (context) {
              buildContext = context;
              return BlocBuilder<ViewPlaceCubit, ViewPlaceState>(
                builder: (context, state) {
                  if (state is ViewPlaceLoaded) {
                    String? todaysHours = getTodaysHours(widget.place);
                    Place selectedPlace = state.place;
                    Uri? placeWebsite;
                    Uri? placePhoneNumber;
                    if (selectedPlace.website != null) {
                      placeWebsite = Uri.parse(selectedPlace.website!);
                    }

                    if (selectedPlace.phoneNumber != null) {
                      placePhoneNumber =
                          Uri(scheme: 'tel', path: selectedPlace.phoneNumber);
                    }

                    return ListView(
                      controller: widget.scrollController,
                      shrinkWrap: true,
                      children: [
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            SizedBox(
                              height: 250,
                              width: MediaQuery.of(context).size.width,
                              child: CachedNetworkImage(
                                imageUrl:
                                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${widget.place.mainPhoto}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
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
                                              duration: Duration(seconds: 2))
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 6.0),
                              child: Opacity(
                                opacity: 0.9,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        label: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8.0,
                                            children: [
                                              RatingBar.builder(
                                                  allowHalfRating: true,
                                                  itemSize: 14,
                                                  itemCount: 5,
                                                  ignoreGestures: true,
                                                  initialRating:
                                                      widget.place.rating!,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return const Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    );
                                                  },
                                                  onRatingUpdate: (value) {}),
                                              Text(widget.place.rating
                                                  .toString())
                                            ])),
                                    widget.place.icon != null
                                        ? Chip(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14)),
                                            avatar: CachedNetworkImage(
                                              imageUrl: widget.place.icon!,
                                              height: 16,
                                            ),
                                            label: Text(capitalizeAllWord(widget
                                                .place.type!
                                                .replaceAll('_', ' '))))
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 12.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                  ),
                                  child: Text(
                                    selectedPlace.name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: Showcase(
                                  key: _quickButtonsShowcase,
                                  description:
                                      'Visit their website or call with one click!',
                                  targetBorderRadius: BorderRadius.circular(24),
                                  targetPadding: const EdgeInsets.all(8.0),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 14.0,
                                    children: [
                                      placeWebsite != null
                                          ? CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              child: IconButton(
                                                onPressed: () async {
                                                  await launchUrl(
                                                      placeWebsite!);
                                                },
                                                icon: const Icon(
                                                  Icons.web_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      placePhoneNumber != null
                                          ? CircleAvatar(
                                              radius: 18,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              child: IconButton(
                                                onPressed: () async {
                                                  await launchUrl(
                                                      placePhoneNumber!);
                                                },
                                                icon: const Icon(
                                                  Icons.phone,
                                                  size: 16,
                                                  color: Colors.white,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  child: Row(children: [
                                    const Icon(
                                      Icons.location_pin,
                                      size: 14,
                                    ),
                                    const SizedBox(
                                      width: 4.0,
                                    ),
                                    Text(
                                        '${widget.place.city!}, ${widget.place.state!}')
                                  ]),
                                ),
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              todaysHours != null && todaysHours != 'Closed'
                                  ? Flexible(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 38,
                                        child: FittedBox(
                                          child: Chip(
                                            label:
                                                Text.rich(TextSpan(children: [
                                              TextSpan(
                                                  text: 'Open: $todaysHours',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ])),
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Flexible(
                                      flex: 1,
                                      child: Text(
                                        'Closed Today',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 220,
                              ),
                              child: ListView.builder(
                                  clipBehavior: Clip.antiAlias,
                                  itemExtent: 250,
                                  physics: const BouncingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  //controller: scrollController,
                                  shrinkWrap: true,
                                  itemCount: state.place.reviews?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    var thisReview =
                                        state.place.reviews![index];
                                    return Align(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navigator.of(context).push(
                                            //     HeroDialogRoute(
                                            //         builder: (context) {
                                            //   return ReviewCardDialog(
                                            //       review: thisReview);
                                            // }));
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    ReviewCardDialog(
                                                      review: thisReview,
                                                    ));
                                            // context.push('/review-card-dialog',
                                            //     extra: thisReview);
                                          },
                                          child: Hero(
                                            //transitionOnUserGestures: true,
                                            createRectTween: (begin, end) {
                                              return CustomRectTween(
                                                  begin: begin!, end: end!);
                                            },
                                            tag: 'reviewHero',
                                            child: Card(
                                              elevation: 1.6,
                                              child: Center(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 16.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '"${widget.place.reviews![index]['text']}"',
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                                                  allowHalfRating:
                                                                      true,
                                                                  itemSize: 12,
                                                                  itemCount: 5,
                                                                  ignoreGestures:
                                                                      true,
                                                                  initialRating:
                                                                      thisReview[
                                                                              'rating']
                                                                          .toDouble(),
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return const Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .amber,
                                                                    );
                                                                  },
                                                                  onRatingUpdate:
                                                                      (value) {}),
                                                              Text(
                                                                '${thisReview['rating'].toString()}.0',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                              )
                                                            ]),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 8.0),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child: CircleAvatar(
                                                              radius: 16,
                                                              child: CachedNetworkImage(
                                                                  imageUrl:
                                                                      thisReview[
                                                                          'profile_photo_url']),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 12.0,
                                                          ),
                                                          Flexible(
                                                            flex: 4,
                                                            child: FittedBox(
                                                              child: Text(
                                                                thisReview[
                                                                    'author_name'],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
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
                                  elevation: 4.0,
                                  fixedSize: const Size(100, 40),
                                  minimumSize: const Size(100, 40)),
                              onPressed: () {
                                Uri googleMapsLink =
                                    Uri.parse(widget.place.mapsUrl!);
                                launchUrl(googleMapsLink);
                              },
                              icon: const Icon(Icons.directions),
                              label: const Text('Let\'s Go')),
                        )
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('Something is Wrong!'),
                    );
                  }
                },
              );
            },
          ));
        });
  }
}
