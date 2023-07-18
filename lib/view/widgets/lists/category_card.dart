import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/view/widgets/animated_count/animated_count.dart';
import 'package:leggo/view/widgets/list_page/dialogs.dart';
import 'package:leggo/view/widgets/lists/delete_list_dialog.dart';
import 'package:leggo/view/widgets/premium_offer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../bloc/profile_bloc.dart';

class CategoryCard extends StatefulWidget {
  final PlaceList placeList;

  const CategoryCard({
    Key? key,
    required this.placeList,
  }) : super(key: key);

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  final GlobalKey _categoryCardShowcase = GlobalKey();

  final GlobalKey _iconPickerShowcaseKey = GlobalKey();

  BuildContext? buildContext;

  static bool showcaseShowing = false;

  @override
  Widget build(BuildContext context) {
    Icon? icon;

    return FutureBuilder<bool?>(
        future: getShowcaseStatus('categoryCardShowcaseComplete'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data == null || snapshot.data == false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              if (showcaseShowing == false) {
                await Future.delayed(const Duration(milliseconds: 400));
                ShowCaseWidget.of(buildContext!).startShowCase(
                    [_categoryCardShowcase, _iconPickerShowcaseKey]);
              }
            });
          }
          return ShowCaseWidget(onStart: (p0, p1) {
            setState(() {
              showcaseShowing = true;
            });
          }, onFinish: () async {
            setState(() {
              showcaseShowing = false;
            });
            // showcaseShowing = false;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('categoryCardShowcaseComplete', true);
          }, builder: Builder(
            builder: (context) {
              buildContext = context;
              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 6.0, 8.0, 6.0),
                child: SizedBox(
                  height: 125,
                  width: MediaQuery.of(context).size.width,
                  child: Showcase(
                    descriptionAlignment: TextAlign.center,
                    targetPadding: const EdgeInsets.all(4.0),
                    targetBorderRadius: BorderRadius.circular(24),
                    key: _categoryCardShowcase,
                    description: 'Great! Now, you can add places to this list.',
                    child: Card(
                      //color: FlexColor.deepBlueDarkPrimaryContainer.withOpacity(0.15),
                      child: Stack(
                        children: [
                          ListTile(
                            trailing: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8.0,
                              ),
                              child: PopupMenuButton(
                                  // elevation: 0,
                                  surfaceTintColor:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  position: PopupMenuPosition.under,
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey[800]
                                        : Colors.white,
                                  ),
                                  itemBuilder: (context) => <PopupMenuEntry>[
                                        PopupMenuItem(
                                          onTap: () => WidgetsBinding.instance
                                              .addPostFrameCallback(
                                                  (timeStamp) async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  EditListDialog(
                                                placeList: widget.placeList,
                                              ),
                                            );
                                          }),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.edit_note_rounded),
                                              SizedBox(
                                                width: 4.0,
                                              ),
                                              Text('Edit List'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (timeStamp) async {
                                              await showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return DeleteListDialog(
                                                    placeList: widget.placeList,
                                                  );
                                                },
                                              );
                                            });
                                          },
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  Icons.delete_forever_rounded),
                                              SizedBox(
                                                width: 4.0,
                                              ),
                                              Text('Delete List'),
                                            ],
                                          ),
                                        )
                                      ]),
                            ),
                            onTap: () {
                              context
                                  .read<SavedPlacesBloc>()
                                  .add(LoadPlaces(placeList: widget.placeList));
                              context.read<RandomWheelCubit>().resetWheel();
                              context.push('/home/placeList-page');
                            },
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 24.0),
                            minLeadingWidth: 20,
                            title: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                widget.placeList.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Wrap(
                                children: [
                                  FutureBuilder<int>(
                                      future: context
                                          .read<PlaceListRepository>()
                                          .getPlaceListItemCount(
                                              widget.placeList.placeListId!),
                                      builder: (context, snapshot) {
                                        var data = snapshot.data;

                                        return Wrap(
                                          children: [
                                            AnimatedCount(count: data ?? 0),
                                            const Text(' Places'),
                                          ],
                                        );
                                      }),
                                ],
                              ),
                            ),
                            leading:
                                BlocConsumer<PurchasesBloc, PurchasesState>(
                              listener: (context, state) {
                                if (state is PurchasesUpdated) {
                                  Navigator.pop(context);
                                }
                              },
                              builder: (context, state) {
                                if (state is PurchasesLoading) {
                                  return LoadingAnimationWidget
                                      .staggeredDotsWave(
                                          color:
                                              FlexColor.bahamaBlueDarkSecondary,
                                          size: 20.0);
                                }
                                if (state is PurchasesLoaded &&
                                    state.isSubscribed == false) {
                                  return InkWell(
                                    onTap: () async {
                                      // TODO: Create Paywall Restriction
                                      await showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) =>
                                            const PremiumOffer(),
                                      );
                                    },
                                    child: Showcase(
                                      key: _iconPickerShowcaseKey,
                                      description:
                                          'You can set a custom icon here!\n(Requires Premium)',
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Icon(
                                          deserializeIcon(
                                                  widget.placeList.icon) ??
                                              Icons.list_rounded,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          size: widget.placeList.icon
                                                  .containsValue(
                                                      'fontAwesomeIcons')
                                              ? 30
                                              : 36,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (state is PurchasesLoaded &&
                                    state.isSubscribed == true) {
                                  return InkWell(
                                    onTap: () async {
                                      // TODO: Create Paywall Restriction
                                      IconData? icon = await pickIcon(context);

                                      if (icon != null) {
                                        Map<String, dynamic>? serializedIcon =
                                            serializeIcon(icon);
                                        context.read<SavedListsBloc>().add(
                                            UpdateSavedLists(
                                                placeList: widget.placeList
                                                    .copyWith(
                                                        icon: serializedIcon)));
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                            'No Icon Selected!',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ));
                                      }
                                    },
                                    child: Showcase(
                                      descriptionAlignment: TextAlign.center,
                                      targetBorderRadius:
                                          BorderRadius.circular(16.0),
                                      targetPadding: const EdgeInsets.all(8.0),
                                      key: _iconPickerShowcaseKey,
                                      description:
                                          'You can set a custom icon here!',
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Icon(
                                          deserializeIcon(
                                                  widget.placeList.icon) ??
                                              Icons.list_rounded,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          size: widget.placeList.icon
                                                  .containsValue(
                                                      'fontAwesomeIcons')
                                              ? 30
                                              : 36,
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const Center(
                                    child: Text('Error!'),
                                  );
                                }
                              },
                            ),
                          ),
                          widget.placeList.listOwnerId !=
                                      context
                                          .read<ProfileBloc>()
                                          .state
                                          .user
                                          .id ||
                                  (widget.placeList.contributorIds != null &&
                                      widget
                                          .placeList.contributorIds!.isNotEmpty)
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
                ),
              );
            },
          ));
        });
  }
}
