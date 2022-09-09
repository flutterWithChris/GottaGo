import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    final GooglePlace googlePlace =
        GooglePlace(dotenv.env['GOOGLE_PLACES_API_KEY']!);

    final TextEditingController textEditingController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add_location_rounded),
          onPressed: () {
            showModalBottomSheet(
                backgroundColor:
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return SearchPlacesSheet(
                      googlePlace: googlePlace, mounted: mounted);
                });
          },
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 12.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(FontAwesomeIcons.egg),
                      Text(
                        'Breakfast Ideas',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        child: ClipOval(
                          child: Image.network(
                            'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/279649796_5507542659278888_8310477287351307005_n.jpg?_nc_cat=108&ccb=1-7&_nc_sid=730e14&_nc_ohc=4Tpv6Bh_tDcAX8C-EJA&_nc_ht=scontent-lga3-1.xx&oh=00_AT9vDLANBsucRWEu8nLlMCOjM8Dh7tmw4Sp895EThKmhSQ&oe=631D8E10',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        child: CircleAvatar(
                          child: ClipOval(
                            child: Image.network(
                              'https://scontent-lga3-1.xx.fbcdn.net/v/t39.30808-6/305213660_5298775460244393_3700270719083305575_n.jpg?_nc_cat=103&ccb=1-7&_nc_sid=09cbfe&_nc_ohc=wpo3El9R7wwAX8XRJSm&_nc_ht=scontent-lga3-1.xx&oh=00_AT_7LteTpaUMPC9OW73CL_C45dcVoiTT2GG3LKEodC90tw&oe=631C1CF2',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            ),
            const GoButton(),
            const PlaceCard(
              closingTime: '3PM',
              placeName: 'Hatch',
              placeLocation: 'Huntington, NY',
              placeDescription:
                  'An extensive menu of classic & creative American breakfast dishes with contemporary...',
              imageUrl:
                  'https://www.google.com/maps/uv?pb=!1s0x89e8287866d3ffff:0xa6734768501a1e3f!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe%3Dw258-h160-k-no!5shatch+huntington+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe&hl=en&sa=X&ved=2ahUKEwiwmoaj84D6AhWWkIkEHfHKDhUQoip6BAhREAM',
            ),
            const PlaceCard(
              closingTime: '3PM',
              placeName: 'Whiskey Down Diner',
              placeLocation: 'Farmingdale, NY',
              placeDescription:
                  'Familiar all-day diner offering typical comfort food such as pancakes, eggs, burgers...',
              imageUrl:
                  'https://www.google.com/maps/uv?pb=!1s0x89e82b9897a768f9%3A0x2853132db2dacf1b!3m1!7e115!4shttps%3A%2F%2Flh5.googleusercontent.com%2Fp%2FAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur%3Dw168-h160-k-no!5sdown%20diner%20-%20Google%20Search!15sCgIgAQ&imagekey=!1e10!2sAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur&hl=en&sa=X&ved=2ahUKEwjAmaKshYH6AhXNjYkEHQs5C6IQoip6BAhpEAM#',
            ),
            const PlaceCard(
              closingTime: '3PM',
              placeName: 'Jardin Cafe',
              placeLocation: 'Patchogue, NY',
              placeDescription:
                  '"I was pleasantly surprised to see such a varied menu with meat and tofu options."',
              imageUrl:
                  'https://www.google.com/maps/uv?pb=!1s0x89e849a3c6fe856d:0xabd40cec3dcf19a6!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipPOidJNkMv1UYjBKbw5sXQvANFfLayn9uCamtQH%3Dw120-h160-k-no!5sjardin+cafe+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipPOidJNkMv1UYjBKbw5sXQvANFfLayn9uCamtQH&hl=en&sa=X&ved=2ahUKEwjMg7HPhYH6AhURj4kEHf7oBT8Qoip6BAhdEAM',
            ),
            const PlaceCard(
              closingTime: '3PM',
              placeName: 'Rise & Grind',
              placeLocation: 'Patchogue, NY',
              placeDescription: '"excellent food, coffee and service..."',
              imageUrl:
                  'https://www.google.com/maps/uv?pb=!1s0x89c41f115b12a40f%3A0x1cb4aeb28234535!3m1!7e115!4shttps%3A%2F%2Flh5.googleusercontent.com%2Fp%2FAF1QipPxetTYWtNtyheHagncbjDIbW59m9kKW9pYS9Mk%3Dw120-h160-k-no!5srise%20and%20grind%20cafe%20-%20Google%20Search!15sCgIgAQ&imagekey=!1e10!2sAF1QipPxetTYWtNtyheHagncbjDIbW59m9kKW9pYS9Mk&hl=en&sa=X&ved=2ahUKEwjc4_a6hoH6AhWclIkEHbtlBrMQoip6BAhpEAM# ',
            ),
            const PlaceCard(
              closingTime: '3PM',
              placeName: 'Hatch',
              placeLocation: 'Huntington, NY',
              placeDescription:
                  'An extensive menu of classic & creative American breakfast dishes with contemporary...',
              imageUrl:
                  'https://www.google.com/maps/uv?pb=!1s0x89e8287866d3ffff:0xa6734768501a1e3f!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe%3Dw258-h160-k-no!5shatch+huntington+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe&hl=en&sa=X&ved=2ahUKEwiwmoaj84D6AhWWkIkEHfHKDhUQoip6BAhREAM',
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPlacesSheet extends StatelessWidget {
  const SearchPlacesSheet({
    Key? key,
    required this.googlePlace,
    required this.mounted,
  }) : super(key: key);

  final GooglePlace googlePlace;
  final bool mounted;
  Future<Uint8List?> getPhotos(DetailsResult detailsResult) async {
    var placeDetails = detailsResult;
    var photo = await googlePlace.photos
        .get(placeDetails.photos!.first.photoReference!, 1080, 1920);
    return photo;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.80,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: ListView(
            shrinkWrap: true,
            controller: scrollController,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      //  autofocus: true,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25)),
                          hintText: 'Search Places...',
                          prefixIcon: const Icon(Icons.search_rounded))),
                  suggestionsCallback: (pattern) async {
                    List<AutocompletePrediction> predictions = [];
                    if (pattern.isEmpty) return predictions;
                    var place = await googlePlace.autocomplete.get(pattern);
                    predictions = place!.predictions!;
                    return predictions;
                  },
                  itemBuilder: (context, itemData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      child: ListTile(
                        title: Text(itemData.description!),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    var placeDetails =
                        await googlePlace.details.get(suggestion.placeId!);
                    placeDetails!.result!.name;
                    if (!mounted) return;
                    context.read<PlaceSearchBloc>().add(
                        PlaceSelected(detailsResult: placeDetails.result!));
                  },
                ),
              ),
              Card(
                child: BlocBuilder<PlaceSearchBloc, PlaceSearchState>(
                  builder: (context, state) {
                    if (state.status == Status.loaded) {
                      var placeDetails = state.detailsResult;

                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                placeDetails!.name!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: FutureBuilder(
                                  future: getPhotos(placeDetails),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Image.memory(snapshot.data!),
                                      );
                                    } else {
                                      return AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: Center(
                                          child: Container(
                                              height: 300,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color: Colors.grey.shade200,
                                              child: const SizedBox(
                                                  height: 20,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()))),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(150, 30)),
                                onPressed: () {
                                  print(placeDetails.website);
                                },
                                icon: const Icon(Icons.web_rounded, size: 18),
                                label: const Text('Visit Website')),
                            Wrap(
                              spacing: 4.0,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Icon(
                                  Icons.place_rounded,
                                  size: 18,
                                ),
                                Text(placeDetails.formattedAddress!),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Wrap(
                                spacing: 6.0,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  RatingBar.builder(
                                    ignoreGestures: true,
                                    itemSize: 20.0,
                                    allowHalfRating: true,
                                    initialRating: placeDetails.rating!,
                                    itemBuilder: (context, index) {
                                      return const Icon(
                                        Icons.star,
                                        size: 12.0,
                                        color: Colors.amber,
                                      );
                                    },
                                    onRatingUpdate: (value) {},
                                  ),
                                  Text(placeDetails.rating.toString()),
                                ],
                              ),
                            ),
                            Chip(
                              label:
                                  Text(placeDetails.types!.first.capitalize()),
                              avatar: Image.network(
                                placeDetails.icon!,
                                height: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('Something Went Wrong..'),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: RichText(
                      text: const TextSpan(children: [
                        TextSpan(text: 'Add to'),
                        TextSpan(
                            text: ' Breakfast Ideas',
                            style: TextStyle(fontWeight: FontWeight.bold))
                      ]),
                    )),
              ),
            ],
          ),
        );
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class GoButton extends StatelessWidget {
  const GoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FractionallySizedBox(
        widthFactor: 0.65,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(125, 30),
            minimumSize: const Size(125, 30),
          ),
          child: const Text(
            'Let\'s Go Somewhere',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class PlaceCard extends StatelessWidget {
  final String imageUrl;
  final String placeName;
  final String placeDescription;
  final String closingTime;
  final String placeLocation;
  const PlaceCard({
    Key? key,
    required this.imageUrl,
    required this.placeName,
    required this.placeDescription,
    required this.closingTime,
    required this.placeLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ListTile(
              visualDensity: const VisualDensity(vertical: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              contentPadding: const EdgeInsets.all(12.0),
              //tileColor: Colors.white,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Wrap(
                  //spacing: 24.0,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(placeName),
                    Wrap(
                      spacing: 5.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_pin,
                          size: 13,
                        ),
                        Text(
                          placeLocation,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Open \'Til $closingTime',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(
                              width: 6.0,
                            ),
                            const CircleAvatar(
                              radius: 3,
                              backgroundColor: Colors.lightGreen,
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 28,
                          child: FittedBox(
                            child: Chip(
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              visualDensity: VisualDensity.compact,
                              label: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8.0,
                                  children: const [
                                    Icon(
                                      Icons.star,
                                      size: 18.0,
                                      color: Colors.amber,
                                    ),
                                    Text('4.5')
                                  ]),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Text(placeDescription)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
