import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/explore/explore_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/gpt_place.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/dialogs/review_card_dialog.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:leggo/view/widgets/tweens/custom_rect_tween.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

final TextEditingController _cityController = TextEditingController();
final TextEditingController _stateController = TextEditingController();

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(80), child: MainBottomNavBar()),
      body: CustomScrollView(
        slivers: [
          const MainTopAppBar(),
          // const SliverToBoxAdapter(child: SearchBar()),
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              if (state is ExploreError) {
                return SliverFillRemaining(
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error Exploring...'),
                      const Gutter(),
                      ElevatedButton.icon(
                          onPressed: () {
                            context.read<ExploreBloc>().add(LoadExplore(
                                placeType: _searchController.value.text.trim(),
                                city: _cityController.value.text.trim(),
                                state: _stateController.value.text.trim()));
                          },
                          label: const Text('Try Again'),
                          icon: const Icon(Icons.refresh)),
                    ],
                  )),
                );
              }
              if (state is ExploreInitial) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: TextField(
                                      onChanged: (value) {
                                        context
                                            .read<ExploreBloc>()
                                            .add(SetQuery(value));
                                      },
                                      controller: _searchController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: const InputDecoration(
                                        label: Text('I\'m looking for...'),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        hintText: 'Coffee, Sushi, etc.',
                                      ),
                                    ),
                                  ),
                                  const Gutter(),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Wrap(
                                          spacing: 4.0,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Icon(Icons.location_on, size: 16.0),
                                            Text('Near'),
                                          ],
                                        ),
                                        const SizedBox(height: 2.0),
                                        InkWell(
                                          onTap: () async {
                                            await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return const SetExploreLocationDialog();
                                                }).then((value) {
                                              setState(() {});
                                            });
                                          },
                                          child: context
                                                      .watch<ExploreBloc>()
                                                      .location !=
                                                  ''
                                              ? Chip(
                                                  side: BorderSide.none,
                                                  label: Text(context
                                                      .read<ExploreBloc>()
                                                      .location),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                )
                                              : const Chip(
                                                  side: BorderSide.none,
                                                  label: Text('Set Location'),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Gutter(),
                              // Location filter chip
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Gutter(),
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        context
                                            .read<ExploreBloc>()
                                            .add(
                                                LoadExplore(
                                                    placeType: _searchController
                                                        .value.text
                                                        .trim(),
                                                    city: _cityController
                                                        .value.text
                                                        .trim(),
                                                    state: _stateController
                                                        .value.text
                                                        .trim()));
                                      },
                                      label: const Text('Explore'),
                                      icon: const Icon(Icons.explore)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // const GutterTiny(),
                      ],
                    ),
                  ),
                );
              }
              if (state is ExploreLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child:
                        Wrap(direction: Axis.vertical, spacing: 8.0, children: [
                      LoadingAnimationWidget.beat(
                          color: Globals().gottaGoOrange, size: 20.0),
                      const Text('Exploring...'),
                    ]),
                  ),
                );
              }
              if (state is ExploreLoaded) {
                return SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: TextField(
                                onChanged: (value) {
                                  context
                                      .read<ExploreBloc>()
                                      .add(SetQuery(value));
                                },
                                controller: _searchController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: const InputDecoration(
                                  label: Text('I\'m looking for...'),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: 'Cafe, Restaurant, etc.',
                                ),
                              ),
                            ),
                            const Gutter(),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Wrap(
                                    spacing: 4.0,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Icon(Icons.location_on, size: 16.0),
                                      Text('Near'),
                                    ],
                                  ),
                                  const SizedBox(height: 2.0),
                                  InkWell(
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return const SetExploreLocationDialog();
                                          }).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child:
                                        context.watch<ExploreBloc>().location !=
                                                ''
                                            ? Chip(
                                                side: BorderSide.none,
                                                label: Text(context
                                                    .read<ExploreBloc>()
                                                    .location),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              )
                                            : const Chip(
                                                side: BorderSide.none,
                                                label: Text('Set Location'),
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ExploreCard(
                          googlePlace: state.googlePlace,
                          gptPlace: state.gptPlace),
                      const GutterTiny(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                              // style: ElevatedButton.styleFrom(
                              //     backgroundColor: Colors.white,
                              //     foregroundColor: Colors.redAccent),
                              onPressed: () {
                                List<String> negativeQueries =
                                    context.read<ExploreBloc>().negativeQueries;
                                if (negativeQueries
                                        .contains(state.gptPlace.name) ==
                                    false) {
                                  negativeQueries.add(state.gptPlace.name);
                                  print(
                                      'Added ${state.gptPlace.name} to negative queries');
                                }
                              },
                              icon: const Icon(Icons.thumb_down_alt_rounded,
                                  size: 20.0)),
                          const Gutter(),
                          ElevatedButton.icon(
                              onPressed: () {
                                context.read<ExploreBloc>().add(LoadExplore(
                                      placeType:
                                          _searchController.value.text.trim(),
                                      city: _cityController.value.text.trim(),
                                      state: _stateController.value.text.trim(),
                                    ));
                              },
                              label: const Text('Explore'),
                              icon: const Icon(Icons.explore)),
                          const Gutter(),
                          IconButton.filled(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green[500],
                              ),
                              onPressed: () {
                                List<String> positiveQueries =
                                    context.read<ExploreBloc>().positiveQueries;
                                if (positiveQueries
                                        .contains(state.gptPlace.name) ==
                                    false) {
                                  positiveQueries.add(state.gptPlace.name);
                                  print(
                                      'Added ${state.gptPlace.name} to positive queries');
                                }
                              },
                              icon: const Icon(
                                Icons.thumb_up_alt_rounded,
                                size: 20.0,
                              )),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Something Went Wrong...')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SetExploreLocationDialog extends StatefulWidget {
  const SetExploreLocationDialog({
    super.key,
  });

  @override
  State<SetExploreLocationDialog> createState() =>
      _SetExploreLocationDialogState();
}

