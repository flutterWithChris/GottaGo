import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class BlankPlaceCard extends StatefulWidget {
  const BlankPlaceCard({
    Key? key,
  }) : super(key: key);

  @override
  State<BlankPlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<BlankPlaceCard> {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 170, maxHeight: 180),
        child: Card(
          clipBehavior: Clip.antiAlias,
          //color: FlexColor.deepBlueDarkSecondaryContainer.withOpacity(0.10),
          child: Row(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
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
                              color: FlexColor.deepBlueLightPrimary,
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
                    ),
                  ),
                ],
              ),
              Flexible(
                flex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                        ),
                        child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            //visualDensity: const VisualDensity(vertical: 4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            // contentPadding: const EdgeInsets.symmetric(
                            //     horizontal: 12.0, vertical: 4.0),
                            //tileColor: Colors.white,

                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                        height: 20,
                                        width: 140,
                                        color: Colors.grey.shade300),
                                  )
                                ],
                              ),
                            ),
                            subtitle: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                      height: 16,
                                      width: 70,
                                      color: Colors.grey.shade300),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                      height: 16,
                                      width: 80,
                                      color: Colors.grey.shade300),
                                )
                              ],
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 12.0, right: 12.0, bottom: 10.0, top: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                  height: 18,
                                  width: 225,
                                  color: Colors.grey.shade300),
                            ),
                            const SizedBox(
                              height: 8.0,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                  height: 18,
                                  width: 225,
                                  color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
