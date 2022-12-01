import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';

class SampleCategoryCard extends StatelessWidget {
  final PlaceList placeList;
  const SampleCategoryCard({
    Key? key,
    required this.placeList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: 0.6,
                child: Card(
                  elevation: 2.0,
                  //  color: FlexColor.deepBlueDarkSecondaryContainer,
                  child: ListTile(
                    minVerticalPadding: 24.0,
                    onTap: () {
                      //context.read<SavedPlacesBloc>().add(LoadPlaces());
                      // context.go('/placeList-page');
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const CreateListDialog();
                        },
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 24.0),
                    minLeadingWidth: 20,

                    //tileColor: categoryColor,
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10.0,
                      children: [
                        placeList.icon != null
                            ? Icon(
                                placeList.icon,
                                size: 16,
                              )
                            : const SizedBox(),
                        Text(
                          placeList.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text('${Random().nextInt(14) + 1} Saved Places'),
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                      child: SizedBox(
                        child: Stack(clipBehavior: Clip.none, children: [
                          Positioned(
                            right: 20,
                            bottom: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: Container(
                                    color:
                                        FlexColor.deepBlueDarkSecondaryVariant),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Container(
                                color: FlexColor.deepBlueDarkPrimaryContainer,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