class _SetExploreLocationDialogState extends State<SetExploreLocationDialog> {
  @override
  void initState() {
    super.initState();
    if (context.read<ExploreBloc>().location != '') {
      _cityController.text =
          context.read<ExploreBloc>().location.split(',')[0] ?? '';
      _stateController.text =
          context.read<ExploreBloc>().location.split(',')[1] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Set Location',
              style: Theme.of(context).textTheme.headlineLarge),
          const Gutter(),
          TextField(
            controller: _cityController,
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            decoration: const InputDecoration(
              label: Text('City'),
            ),
          ),
          const Gutter(),
          TextField(
            controller: _stateController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              label: Text('State'),
            ),
          ),
          const Gutter(),
          ElevatedButton.icon(
              onPressed: () {
                if (_cityController.text.isNotEmpty &&
                    _stateController.text.isNotEmpty) {
                  context.read<ExploreBloc>().add(SetLocation(
                      _cityController.value.text.trim(),
                      _stateController.value.text.trim()));
                  setState(() {});
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Please enter a city and state!'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              icon: const Icon(Icons.my_location),
              label: const Text('Set Location')),
        ]),
      ),
    );
  }
}

class ExploreCard extends StatefulWidget {
  final GooglePlace googlePlace;
  final GptPlace gptPlace;
  const ExploreCard(
      {super.key, required this.googlePlace, required this.gptPlace});

