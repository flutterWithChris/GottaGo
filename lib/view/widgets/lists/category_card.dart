import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/lists/delete_list_dialog.dart';

import '../../../bloc/profile_bloc.dart';

class CategoryCard extends StatelessWidget {
  final PlaceList placeList;

  const CategoryCard({
    Key? key,
    required this.placeList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    //color: FlexColor.deepBlueDarkPrimaryContainer.withOpacity(0.15),
                    child: Stack(
                      children: [
                        ListTile(
                          trailing: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: PopupMenuButton(
                                position: PopupMenuPosition.under,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                // onSelected: (value) {},
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? FlexColor.bahamaBlueLightPrimary
                                      : Colors.white,
                                ),
                                itemBuilder: (context) => <PopupMenuEntry>[
                                      PopupMenuItem(
                                          onTap: () {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (timeStamp) {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return DeleteListDialog(
                                                    placeList: placeList,
                                                  );
                                                },
                                              );
                                            });
                                          },
                                          child: const Text('Delete List'))
                                    ]),
                          ),
                          onTap: () {
                            context
                                .read<SavedPlacesBloc>()
                                .add(LoadPlaces(placeList: placeList));
                            context.push('/home/placeList-page');
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 30.0),
                          minLeadingWidth: 20,
                          title: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 4.0, left: 8.0),
                            child: Text(
                              placeList.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 23.0),
                            child: Wrap(
                              children: [
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: '${placeList.placeCount} ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(text: ' Saved Places'),
                                ])),
                              ],
                            ),
                          ),
                          leading: Icon(
                            Icons.list_rounded,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? FlexColor.bahamaBlueLightPrimary
                                    : Colors.white,
                            size: 36,
                          ),
                        ),
                        placeList.listOwnerId !=
                                    context.read<ProfileBloc>().state.user.id ||
                                placeList.contributorIds.isNotEmpty
                            ? Positioned(
                                left: 16.0,
                                top: 10.0,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.groups_rounded,
                                      size: 20,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? FlexColor.bahamaBlueLightPrimary
                                              .withOpacity(0.6)
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                    const SizedBox(
                                      width: 12.0,
                                    ),
                                    // Text(
                                    //   'Shared List',
                                    //   style: TextStyle(
                                    //       fontStyle: FontStyle.italic),
                                    // ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
