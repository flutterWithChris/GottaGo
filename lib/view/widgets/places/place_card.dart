import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/place/edit_places_bloc.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place_list.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    hide SlideEffect;
import 'package:url_launcher/url_launcher.dart';

import '../../../cubit/lists/list_sort_cubit.dart';
import '../../../model/place.dart';

class PlaceCard extends StatefulWidget {
  final PlaceList placeList;
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
    required this.placeList,
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

class _PlaceCardState extends State<PlaceCard>
    with AutomaticKeepAliveClientMixin {
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
  bool isSelected = false;
  Color openNowContainerColor = Colors.white;
  Color ratingContainerColor = Colors.black87;
  final GlobalKey _placeCardShowcase = GlobalKey();
  final GlobalKey _goButtonShowcase = GlobalKey();
  final GlobalKey _editButtonsShowcase = GlobalKey();
  PageController pageController = PageController();
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    BuildContext? buildContext;
    super.build(context);
    String? todaysHours = getTodaysHours(widget.place);
    return FutureBuilder<bool?>(
        future: getShowcaseStatus('placeCardShowcaseComplete'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data == null || snapshot.data == false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              await Future.delayed(const Duration(milliseconds: 400));
              if (ShowCaseWidget.of(context).mounted == false) {
                ShowCaseWidget.of(buildContext!).startShowCase([
                  _placeCardShowcase,
                  _goButtonShowcase,
                  _editButtonsShowcase
                ]);
              }
            });
          }
          return ShowCaseWidget(onFinish: () async {
            var prefs = await SharedPreferences.getInstance();
            prefs.setBool('placeCardShowcaseComplete', true);
          }, builder: Builder(
            builder: (context) {
              buildContext = context;
              return BlocBuilder<EditPlacesBloc, EditPlacesState>(
                builder: (context, state) {
                  return InkWell(
                    splashColor: FlexColor.bahamaBlueDarkSecondary,
                    borderRadius: BorderRadius.circular(24),
                    onTap: () async {
                      if (state is EditPlacesStarted) {
                        setState(() {
                          isSelected = !isSelected;
                        });
                        if (isSelected == true) {
                          context
                              .read<EditPlacesBloc>()
                              .add(SelectPlace(place: widget.place));
                        }
                        if (isSelected == false) {
                          context
                              .read<EditPlacesBloc>()
                              .add(UnselectPlace(place: widget.place));
                        }
                      } else {
                        context.read<ViewPlaceCubit>().viewPlace(widget.place);
                        context.pushNamed('view-place', extra: widget.place);
                        // await showModalBottomSheet(
                        //     isScrollControlled: true,
                        //     context: context,
                        //     builder: (context) => DraggableScrollableSheet(
                        //         expand: false,
                        //         initialChildSize: 0.85,
                        //         maxChildSize: 0.9,
                        //         builder: (context, scrollController) {
                        //           return ViewPlaceSheet(
                        //               place: widget.place,
                        //               scrollController: scrollController);
                        //         }));
                      }
                    },
                    child: Showcase(
                      key: _placeCardShowcase,
                      descriptionAlignment: TextAlign.center,
                      targetBorderRadius: BorderRadius.circular(24.0),
                      targetPadding: const EdgeInsets.all(8.0),
                      description:
                          'Nice! Now you can click on this spot to view info.',
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            // direction: Axis.vertical,
                            children: [
                              Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  widget.place.photos != null &&
                                          widget.place.photos!.isNotEmpty
                                      ? AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: PageView(
                                            //  shrinkWrap: true,
                                            controller: pageController,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            // padding: EdgeInsets.zero,
                                            children: [
                                              for (dynamic image
                                                  in widget.place.photos!)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  child: CachedNetworkImage(
                                                    placeholder:
                                                        (context, url) {
                                                      return Hero(
                                                        tag:
                                                            'gallery-${widget.place.placeId}',
                                                        child: AspectRatio(
                                                          aspectRatio: 4 / 3,
                                                          child: Center(
                                                            child: Animate(
                                                              onPlay:
                                                                  (controller) {
                                                                controller
                                                                    .repeat();
                                                              },
                                                              effects: const [
                                                                ShimmerEffect(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            2))
                                                              ],
                                                              child: Container(
                                                                height: 300,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                              ),
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
                                            ],
                                          ),
                                        )
                                      : Hero(
                                          tag:
                                              'gallery-${widget.place.placeId}',
                                          child: AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                      'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${widget.place.mainPhoto}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )),
                                        ),
                                  widget.place.photos != null &&
                                          widget.place.photos!.isNotEmpty
                                      ? Positioned(
                                          bottom: 16.0,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: SmoothPageIndicator(
                                              controller: pageController,
                                              count:
                                                  widget.place.photos!.length,
                                              effect: WormEffect(
                                                dotHeight: 10.0,
                                                dotWidth: 10.0,
                                                dotColor: Theme.of(context)
                                                    .colorScheme
                                                    .tertiaryContainer,
                                                activeDotColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                              ),
                                            ),
                                          ))
                                      : const SizedBox(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft:
                                                  Radius.circular(12.0)),
                                          color: Theme.of(context).cardColor,
                                        ),
                                        alignment: AlignmentDirectional.center,
                                        height: 24.0,
                                        width: 120.0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                          ),
                                          child: FittedBox(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                todaysHours != null
                                                    ? todaysHours != 'Closed'
                                                        ? todaysHours.contains(
                                                                '24 hours')
                                                            ? Text(
                                                                'Open 24 Hours',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              )
                                                            : Text(
                                                                'Open \'til: ${todaysHours.split('–')[1].trim()}',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                              )
                                                        : const Text(
                                                            'Closed Today!')
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(12.0))),
                                        height: 24,
                                        width: 48,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Wrap(
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              spacing: 4.0,
                                              children: [
                                                RatingBar.builder(
                                                    itemCount: 1,
                                                    itemSize: 12.0,
                                                    initialRating: 1,
                                                    ignoreGestures: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return const Icon(
                                                        Icons.star,
                                                        size: 12.0,
                                                        color: Colors.amber,
                                                      );
                                                    },
                                                    onRatingUpdate:
                                                        (rating) {}),
                                                Text(
                                                    widget.ratingsTotal
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ))
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  BlocBuilder<EditPlacesBloc, EditPlacesState>(
                                    builder: (context, state) {
                                      if (state is EditPlacesStarted) {
                                        return Positioned(
                                          left: 8.0,
                                          top: 8.0,
                                          child: Animate(
                                            effects: const [
                                              SlideEffect(
                                                  curve: Curves.easeOutSine,
                                                  begin: Offset(0.0, -1.0),
                                                  duration: Duration(
                                                      milliseconds: 50))
                                            ],
                                            child: RoundCheckBox(
                                              checkedColor: FlexColor
                                                  .bahamaBlueDarkPrimaryContainer,
                                              uncheckedColor: Colors.white54,
                                              size: 30,
                                              isChecked: isSelected,
                                              onTap: (p0) {
                                                setState(() {
                                                  isSelected = p0!;
                                                });
                                                if (p0 == true) {
                                                  context
                                                      .read<EditPlacesBloc>()
                                                      .add(SelectPlace(
                                                          place: widget.place));
                                                }
                                                if (p0 == false) {
                                                  context
                                                      .read<EditPlacesBloc>()
                                                      .add(UnselectPlace(
                                                          place: widget.place));
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  )
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Wrap(
                                        spacing: 12.0,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Hero(
                                            flightShuttleBuilder:
                                                (flightContext,
                                                    animation,
                                                    flightDirection,
                                                    fromHeroContext,
                                                    toHeroContext) {
                                              return DefaultTextStyle(
                                                style: DefaultTextStyle.of(
                                                        fromHeroContext)
                                                    .style,
                                                child: toHeroContext.widget,
                                              );
                                            },
                                            tag:
                                                'placeName-${widget.place.placeId}',
                                            child: Text(
                                              titleCase(widget.placeName),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          // Middle Dot
                                          // const Flexible(
                                          //   child: Text(
                                          //     '·',
                                          //     style: TextStyle(
                                          //       fontSize: 22,
                                          //       fontWeight: FontWeight.bold,
                                          //     ),
                                          //   ),
                                          // ),

                                          // Place Type
                                          if (widget.place.type != null)
                                            Hero(
                                              flightShuttleBuilder:
                                                  (flightContext,
                                                      animation,
                                                      flightDirection,
                                                      fromHeroContext,
                                                      toHeroContext) {
                                                return DefaultTextStyle(
                                                  style: DefaultTextStyle.of(
                                                          fromHeroContext)
                                                      .style,
                                                  child: toHeroContext.widget,
                                                );
                                              },
                                              tag:
                                                  'placeType-${widget.place.placeId}',
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Chip(
                                                    side: BorderSide.none,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    label: Text(titleCase(widget
                                                        .place.type!
                                                        .replaceAll('_', ' '))),
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    labelPadding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 4.0),
                                                    avatar: widget.place.icon != null
                                                        ? CachedNetworkImage(
                                                            height: 12,
                                                            imageUrl: widget
                                                                .place.icon!)
                                                        : null,
                                                    labelStyle: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(color: Colors.black)),
                                              ),
                                            ),
                                          Wrap(
                                            spacing: 5.0,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.location_pin,
                                                size: 13,
                                              ),
                                              Hero(
                                                flightShuttleBuilder:
                                                    (flightContext,
                                                        animation,
                                                        flightDirection,
                                                        fromHeroContext,
                                                        toHeroContext) {
                                                  return DefaultTextStyle(
                                                    style: DefaultTextStyle.of(
                                                            fromHeroContext)
                                                        .style,
                                                    child: toHeroContext.widget,
                                                  );
                                                },
                                                tag:
                                                    'placeLocation-${widget.place.placeId}',
                                                child: Text(
                                                  '${widget.place.city!}, ${widget.place.state}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, bottom: 0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Showcase(
                                            key: _goButtonShowcase,
                                            descriptionAlignment:
                                                TextAlign.center,
                                            targetBorderRadius:
                                                BorderRadius.circular(50),
                                            targetPadding:
                                                const EdgeInsets.all(10.0),
                                            description: 'Get directions here.',
                                            child: Hero(
                                              tag:
                                                  'goButton-${widget.place.placeId}',
                                              child: ElevatedButton.icon(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          //    foregroundColor: Colors.white,
                                                          fixedSize: const Size(
                                                              110, 36),
                                                          elevation: 1.3),
                                                  onPressed: () {
                                                    Uri googleMapsLink =
                                                        Uri.parse(widget
                                                            .place.mapsUrl!);
                                                    launchUrl(googleMapsLink);
                                                  },
                                                  icon: const Icon(
                                                    FontAwesomeIcons
                                                        .locationArrow,
                                                    size: 18,
                                                  ),
                                                  label: const FittedBox(
                                                      child:
                                                          Text('Let\'s Go'))),
                                            ),
                                          ),
                                          Showcase(
                                            key: _editButtonsShowcase,
                                            description:
                                                'Use these buttons to mark visited or delete a place!',
                                            targetBorderRadius:
                                                BorderRadius.circular(50),
                                            targetPadding:
                                                const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                context.watch<ListSortCubit>().state.status ==
                                                        'Visited'
                                                    ? IconButton(
                                                        style: IconButton.styleFrom(
                                                            backgroundColor: FlexColor
                                                                .bahamaBlueDarkSecondaryVariant
                                                                .withOpacity(
                                                                    0.06)),
                                                        splashRadius: 60,
                                                        splashColor: FlexColor
                                                            .bahamaBlueDarkPrimaryContainer,
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  EditPlacesBloc>()
                                                              .add(UnVisitPlace(
                                                                  place: widget
                                                                      .place,
                                                                  placeList: widget
                                                                      .placeList));
                                                        },
                                                        icon: const Icon(
                                                            Icons.undo_rounded))
                                                    : IconButton(
                                                        style: IconButton.styleFrom(
                                                            backgroundColor: Theme.of(context).brightness ==
                                                                    Brightness
                                                                        .light
                                                                ? FlexColor
                                                                    .bahamaBlueLightSecondaryVariant
                                                                    .withOpacity(
                                                                        0.6)
                                                                : FlexColor
                                                                    .bahamaBlueDarkSecondaryVariant
                                                                    .withOpacity(0.06)),
                                                        splashRadius: 60,
                                                        splashColor: FlexColor.bahamaBlueDarkPrimaryContainer,
                                                        onPressed: () {
                                                          context
                                                              .read<
                                                                  EditPlacesBloc>()
                                                              .add(MarkVisitedPlace(
                                                                  place: widget
                                                                      .place,
                                                                  placeList: widget
                                                                      .placeList));
                                                        },
                                                        icon: const Icon(Icons.check_circle_outline_rounded)),
                                                IconButton(
                                                    style: IconButton.styleFrom(
                                                        backgroundColor: Theme.of(
                                                                        context)
                                                                    .brightness ==
                                                                Brightness.light
                                                            ? FlexColor
                                                                .bahamaBlueLightSecondary
                                                                .withOpacity(
                                                                    0.12)
                                                            : FlexColor
                                                                .bahamaBlueDarkSecondaryContainer
                                                                .withOpacity(
                                                                    0.12)),
                                                    splashRadius: 60,
                                                    splashColor: FlexColor
                                                        .bahamaBlueDarkPrimaryContainer,
                                                    onPressed: () {
                                                      context
                                                                  .read<
                                                                      ListSortCubit>()
                                                                  .state
                                                                  .status ==
                                                              'Visited'
                                                          ? context
                                                              .read<
                                                                  EditPlacesBloc>()
                                                              .add(DeleteVisitedPlace(
                                                                  place: widget
                                                                      .place,
                                                                  placeList: widget
                                                                      .placeList))
                                                          : context
                                                              .read<
                                                                  EditPlacesBloc>()
                                                              .add(DeletePlace(
                                                                  place: widget
                                                                      .place,
                                                                  placeList: widget
                                                                      .placeList));
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .delete_forever_rounded,
                                                    )),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ));
        });
  }
}