  @override
  State<ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<ExploreCard> {
  final PageController _pageController = PageController();
  final PageController detailsSlideshowController = PageController();
  @override
  Widget build(BuildContext context) {
    print('Google Place Photos: ${widget.googlePlace.photos}');
    List<String> photoReferences = [];
    if (widget.googlePlace.photos != null) {
      for (var photo in widget.googlePlace.photos!) {
        photoReferences.add(photo!['photo_reference']);
      }
    }
    return BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
      builder: (context, state) {
        if (state is SavedPlacesUpdated) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                  child: Column(
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 48.0),
                  Text('Place Added',
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              ));
            },
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: OpenContainer(
            closedColor: Colors.transparent,
            closedElevation: 0.0,
            openBuilder: (context, action) {
              String? todaysHours =
                  getTodaysHoursFromGooglePlace(widget.googlePlace);
              Uri? placeWebsite;
              Uri? placePhoneNumber;

              return Scaffold(
                bottomNavigationBar: MainBottomNavBar(),
                body: CustomScrollView(
                  slivers: [
                    const MainTopAppBar(),
                    SliverList(
                        delegate: SliverChildListDelegate([
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          SizedBox(
                            height: 250,
                            width: MediaQuery.of(context).size.width,
                            child: widget.googlePlace.photos != null &&
                                    widget.googlePlace.photos!.isNotEmpty
                                ? AspectRatio(
                                    aspectRatio: 4 / 3,
                                    child: PageView(
                                      //  shrinkWrap: true,
                                      controller: detailsSlideshowController,
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      // padding: EdgeInsets.zero,
                                      children: [
                                        for (dynamic image
                                            in widget.googlePlace.photos!)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8.0, 8.0, 8.0, 0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
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
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          color:
                                                              Theme.of(context)
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
                                  )
                                : CachedNetworkImage(
                                    imageUrl:
                                        'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=${widget.googlePlace.photos![0]}&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}',
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: SizedBox(
                                        width: 160,
                                        child: FittedBox(
                                          child: Chip(
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
                                                    initialRating: widget
                                                        .googlePlace.rating!,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return const Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      );
                                                    },
                                                    onRatingUpdate: (value) {}),
                                                Text(widget.googlePlace.rating
                                                    .toString())
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    widget.googlePlace.icon != null
                                        ? Flexible(
                                            child: Chip(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14)),
                                                avatar: CachedNetworkImage(
                                                  imageUrl:
                                                      widget.googlePlace.icon!,
                                                  height: 16,
                                                ),
                                                label: Text(capitalizeAllWord(
                                                    widget.googlePlace.type!
                                                        .replaceAll(
                                                            '_', ' ')))),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          widget.googlePlace.photos != null &&
                                  widget.googlePlace.photos!.isNotEmpty
                              ? Positioned(
                                  bottom: 16.0,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: SmoothPageIndicator(
                                      controller: detailsSlideshowController,
                                      count: widget.googlePlace.photos!.length,
                                      effect: WormEffect(
                                        dotHeight: 10.0,
                                        dotWidth: 10.0,
                                        dotColor: Theme.of(context)
                                            .colorScheme
                                            .tertiaryContainer,
                                        activeDotColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
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
                                child: Text(
                                  widget.googlePlace.name!,
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
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 14.0,
                                children: [
                                  widget.googlePlace.website != null
                                      ? CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          child: IconButton(
                                            onPressed: () async {
                                              await launchUrl(Uri.parse(
                                                  widget.googlePlace.website!));
                                            },
                                            icon: const Icon(
                                              Icons.web_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                  widget.googlePlace.formattedPhoneNumber !=
                                          null
                                      ? CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          child: IconButton(
                                            onPressed: () async {
                                              await launchUrl(Uri(
                                                  scheme: 'tel',
                                                  path: widget.googlePlace
                                                      .formattedPhoneNumber!));
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
                                      '${widget.gptPlace.city}, ${widget.gptPlace.state}')
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
                                          label: Text.rich(TextSpan(children: [
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
                                itemCount:
                                    widget.googlePlace.reviews?.length ?? 0,
                                itemBuilder: (context, index) {
                                  var thisReview =
                                      widget.googlePlace.reviews![index];
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
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '"${widget.googlePlace.reviews![index]['text']}"',
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
                                                                    Icons.star,
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
                                                                          FontWeight
                                                                              .bold),
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
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      insetAnimationDuration:
                                          const Duration(milliseconds: 400),
                                      child: AddToListDialog(
                                          place: widget.googlePlace),
                                    );
                                  });
                            },
                            icon: const Icon(Icons.add_location_alt_outlined,
                                size: 20.0),
                            label: const Text('Add to List')),
                      )
                    ]))
                  ],
                ),
              );
            },
            closedBuilder: (context, action) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          PageView(
                            controller: _pageController,
                            children: [
                              if (photoReferences.isNotEmpty)
                                for (String ref in photoReferences)
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                  color: Colors.grey[300]!,
                                                  child: Center(
                                                      child:
                                                          LoadingAnimationWidget
                                                              .staggeredDotsWave(
                                                    color:
                                                        Globals().gottaGoOrange,
                                                    size: 20.0,
                                                  ))),
                                          imageUrl:
                                              'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=$ref&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}'))
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                    Icons.add_location_alt_outlined)),
                          ),
                          Positioned(
                              bottom: 16.0,
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: photoReferences.length,
                                onDotClicked: (index) =>
                                    _pageController.animateToPage(index,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeIn),
                                effect: WormEffect(
                                    type: WormType.thin,
                                    dotColor: Colors.grey[300]!,
                                    activeDotColor: Colors.white,
                                    dotHeight: 8.0,
                                    dotWidth: 8.0,
                                    spacing: 8.0,
                                    strokeWidth: 2.0),
                              ))
                        ],
                      ),
                    ),
                    const GutterSmall(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 8.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(widget.googlePlace.name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                  // Middle dot character
                                  Text('·',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Chip(
                                      side: BorderSide.none,
                                      visualDensity: VisualDensity.compact,
                                      label: Text(widget.gptPlace.type),
                                      backgroundColor: Colors.grey[200],
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      avatar: const Icon(
                                        Icons.local_cafe_outlined,
                                        size: 14.0,
                                      ),
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.black)),
                                  // const Chip(
                                  //   side: BorderSide.none,
                                  //   backgroundColor: Color.fromARGB(255, 25, 60, 253),
                                  //   avatar: Text('✨', style: TextStyle(fontSize: 12.0)),
                                  //   label: Text('New',
                                  //       style: TextStyle(
                                  //           color: Colors.white, fontSize: 12.0)),
                                  //   labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                  //   visualDensity: VisualDensity.compact,
                                  // )
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4.0,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 14.0,
                                  ),
                                  Text(
                                      '${widget.gptPlace.city}, ${widget.gptPlace.state}')
                                ],
                              )
                            ],
                          ),
                          const GutterSmall(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(widget.gptPlace.description,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const Gutter()
                  ]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AddToListDialog extends StatefulWidget {
  final GooglePlace place;
  const AddToListDialog({required this.place, super.key});

  @override
  State<AddToListDialog> createState() => _AddToListDialogState();
}

class _AddToListDialogState extends State<AddToListDialog> {
  final ScrollController _scrollController = ScrollController();
  PlaceList? selectedList;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Gutter(),
        Text('Add ${widget.place.name} to a list',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge),
        const Gutter(),
        Text.rich(
          TextSpan(children: [
            //  const TextSpan(text: 'You can add '),
            const TextSpan(text: 'Add '),
            TextSpan(
                text: widget.place.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            // const TextSpan(text: ' to one of your lists, or create a new one')
            const TextSpan(text: ' to one of your lists:')
          ], style: Theme.of(context).textTheme.bodyMedium),
          textAlign: TextAlign.center,
        ),
        const Gutter(),
        context.read<SavedListsBloc>().allPlaceLists.isNotEmpty
            ? Flexible(
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView.separated(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount:
                          context.read<SavedListsBloc>().allPlaceLists.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          // tileColor: Colors.grey[200]!,
                          shape: selectedList ==
                                  context
                                      .read<SavedListsBloc>()
                                      .allPlaceLists[index]
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      width: 2.0))
                              : null,
                          onTap: () {
                            setState(() {
                              selectedList = context
                                  .read<SavedListsBloc>()
                                  .allPlaceLists[index];
                            });
                            // context.read<ExploreBloc>().add(AddPlaceToList(
                            //     context.read<ExploreBloc>().lists[index].id,
                            //     place.placeId));
                            //  context.pop();
                          },
                          title: Text(context
                              .read<SavedListsBloc>()
                              .allPlaceLists[index]
                              .name),
                        );
                      }),
                ),
              )
            : ElevatedButton.icon(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return const Dialog(
                            //child: CreateListDialog(),
                            // TODO: Create List Dialog & Fix bottom nav bar not awworking when explor container expanded
                            );
                      });
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New List')),
        const Gutter(),
        context.read<SavedListsBloc>().allPlaceLists.isNotEmpty
            ? BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
                builder: (context, state) {
                  if (state is SavedPlacesLoading) {
                    return LoadingAnimationWidget.beat(
                        color: Globals().gottaGoOrange, size: 20.0);
                  }
                  if (state is SavedPlacesUpdated) {
                    context.pop();
                  }
                  if (state is SavedPlacesLoaded ||
                      state is SavedPlacesInitial) {
                    return ElevatedButton.icon(
                        onPressed: () {
                          if (selectedList != null) {
                            context.read<SavedPlacesBloc>().add(AddPlace(
                                place: Place.fromGooglePlace(widget.place),
                                placeList: selectedList!));
                            context.pop();
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Please select a list!'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add to List'));
                  } else {
                    return const SizedBox();
                  }
                },
              )
            : const SizedBox(),
      ]),
    );
  }
}
