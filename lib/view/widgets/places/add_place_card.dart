import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:leggo/view/widgets/places/search_places_sheet.dart';

class AddPlaceCard extends StatefulWidget {
  const AddPlaceCard({
    Key? key,
  }) : super(key: key);

  @override
  State<AddPlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<AddPlaceCard> {
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
  Color openNowContainerColor = Colors.white;
  Color ratingContainerColor = Colors.black87;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 170, maxHeight: 180),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.8),
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return SearchPlacesSheet(mounted: mounted);
                  });
            },
            child: Card(
              clipBehavior: Clip.antiAlias,
              //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: [
                        ConstrainedBox(
                            constraints: const BoxConstraints(
                                minHeight: 170,
                                maxHeight: 180,
                                minWidth: 120,
                                maxWidth: 120),
                            child: Container(
                              decoration: const BoxDecoration(
                                  gradient: LinearGradient(stops: [
                                0.2,
                                0.8
                              ], colors: [
                                FlexColor.deepBlueDarkSecondary,
                                FlexColor.deepBlueLightPrimaryContainer,
                              ])),
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12.0)),
                                  child: Container(
                                    alignment: AlignmentDirectional.center,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 24.0,
                                    width: 70.0,
                                    child: const SizedBox(),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12.0)),
                                  child: Container(
                                      alignment: AlignmentDirectional.centerEnd,
                                      color: Colors.black87,
                                      height: 20.0,
                                      width: 50.0,
                                      child: SizedBox(
                                        height: 20,
                                        width: 40,
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2.0),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: const SizedBox())),
                                      )),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    )),
                    Flexible(
                        flex: 2,
                        child: Center(
                          child: Animate(
                            effects: const [
                              // ShakeEffect(
                              //     duration: Duration(seconds: 1), hz: 1),
                              ShimmerEffect(
                                  duration: Duration(milliseconds: 600))
                            ],
                            child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  fixedSize: MaterialStateProperty.all(
                                      const Size(210, 32)),
                                  // foregroundColor: MaterialStateProperty.all(
                                  //   Colors.white.withOpacity(0.9),
                                  // ),
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withOpacity(0.8),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return SearchPlacesSheet(
                                            mounted: mounted);
                                      });
                                },
                                icon: const Icon(Icons.add_circle_rounded),
                                label: const Text('Add Your First Place')),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
