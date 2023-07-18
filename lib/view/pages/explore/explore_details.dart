import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:leggo/cubit/explore_slideshow/explore_slideshow_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/gpt_place.dart';
import 'package:leggo/view/pages/explore.dart';
import 'package:leggo/view/widgets/dialogs/review_card_dialog.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:leggo/view/widgets/tweens/custom_rect_tween.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/explore/explore_bloc.dart';

class ExploreDetailsPage extends StatefulWidget {
  final double? photoIndex;
  const ExploreDetailsPage({this.photoIndex, super.key});

  @override
  State<ExploreDetailsPage> createState() => _ExploreDetailsPageState();
}

class _ExploreDetailsPageState extends State<ExploreDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final PageController detailsSlideshowController = PageController(
      initialPage: context.watch<ExploreSlideshowCubit>().state.photoIndex ?? 0,
    );
    final GooglePlace googlePlace =
        context.read<ExploreBloc>().state.googlePlace!;
    final GptPlace gptPlace = context.read<ExploreBloc>().state.gptPlace!;
    String? todaysHours = getTodaysHoursFromGooglePlace(googlePlace);
    Uri? placeWebsite;
    Uri? placePhoneNumber;

    return Scaffold(
      // bottomNavigationBar: MainBottomNavBar(),
      body: CustomScrollView(
        slivers: [
          const MainTopAppBarSmall(),
          SliverList(
              delegate: SliverChildListDelegate([
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                SizedBox(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  child: googlePlace.photos != null &&
                          googlePlace.photos!.isNotEmpty
                      ? Hero(
                          tag: '${googlePlace.placeId!}-gallery',
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: PageView(
                              onPageChanged: (value) {
                                context
                                    .read<ExploreSlideshowCubit>()
                                    .swipe(value);
                              },
                              //  shrinkWrap: true,
                              controller: detailsSlideshowController,
                              physics: const BouncingScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              // padding: EdgeInsets.zero,
                              children: [
                                for (dynamic image in googlePlace.photos!)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        8.0, 8.0, 8.0, 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
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
                                                          Duration(seconds: 2))
                                                ],
                                                child: Container(
                                                  height: 300,
                                                  width: MediaQuery.of(context)
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
                                            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${image['photo_reference']}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl:
                              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${googlePlace.photos![0]}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
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
                Positioned(
                  width: MediaQuery.of(context).size.width,
                  top: 8.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    child: Opacity(
                      opacity: 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: SizedBox(
                              width: 160,
                              child: FittedBox(
                                child: Chip(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
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
                                          initialRating: googlePlace.rating!,
                                          itemBuilder: (context, index) {
                                            return const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            );
                                          },
                                          onRatingUpdate: (value) {}),
                                      Text(googlePlace.rating.toString())
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          googlePlace.icon != null
                              ? Flexible(
                                  child: Chip(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      avatar: CachedNetworkImage(
                                        imageUrl: googlePlace.icon!,
                                        height: 16,
                                      ),
                                      label: Text(capitalizeAllWord(googlePlace
                                          .type!
                                          .replaceAll('_', ' ')))),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
                googlePlace.photos != null && googlePlace.photos!.isNotEmpty
                    ? Positioned(
                        bottom: 16.0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SmoothPageIndicator(
                            controller: detailsSlideshowController,
                            count: googlePlace.photos!.length,
                            effect: WormEffect(
                              dotHeight: 10.0,
                              dotWidth: 10.0,
                              dotColor: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              activeDotColor:
                                  Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ))
                    : const SizedBox(),
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
                      child: Hero(
                        tag: '${googlePlace.placeId!}-name',
                        child: Text(
                          googlePlace.name!,
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
                  ),
                  Flexible(
                    flex: 2,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 14.0,
                      children: [
                        googlePlace.website != null
                            ? CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: IconButton(
                                  onPressed: () async {
                                    await launchUrl(
                                        Uri.parse(googlePlace.website!));
                                  },
                                  icon: const Icon(
                                    Icons.web_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        googlePlace.formattedPhoneNumber != null
                            ? CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: IconButton(
                                  onPressed: () async {
                                    await launchUrl(Uri(
                                        scheme: 'tel',
                                        path:
                                            googlePlace.formattedPhoneNumber!));
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Hero(
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  return DefaultTextStyle(
                      style: DefaultTextStyle.of(toHeroContext).style,
                      child: toHeroContext.widget);
                },
                tag: '${googlePlace.placeId!}-location',
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5.0,
                  children: [
                    FittedBox(
                      child: Row(children: [
                        const Icon(
                          Icons.location_pin,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Text('${gptPlace.city}, ${gptPlace.state}')
                      ]),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    todaysHours != null && todaysHours != 'Closed'
                        ? SizedBox(
                            height: 38,
                            child: FittedBox(
                              child: Material(
                                color: Colors.transparent,
                                child: Chip(
                                  label: Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: 'Open: $todaysHours',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ])),
                                ),
                              ),
                            ),
                          )
                        : const Text(
                            'Closed Today',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Hero(
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  return DefaultTextStyle(
                      style: DefaultTextStyle.of(toHeroContext).style,
                      child: toHeroContext.widget);
                },
                tag: '${googlePlace.placeId!}-description',
                child: Text(
                  gptPlace.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                      itemCount: googlePlace.reviews?.length ?? 0,
                      itemBuilder: (context, index) {
                        var thisReview = googlePlace.reviews![index];
                        return Align(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
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
                                    builder: (context) => ReviewCardDialog(
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
                                tag: 'reviewHero-${thisReview['author_name']}',
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
                                          '"${googlePlace.reviews![index]['text']}"',
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
                                                      onRatingUpdate:
                                                          (value) {}),
                                                  Text(
                                                    '${thisReview['rating'].toString()}.0',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall!
                                                        .copyWith(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                  onPressed: () async {
                    await showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            insetAnimationDuration:
                                const Duration(milliseconds: 400),
                            child: AddToListDialog(place: googlePlace),
                          );
                        });
                  },
                  icon: const Icon(Icons.add_location_alt_outlined, size: 20.0),
                  label: const Text('Add to List')),
            )
          ]))
        ],
      ),
    );
  }
}
