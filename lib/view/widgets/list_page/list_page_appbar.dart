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
import 'package:leggo/view/widgets/premium_offer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CategoryPageAppBar extends StatefulWidget {
  const CategoryPageAppBar({
    Key? key,
    required this.contributors,
    required this.placeList,
    required this.scrollController,
    required this.listOwner,
  }) : super(key: key);

  final List<User>? contributors;

  final PlaceList placeList;
  final User listOwner;
  final ScrollController scrollController;

  @override
  State<CategoryPageAppBar> createState() => _CategoryPageAppBarState();
}

class _CategoryPageAppBarState extends State<CategoryPageAppBar> {
  EdgeInsets avatarStackPadding = const EdgeInsets.only(right: 4.0);

  @override
  void initState() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.addListener(
        () {
          if (widget.scrollController.offset > 65) {
            if (!mounted) return;
            setState(() {
              Platform.isIOS
                  ? avatarStackPadding =
                      const EdgeInsets.symmetric(horizontal: 28.0)
                  : avatarStackPadding = const EdgeInsets.only(right: 28.0);
            });
          } else if (widget.scrollController.hasClients &&
              widget.scrollController.offset < 65) {
            if (!mounted) return;
            setState(() {
              avatarStackPadding = const EdgeInsets.only(right: 4.0);
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
      expandedHeight: 125,
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
              : FlexColor.bahamaBlueLightPrimary),
      title: AnimatedPadding(
        curve: Curves.easeOutSine,
        duration: const Duration(milliseconds: 300),
        padding: avatarStackPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 4,
              child: FittedBox(
                child: Wrap(
                  spacing: 16.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Animate(
                        effects: const [
                          FadeEffect(),
                          SlideEffect(
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeOutSine,
                              begin: Offset(-1.0, 0),
                              end: Offset(0, 0))
                          // RotateEffect(
                          //     curve: Curves.easeOutBack,
                          //     duration: Duration(milliseconds: 500),
                          //     begin: -0.25,
                          //     end: 0.0,
                          //     alignment: Alignment.centerLeft)
                        ],
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0, left: 4.0),
                          child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Icon(
                                deserializeIcon(widget.placeList.icon) ??
                                    Icons.list_alt_rounded,
                                size: widget.placeList.icon
                                        .containsValue('fontAwesomeIcons')
                                    ? 28
                                    : 32,
                              )),
                        )),
                    Animate(
                      effects: const [
                        FadeEffect(),
                        RotateEffect(
                            curve: Curves.easeOutBack,
                            duration: Duration(milliseconds: 500),
                            begin: -0.25,
                            end: 0.0,
                            alignment: Alignment.centerLeft)
                      ],
                      child: Text(
                        widget.placeList.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Animate(
                effects: const [
                  FadeEffect(),
                  SlideEffect(
                      duration: Duration(milliseconds: 700),
                      curve: Curves.easeOutQuart,
                      begin: Offset(0.5, 0.0),
                      end: Offset(0.0, 0.0)),
                ],
                child: BlocConsumer<SavedPlacesBloc, SavedPlacesState>(
                  listener: (context, state) {
                    if (state is PurchasesUpdated) {
                      Navigator.pop(context);
                    }
                  },
                  builder: (context, state) {
                    if (state is SavedPlacesLoading) {
                      return LoadingAnimationWidget.beat(
                          color: FlexColor.bahamaBlueDarkSecondary, size: 18.0);
                    }
                    if (state is SavedPlacesLoaded) {
                      return AvatarStack(
                        settings: RestrictedPositions(
                            align: StackAlign.right, laying: StackLaying.first),
                        borderWidth: 2.0,
                        borderColor:
                            Theme.of(context).chipTheme.backgroundColor,
                        width: 70,
                        height: 40,
                        avatars: [
                          CachedNetworkImageProvider(
                              widget.listOwner.profilePicture!),
                          for (User user in state.contributors)
                            CachedNetworkImageProvider(user.profilePicture!),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text('Error Loading Avatars!'),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton(
            position: PopupMenuPosition.under,
            icon: Icon(
              Icons.more_vert_rounded,
              color: Theme.of(context).brightness == Brightness.light
                  ? FlexColor.bahamaBlueLightPrimary
                  : Colors.white,
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () => WidgetsBinding.instance
                        .addPostFrameCallback((timeStamp) async {
                      await showDialog(
                        context: context,
                        builder: (context) => EditListDialog(
                          placeList: widget.placeList,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
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
                              placeList: widget.placeList,
                            );
                          },
                        );
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.delete_forever_rounded),
                        SizedBox(
                          width: 4.0,
                        ),
                        Text('Delete List'),
                      ],
                    ),
                  )
                ]),
      ],
    );
  }
}
