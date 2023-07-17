import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/explore/explore_bloc.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/gpt_place.dart';
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
                return const SliverToBoxAdapter(
                  child: Center(child: Text('Error Exploring...')),
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
                                      controller: _searchController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      onChanged: (value) {
                                        context
                                            .read<ExploreBloc>()
                                            .add(SetQuery(value));
                                      },
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
                                                });
                                          },
                                          child: context
                                                      .watch<ExploreBloc>()
                                                      .location !=
                                                  null
                                              ? Chip(
                                                  side: BorderSide.none,
                                                  label: Text(context
                                                      .watch<ExploreBloc>()
                                                      .location!),
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
                                        context.read<ExploreBloc>().add(
                                            LoadExplore(
                                                placeType: context
                                                    .read<ExploreBloc>()
                                                    .searchQuery!,
                                                city: state.city));
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
                return SliverToBoxAdapter(
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
                      ExploreCard(
                          googlePlace: state.googlePlace,
                          gptPlace: state.gptPlace),
                      const Gutter(),
                      ElevatedButton.icon(
                          onPressed: () {
                            context.read<ExploreBloc>().add(LoadExplore(
                                placeType:
                                    context.read<ExploreBloc>().searchQuery!,
                                city: 'Wading River'));
                          },
                          label: const Text('Explore'),
                          icon: const Icon(Icons.explore)),
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
    _cityController.text =
        context.read<ExploreBloc>().location?.split(',')[0] ?? '';
    _stateController.text =
        context.read<ExploreBloc>().location?.split(',')[1] ?? '';
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
                      '${_cityController.text.trim()}, ${_stateController.text.trim()}'));
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
  @override
  Widget build(BuildContext context) {
    print('Google Place Photos: ${widget.googlePlace.photos}');
    List<String> photoReferences = [];
    if (widget.googlePlace.photos != null) {
      for (var photo in widget.googlePlace.photos!) {
        photoReferences.add(photo!['photo_reference']);
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
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
                                  placeholder: (context, url) => Container(
                                      color: Colors.grey[300]!,
                                      child: Center(
                                          child: LoadingAnimationWidget
                                              .staggeredDotsWave(
                                        color: Globals().gottaGoOrange,
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
                        icon: const Icon(Icons.add_location_alt_outlined)),
                  ),
                  Positioned(
                      bottom: 16.0,
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: photoReferences.length,
                        onDotClicked: (index) => _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          // Middle dot character
                          Text('·',
                              style: Theme.of(context).textTheme.titleMedium),
                          Chip(
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                              label: Text(widget.gptPlace.type),
                              backgroundColor: Colors.grey[200],
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
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
      ),
    );
  }
}
