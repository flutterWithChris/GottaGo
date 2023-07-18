import 'dart:io';

import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/view/widgets/list_page/dialogs.dart';
import 'package:leggo/view/widgets/lists/delete_list_dialog.dart';
import 'package:leggo/view/widgets/lists/invite_dialog.dart';
import 'package:leggo/view/widgets/premium_offer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CategoryPageAppBar extends StatefulWidget {
  const CategoryPageAppBar({
    Key? key,
    this.contributors,
    this.placeList,
    required this.scrollController,
    this.listOwner,
  }) : super(key: key);

  final List<User>? contributors;
  final PlaceList? placeList;
  final User? listOwner;
  final ScrollController scrollController;

  @override
  State<CategoryPageAppBar> createState() => _CategoryPageAppBarState();
}

class _CategoryPageAppBarState extends State<CategoryPageAppBar> {
  EdgeInsets avatarStackPadding = const EdgeInsets.only(right: 0.0);
  EdgeInsets iconPadding = const EdgeInsets.only(right: 4.0, left: 4.0);

  @override
  void initState() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.addListener(
        () {
          if (widget.scrollController.offset > 65) {
            if (!mounted) return;
            setState(() {
              Platform.isIOS
                  ? iconPadding = const EdgeInsets.only(left: 24.0)
                  : iconPadding = const EdgeInsets.only(left: 30.0);
            });
          } else if (widget.scrollController.hasClients &&
              widget.scrollController.offset < 65) {
            if (!mounted) return;
            setState(() {
              iconPadding = const EdgeInsets.only(right: 4.0, left: 4.0);
            });
          }
        },
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      leadingWidth: 50,
      expandedHeight: 120,
      // leading: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //   child: IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Icons.menu),
      //   ),
      // ),

      actionsIconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey[800]),
      title: AnimatedPadding(
        curve: Curves.easeOutSine,
        duration: const Duration(milliseconds: 300),
        padding: avatarStackPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BlocBuilder<SavedPlacesBloc, SavedPlacesState>(
              builder: (context, state) {
                if (state is SavedPlacesLoading) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: LoadingAnimationWidget.beat(
                        color: FlexColor.bahamaBlueDarkSecondary, size: 20.0),
                  );
                }
                if (state is SavedPlacesLoaded) {
                  return Flexible(
                    flex: 4,
                    child: FittedBox(
                      child: Wrap(
                        spacing: 16.0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AnimatedPadding(
                            duration: const Duration(milliseconds: 300),
                            padding: iconPadding,
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: context
                                          .watch<SavedPlacesBloc>()
                                          .state
                                          .placeList
                                          ?.icon !=
                                      null
                                  ? Icon(
                                      deserializeIcon(context
                                              .read<SavedPlacesBloc>()
                                              .state
                                              .placeList!
                                              .icon) ??
                                          Icons.list_alt_rounded,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey[800],
                                      size: context
                                              .read<SavedPlacesBloc>()
                                              .state
                                              .placeList!
                                              .icon
                                              .containsValue('fontAwesomeIcons')
                                          ? 28
                                          : 32,
                                    )
                                  : const Icon(
                                      Icons.list_alt_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                          ),
                          context
                                      .watch<SavedPlacesBloc>()
                                      .state
                                      .placeList
                                      ?.name !=
                                  null
                              ? Text(
                                  context
                                      .read<SavedPlacesBloc>()
                                      .state
                                      .placeList!
                                      .name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ).animate().fadeIn().rotate(
                            curve: Curves.easeOutBack,
                            duration: const Duration(milliseconds: 500),
                            begin: -0.25,
                            end: 0.0,
                            alignment: Alignment.centerLeft,
                          ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            Flexible(
              child: BlocConsumer<SavedPlacesBloc, SavedPlacesState>(
                listener: (context, state) {
                  if (state is PurchasesUpdated) {
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  if (state is SavedPlacesLoading) {
                    return const SizedBox();
                  }
                  if (state is SavedPlacesLoaded) {
                    return AvatarStack(
                      infoWidgetBuilder: (surplus) {
                        return Text(
                          '+$surplus',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(0.5)),
                        );
                      },
                      settings: RestrictedPositions(
                          align: StackAlign.right, laying: StackLaying.first),
                      borderWidth: 2.0,
                      borderColor: Theme.of(context).chipTheme.backgroundColor,
                      width: 70,
                      height: 40,
                      avatars: [
                        CachedNetworkImageProvider(
                            state.listOwner.profilePicture!),
                        for (User user in state.contributors)
                          CachedNetworkImageProvider(user.profilePicture!),
                      ],
                    ).animate().fadeIn().slideX(
                          curve: Curves.easeOutSine,
                          duration: const Duration(milliseconds: 400),
                          begin: 0.5,
                          end: 0.0,
                        );
                  } else {
                    return const Center(
                      child: Text('Error Loading Avatars!'),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: PopupMenuButton(
              padding: const EdgeInsets.only(left: 0),
              position: PopupMenuPosition.under,
              icon: Icon(
                Icons.more_vert_rounded,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey[800]
                    : Colors.white,
              ),
              itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      onTap: () => WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        await showDialog(
                          context: context,
                          builder: (context) => EditListDialog(
                            placeList: widget.placeList!,
                          ),
                        ).then((value) async {
                          if (value == true) {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => const PremiumOffer(),
                            );
                          }
                        });
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
                            .addPostFrameCallback((timeStamp) async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return DeleteListDialog(
                                placeList: widget.placeList!,
                              );
                            },
                          );
                        });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_forever_rounded),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text('Delete List'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_add_rounded),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text('Invite Friend'),
                        ],
                      ),
                      onTap: () {
                        if (context.read<PurchasesBloc>().state.isSubscribed ==
                            true) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) async {
                            await showDialog(
                              useRootNavigator: false,
                              context: context,
                              builder: (dialogContext) {
                                return InviteDialog(
                                    placeList: context
                                        .read<SavedPlacesBloc>()
                                        .state
                                        .placeList!,
                                    dialogContext: dialogContext);
                              },
                            );
                          });
                        } else {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) async {
                            await showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) {
                                return const PremiumOffer();
                              },
                            );
                          });
                        }
                      },
                    ),
                  ]),
        ),
      ],
    );
  }
}
