import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
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
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.6,
              child: SizedBox(
                height: 125,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  //   elevation: 2.0,
                  //  color: FlexColor.deepBlueDarkSecondaryContainer,
                  child: ListTile(
                    trailing: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[800]
                            : Colors.white,
                      ),
                    ),
                    minVerticalPadding: 24.0,
                    onTap: () async {
                      //context.read<SavedPlacesBloc>().add(LoadPlaces());
                      // context.go('/placeList-page');
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return const CreateListDialog();
                        },
                      );
                    },
                    contentPadding:
                        const EdgeInsets.fromLTRB(10.0, 12.0, 16.0, 12.0),
                    minLeadingWidth: 20,

                    //tileColor: categoryColor,
                    title: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10.0,
                      children: [
                        // placeList.icon != null
                        //     ? Icon(
                        //         placeList.icon,
                        //         size: 16,
                        //       )
                        //     : const SizedBox(),
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
                          width: 40,
                          height: 40,
                          child: Icon(
                            deserializeIcon(placeList.icon),
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[800]
                                    : Colors.white,
                            size: 30,
                          )),
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
