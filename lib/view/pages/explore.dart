import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PreferredSize(
          preferredSize: const Size.fromHeight(80), child: MainBottomNavBar()),
      body: CustomScrollView(
        slivers: [
          const MainTopAppBar(),
          // const SliverToBoxAdapter(child: SearchBar()),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return const ExploreCard();
              },
              childCount: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class ExploreCard extends StatefulWidget {
  const ExploreCard({super.key});

  @override
  State<ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<ExploreCard> {
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
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
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  'https://lh3.googleusercontent.com/p/AF1QipPygSVzL-3cUt5zaFAiHRN1mjspJj-s1bjlbYmi=s680-w680-h510')),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  'https://lh3.googleusercontent.com/p/AF1QipPygSVzL-3cUt5zaFAiHRN1mjspJj-s1bjlbYmi=s680-w680-h510')),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  'https://lh3.googleusercontent.com/p/AF1QipPygSVzL-3cUt5zaFAiHRN1mjspJj-s1bjlbYmi=s680-w680-h510')),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                  'https://lh3.googleusercontent.com/p/AF1QipPygSVzL-3cUt5zaFAiHRN1mjspJj-s1bjlbYmi=s680-w680-h510')),
                        ),
                      ),
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
                        count: 4,
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
                          Text('Three Thirds Cafe',
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
                              label: const Text('Cafe'),
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
                        ],
                      ),
                      const Chip(
                        side: BorderSide.none,
                        backgroundColor: Color.fromARGB(255, 25, 60, 253),
                        avatar: Text('✨', style: TextStyle(fontSize: 12.0)),
                        label: Text('New',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12.0)),
                        labelPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        visualDensity: VisualDensity.compact,
                      )
                    ],
                  ),
                  const Row(
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4.0,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14.0,
                          ),
                          Text('Southold, NY')
                        ],
                      )
                    ],
                  ),
                  const GutterSmall(),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
