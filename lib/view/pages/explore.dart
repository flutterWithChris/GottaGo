import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/explore/explore_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/cubit/explore_slideshow/explore_slideshow_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/gpt_place.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final TextEditingController _cityController = TextEditingController();
final TextEditingController _stateController = TextEditingController();

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  bool isLiked = false;
  bool isDisliked = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(80), child: MainBottomNavBar()),
      body: CustomScrollView(
        slivers: [
          const MainTopAppBarSmall(),
          // const SliverToBoxAdapter(child: SearchBar()),
          BlocConsumer<ExploreBloc, ExploreState>(
            listener: (context, state) {
              // if (state is ExploreLoaded) {
              //   setState(() {
              //     isLiked = false;
              //     isDisliked = false;
              //   });
              // }
            },
            builder: (context, state) {
              if (state is ExploreError) {
                return SliverFillRemaining(
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                  hintText: 'Coffee, Sushi, etc.',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Gutter(),
                          ElevatedButton.icon(
                              onPressed: () {
                                context.read<ExploreBloc>().add(LoadExplore(
                                    placeType:
                                        _searchController.value.text.trim(),
                                    city: _cityController.value.text.trim(),
                                    state: _stateController.value.text.trim()));
                              },
                              label: const Text('Explore'),
                              icon: const Icon(Icons.travel_explore_outlined)),
                        ],
                      ),
                      const Gutter(),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_rounded,
                              size: 60.0, color: Colors.red),
                          const Gutter(),
                          Text(
                            'Error Exploring...',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Gutter(),
                          ElevatedButton.icon(
                              onPressed: () {
                                context.read<ExploreBloc>().add(LoadExplore(
                                    placeType:
                                        _searchController.value.text.trim(),
                                    city: _cityController.value.text.trim(),
                                    state: _stateController.value.text.trim()));
                              },
                              label: const Text('Retry'),
                              icon: const Icon(Icons.refresh_rounded)),
                        ],
                      )),
                      const Gutter(),
                    ],
                  )),
                );
              }
              if (state is ExploreLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: Wrap(
                        direction: Axis.horizontal,
                        spacing: 16.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          LoadingAnimationWidget.halfTriangleDot(
                              color: Globals().gottaGoOrange, size: 20.0),
                          Text('Exploring...',
                              style: Theme.of(context).textTheme.headlineSmall),
                        ]),
                  ),
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
                                      icon: const Icon(
                                          Icons.travel_explore_outlined)),
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

              if (state is ExploreLoaded) {
                isDisliked = context
                    .watch<ExploreBloc>()
                    .negativeQueries
                    .contains(state.gptPlace.name);
                isLiked = context
                    .watch<ExploreBloc>()
                    .positiveQueries
                    .contains(state.gptPlace.name);
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        ),
                        ExploreCard(
                            googlePlace: state.googlePlace,
                            gptPlace: state.gptPlace),
                        const GutterTiny(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton.filledTonal(
                              style: ElevatedButton.styleFrom(
                                side: isDisliked
                                    ? const BorderSide(
                                        color: Colors.red, width: 2.0)
                                    : null,
                              ),
                              onPressed: () {
                                List<String> negativeQueries =
                                    context.read<ExploreBloc>().negativeQueries;
                                if (isDisliked == false) {
                                  negativeQueries.add(state.gptPlace.name);
                                  print(
                                      'Added ${state.gptPlace.name} to negative queries');
                                } else {
                                  negativeQueries.remove(state.gptPlace.name);
                                  print(
                                      'Removed ${state.gptPlace.name} from negative queries');
                                }
                                setState(() {
                                  isDisliked = !isDisliked;
                                });
                              },
                              icon: const Icon(Icons.thumb_down_alt_rounded,
                                      size: 20.0)
                                  .animate(
                                    target: isDisliked ? 1.0 : 0.0,
                                    onComplete: (controller) =>
                                        controller.animateBack(0),
                                  )
                                  .slideY(
                                    begin: 0.0,
                                    end: 0.4,
                                    curve: Curves.easeInOutCubic,
                                  )
                                  .rotate(
                                    begin: 0.0,
                                    end: -0.05,
                                    curve: Curves.easeInOutCubic,
                                  ),
                            )
                                .animate(
                                  target: isDisliked ? 1.0 : 0.0,
                                  onComplete: (controller) =>
                                      controller.animateBack(0),
                                )
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.1, 1.1),
                                  curve: Curves.easeInOutCubic,
                                ),
                            const Gutter(),
                            ElevatedButton.icon(
                                onPressed: () {
                                  context.read<ExploreBloc>().add(LoadExplore(
                                        placeType:
                                            _searchController.value.text.trim(),
                                        city: _cityController.value.text.trim(),
                                        state:
                                            _stateController.value.text.trim(),
                                      ));
                                  if (isDisliked == false && isLiked == false) {
                                    context
                                        .read<ExploreBloc>()
                                        .queryHistory
                                        .add(state.gptPlace.name);
                                  }
                                },
                                label: const Text('Explore'),
                                icon:
                                    const Icon(Icons.travel_explore_outlined)),
                            const Gutter(),
                            IconButton.filled(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green[500],
                                side: isLiked
                                    ? const BorderSide(
                                        color: Colors.white, width: 3.0)
                                    : null,
                              ),
                              onPressed: () {
                                List<String> positiveQueries =
                                    context.read<ExploreBloc>().positiveQueries;
                                if (isLiked == false) {
                                  positiveQueries.add(state.gptPlace.name);
                                  print(
                                      'Added ${state.gptPlace.name} to positive queries');
                                } else {
                                  positiveQueries.remove(state.gptPlace.name);
                                  print(
                                      'Removed ${state.gptPlace.name} from positive queries');
                                }

                                setState(() {
                                  isLiked = !isLiked;
                                });
                              },
                              icon: const Icon(
                                Icons.thumb_up_alt_rounded,
                                size: 20.0,
                              )
                                  .animate(
                                    target: isLiked ? 1.0 : 0.0,
                                    onComplete: (controller) =>
                                        controller.animateBack(0),
                                  )
                                  .slideY(
                                    begin: 0.0,
                                    end: -0.4,
                                    curve: Curves.easeInOutCubic,
                                  )
                                  .rotate(
                                    begin: 0.0,
                                    end: -0.05,
                                    curve: Curves.easeInOutCubic,
                                  ),
                            )
                                .animate(
                                  target: isLiked ? 1.0 : 0.0,
                                  onComplete: (controller) =>
                                      controller.animateBack(0),
                                )
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.1, 1.1),
                                  curve: Curves.easeInOutCubic,
                                ),
                          ],
                        ),
                      ],
                    ),
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Photo Index: ${context.read<ExploreBloc>().photoIndex}');
    PageController pageController = PageController(
      initialPage: context.read<ExploreSlideshowCubit>().state.photoIndex ?? 0,
    );
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
          child: Card(
            child: InkWell(
              onTap: () =>
                  context.go('/explore/details', extra: pageController.page),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    BlocBuilder<ExploreSlideshowCubit, ExploreSlideshowState>(
                      builder: (context, state) {
                        pageController = PageController(
                          initialPage: state.photoIndex ?? 0,
                        );
                        return Hero(
                          tag: '${widget.googlePlace.placeId!}-gallery',
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                PageView(
                                  onPageChanged: (value) {
                                    context
                                        .read<ExploreSlideshowCubit>()
                                        .swipe(value);
                                  },
                                  controller: pageController,
                                  children: [
                                    if (photoReferences.isNotEmpty)
                                      for (String ref in photoReferences)
                                        ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                        color:
                                                            Colors.grey[300]!,
                                                        child: Center(
                                                            child: LoadingAnimationWidget
                                                                .staggeredDotsWave(
                                                          color: Globals()
                                                              .gottaGoOrange,
                                                          size: 20.0,
                                                        ))),
                                                imageUrl:
                                                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=1080&maxheight=1920&photo_reference=$ref&key=${dotenv.get('GOOGLE_PLACES_API_KEY')}'))
                                  ],
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton.filledTonal(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 2.0,
                                          backgroundColor:
                                              Globals().gottaGoOrange),
                                      onPressed: () async {
                                        await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                child: AddToListDialog(
                                                    place: widget.googlePlace),
                                              );
                                            });
                                      },
                                      icon: const Icon(
                                        Icons.add_location_alt_outlined,
                                        color: Colors.white,
                                      )),
                                ),
                                Positioned(
                                    bottom: 16.0,
                                    child: SmoothPageIndicator(
                                      controller: pageController,
                                      count: photoReferences.length,
                                      onDotClicked: (index) =>
                                          pageController.animateToPage(index,
                                              duration: const Duration(
                                                  milliseconds: 500),
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
                        );
                      },
                    ),
                    const GutterSmall(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Wrap(
                                spacing: 12.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Hero(
                                    tag: '${widget.googlePlace.placeId!}-name',
                                    child: Text(
                                      widget.googlePlace.name!,
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
                                  if (widget.googlePlace.type != null)
                                    Chip(
                                        side: BorderSide.none,
                                        visualDensity: VisualDensity.compact,
                                        label: Text(widget.googlePlace.type!
                                            .replaceAll('_', ' ')
                                            .capitalize),
                                        backgroundColor: Colors.grey[200],
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                        avatar: CachedNetworkImage(
                                          imageUrl: widget.googlePlace.icon!,
                                          height: 12,
                                        ),
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.black)),
                                  Hero(
                                    flightShuttleBuilder: (flightContext,
                                        animation,
                                        flightDirection,
                                        fromHeroContext,
                                        toHeroContext) {
                                      return DefaultTextStyle(
                                          style:
                                              DefaultTextStyle.of(toHeroContext)
                                                  .style,
                                          child: toHeroContext.widget);
                                    },
                                    tag:
                                        '${widget.googlePlace.placeId!}-location',
                                    child: Wrap(
                                      spacing: 5.0,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_pin,
                                          size: 13,
                                        ),
                                        Text(
                                          '${widget.gptPlace.city}, ${widget.gptPlace.state}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Hero(
                                flightShuttleBuilder: (flightContext,
                                    animation,
                                    flightDirection,
                                    fromHeroContext,
                                    toHeroContext) {
                                  return DefaultTextStyle(
                                      style: DefaultTextStyle.of(toHeroContext)
                                          .style,
                                      child: toHeroContext.widget);
                                },
                                tag:
                                    '${widget.googlePlace.placeId!}-description',
                                child: Text(widget.gptPlace.description,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),
                            const Gutter()
                          ]),
                    ),
                  ],
                ),
              ),
            ),
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
        Text('Add to List',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge),
        const Gutter(),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'You can add '),
            TextSpan(
                text: widget.place.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const TextSpan(text: ' to one of your lists, or create a new one:')
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
                          leading: Icon(
                            deserializeIcon(context
                                .read<SavedListsBloc>()
                                .allPlaceLists[index]
                                .icon),
                            size: 18.0,
                          ),
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
            : const SizedBox(),
        const Gutter(),
        context.read<SavedListsBloc>().allPlaceLists.isNotEmpty
            ? BlocConsumer<SavedPlacesBloc, SavedPlacesState>(
                listener: (context, state) {
                  if (state is SavedPlacesUpdated) {
                    context.pop();
                  }
                },
                builder: (context, state) {
                  if (state is SavedPlacesLoading) {
                    return LoadingAnimationWidget.beat(
                        color: Globals().gottaGoOrange, size: 20.0);
                  }

                  if (state is SavedPlacesLoaded ||
                      state is SavedPlacesInitial ||
                      state is SavedPlacesUpdated) {
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
            : ElevatedButton.icon(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return const Dialog(
                          child: CreateListDialog(),
                        );
                      }).then((value) {
                    context.read<ExploreBloc>().add(AddPlaceToNewList(
                        Place.fromGooglePlace(widget.place), value));
                    context.pop();
                    return value;
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New List')),
        const GutterSmall(),
        context.read<SavedListsBloc>().allPlaceLists.isNotEmpty
            ? TextButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return const Dialog(
                          child: CreateListDialog(),
                        );
                      }).then((value) {
                    context.read<ExploreBloc>().add(AddPlaceToNewList(
                        Place.fromGooglePlace(widget.place), value));
                    context.pop();
                    return value;
                  });
                },
                // icon: const Icon(Icons.add),
                child: const Text('Create New List'))
            : const SizedBox(),
      ]),
    );
  }
}
