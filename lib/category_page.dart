import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_place/google_place.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TypeAheadField(
                    textFieldConfiguration:
                        const TextFieldConfiguration(autofocus: true),
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
                      Navigator.pop(context);
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;
                      Scaffold.of(context).showBottomSheet(
                        (context) {
                          return DraggableScrollableSheet(
                            builder: (context, scrollController) {
                              return Column(
                                children: [
                                  Text(suggestion.description!),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ));
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
                Text(
                  'Breakfast Ideas',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
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
    );
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
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          contentPadding: const EdgeInsets.all(12.0),
          tileColor: Colors.white,
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(placeName),
              Row(
                children: [
                  Text(
                    'Open \'Til $closingTime',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  const CircleAvatar(
                    radius: 3,
                    backgroundColor: Colors.lightGreen,
                  )
                ],
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [Text(placeLocation), Text(placeDescription)],
          ),
        ),
      ),
    );
  }
}
