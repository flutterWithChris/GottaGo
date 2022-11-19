import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:leggo/category_page.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/model/place.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewPlaceSheet extends StatelessWidget {
  final Place place;
  final ScrollController scrollController;
  const ViewPlaceSheet({
    Key? key,
    required this.place,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> _launchUrl(Uri url) async {
      if (!await launchUrl(url)) {
        throw 'Could not launch $url';
      }
    }

    String getTodaysDay() {
      DateTime date = DateTime.now();
      String dayOfTheWeek = DateFormat('EEEE').format(date);
      return dayOfTheWeek;
    }

    String? getTodaysHours(Place place) {
      if (place.hours == null) {
        return null;
      } else {
        String todaysDay = getTodaysDay();
        String todaysHours = place.hours!
            .firstWhere((element) => element.toString().contains(todaysDay));
        if (todaysHours.contains('Closed')) {
          return 'Closed';
        }
        String hoursIsolated =
            todaysHours.replaceFirst(RegExp('$todaysDay: '), '');
        return hoursIsolated;
        print(hoursIsolated);
      }
    }

    return BlocBuilder<ViewPlaceCubit, ViewPlaceState>(
      builder: (context, state) {
        if (state is ViewPlaceLoaded) {
          String? todaysHours = getTodaysHours(place);
          Place selectedPlace = state.place;
          final Uri placeWebsite = Uri.parse(selectedPlace.website!);
          final Uri placePhoneNumber =
              Uri(scheme: 'tel', path: selectedPlace.phoneNumber);
          return ListView(
            controller: scrollController,
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
                          'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${place.mainPhoto}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              label: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8.0,
                                  children: [
                                    RatingBar.builder(
                                        allowHalfRating: true,
                                        itemSize: 14,
                                        itemCount: 5,
                                        ignoreGestures: true,
                                        initialRating: place.rating!,
                                        itemBuilder: (context, index) {
                                          return const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          );
                                        },
                                        onRatingUpdate: (value) {}),
                                    Text(place.rating.toString())
                                  ])),
                          Chip(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              avatar: CachedNetworkImage(
                                imageUrl: place.icon!,
                                height: 16,
                              ),
                              label: Text(place.type!.capitalizeString()))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 8.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          selectedPlace.name!,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 2,
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 14.0,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            child: IconButton(
                              onPressed: () async {
                                await launchUrl(placeWebsite);
                              },
                              icon: const Icon(Icons.web_rounded, size: 16),
                            ),
                          ),
                          CircleAvatar(
                            radius: 18,
                            child: IconButton(
                              onPressed: () async {
                                await launchUrl(placePhoneNumber);
                              },
                              icon: const Icon(Icons.phone, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5.0,
                        children: [
                          const Icon(
                            Icons.location_pin,
                            size: 14,
                          ),
                          Text('${place.city!}, ${place.state!}')
                        ]),
                    todaysHours != null && todaysHours != 'Closed'
                        ? Flexible(
                            flex: 1,
                            child: SizedBox(
                              height: 40,
                              child: FittedBox(
                                child: Chip(
                                  label: Text.rich(TextSpan(children: [
                                    const TextSpan(
                                        text: 'Today: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(text: todaysHours),
                                  ])),
                                ),
                              ),
                            ),
                          )
                        : const Flexible(
                            flex: 1,
                            child: Text(
                              'Closed Today',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                          var thisReview = state.place.reviews![index];
                          return Align(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Card(
                                elevation: 1.6,
                                child: Center(
                                    child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '"${place.reviews![index]['text']}"',
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 40,
                                        width: 125,
                                        child: FittedBox(
                                          child: Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 8.0,
                                              children: [
                                                RatingBar.builder(
                                                    allowHalfRating: true,
                                                    itemSize: 12,
                                                    itemCount: 5,
                                                    ignoreGestures: true,
                                                    initialRating:
                                                        thisReview['rating']
                                                            .toDouble(),
                                                    itemBuilder:
                                                        (context, index) {
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
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                )
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: CircleAvatar(
                                                radius: 16,
                                                child: CachedNetworkImage(
                                                    imageUrl: thisReview[
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
                                                  thisReview['author_name'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.left,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 8.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 4.0,
                        fixedSize: const Size(100, 40),
                        minimumSize: const Size(100, 40)),
                    onPressed: () {
                      Uri googleMapsLink = Uri.parse(place.mapsUrl!);
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
  }
}
