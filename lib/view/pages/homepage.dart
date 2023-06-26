import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/lists/blank_category_card.dart';
import 'package:leggo/view/widgets/lists/category_card.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';
import 'package:leggo/view/widgets/lists/sample_category_card.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../consts.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final GlobalKey _createListShowcaseKey = GlobalKey();
  final GlobalKey _createListButtonKey = GlobalKey();
  final ScrollController mainScrollController = ScrollController();
  BuildContext? buildContext;
  List<Widget> rows = [];
  @override
  void initState() {
    for (PlaceList placeList in samplePlaceLists!) {
      rows.add(SampleCategoryCard(placeList: placeList));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
        future: getShowcaseStatus('createListShowcaseComplete'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data == null || snapshot.data == false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              if (ShowCaseWidget.of(context).activeWidgetId == null) {
                await Future.delayed(
                  const Duration(seconds: 0),
                  () => ShowCaseWidget.of(buildContext!).startShowCase(
                      [_createListShowcaseKey, _createListButtonKey]),
                );
              }
            });
          }
          return ShowCaseWidget(
            onFinish: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('createListShowcaseComplete', true);
            },
            builder: Builder(
              builder: (context) {
                buildContext = context;
                return Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.endDocked,
                  bottomNavigationBar: MainBottomNavBar(),
                  body: BlocBuilder<SavedListsBloc, SavedListsState>(
                    builder: (context, state) {
                      // rows.insert(
                      //     0,
                      //     Showcase(
                      //       descriptionAlignment: TextAlign.center,
                      //       targetShapeBorder: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(50.0)),
                      //       key: _createListShowcaseKey,
                      //       description:
                      //           'Create lists for different categories, locations, etc.',
                      //       child: Animate(
                      //           effects: const [SlideEffect()],
                      //           child: const BlankCategoryCard()),
                      //     ));
                      // if (state is SavedListsLoading ||
                      //     state is SavedListsInitial ||
                      //     state is SavedListsUpdated) {

                      //   return CustomScrollView(
                      //     controller: mainScrollController,
                      //     slivers: [
                      //       const MainTopAppBar(),
                      //       // Main List View
                      //       SliverList(
                      //         delegate: SliverChildBuilderDelegate(
                      //             childCount: rows.length, (context, index) {
                      //           return rows[index];
                      //         }),
                      //       )
                      //     ],
                      //   );
                      // }
                      if (state is SavedListsFailed) {
                        return const Center(
                          child: Text('Error Loading Lists!'),
                        );
                      }
                      if (state is SavedListsLoaded ||
                          state is SavedListsLoading ||
                          state is SavedListsInitial ||
                          state is SavedListsUpdated) {
                        if (context.read<ProfileBloc>().state
                                is ProfileIncomplete &&
                            ModalRoute.of(context)!.isCurrent) {
                          WidgetsBinding.instance
                              .addPostFrameCallback((timeStamp) async {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                isDismissible: false,
                                enableDrag: false,
                                context: context,
                                builder: (context) =>
                                    const IncompleteProfileDialog());
                          });
                        }

                        return StreamBuilder<List<PlaceList>>(
                            stream: context
                                .read<SavedListsBloc>()
                                .state
                                .placeListsStream,
                            builder: (context, snapshot) {
                              var data = snapshot.data;
                              var placeLists = [];
                              // for (PlaceList placeList in samplePlaceLists) {
                              //   rows.add(Animate(
                              //       onComplete: (controller) =>
                              //           controller.repeat(),
                              //       effects: const [
                              //         ShimmerEffect(
                              //           duration: Duration(milliseconds: 400),
                              //         )
                              //       ],
                              //       child: SampleCategoryCard(
                              //           placeList: placeList)));
                              // }
                              // if (data == null) {
                              //   return CustomScrollView(
                              //     slivers: [
                              //       const MainTopAppBar(),
                              //       SliverList(
                              //           delegate: SliverChildListDelegate(rows
                              //               .animate(interval: 100.ms)
                              //               .slideX(
                              //                   curve: Curves.easeOutSine,
                              //                   begin: 1.0,
                              //                   duration: 400.ms)))
                              //     ],
                              //   );
                              // }
                              if (snapshot.hasData && data != null) {
                                placeLists = data;

                                if (placeLists.isNotEmpty) {
                                  // rows.clear();
                                  List<CategoryCard> categoryCards = [
                                    for (PlaceList placeList in placeLists)
                                      CategoryCard(placeList: placeList)
                                  ];
                                  if (rows != categoryCards) {
                                    rows.clear();
                                    if (placeLists.length < 5) {
                                      for (int i = 0;
                                          i < 5 - placeLists.length;
                                          i++) {
                                        rows.add(
                                          SampleCategoryCard(
                                              placeList: samplePlaceLists![i]),
                                        );
                                      }
                                    }
                                    rows.insertAll(0, categoryCards);
                                  }
                                  // rows.insertAll(0, categoryCards);
                                  // if (placeLists.length < 5) {
                                  //   for (int i = 0;
                                  //       i < 5 - placeLists.length;
                                  //       i++) {
                                  //     rows.add(SampleCategoryCard(
                                  //         placeList: samplePlaceLists[i]));
                                  //   }
                                  // }
                                }
                              }
                              if (placeLists.isEmpty &&
                                  rows[0] is! BlankCategoryCard) {
                                rows.clear();
                                for (PlaceList placeList in samplePlaceLists!) {
                                  rows.add(
                                      SampleCategoryCard(placeList: placeList));
                                }
                                rows.insert(0, const BlankCategoryCard());
                              }
                              // else {
                              //   //rows.clear();
                              //   for (PlaceList placeList
                              //       in samplePlaceLists) {
                              //     rows.add(SampleCategoryCard(
                              //         placeList: placeList));
                              //   }
                              //   rows.insert(
                              //       0,
                              //       Showcase(
                              //         descriptionAlignment: TextAlign.center,
                              //         targetShapeBorder:
                              //             RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(
                              //                         50.0)),
                              //         key: _createListShowcaseKey,
                              //         description:
                              //             'Create lists for different categories, locations, etc.',
                              //         child: const BlankCategoryCard(),
                              //       ));
                              // }
                              return CustomScrollView(
                                //cacheExtent: 1500,
                                controller: mainScrollController,
                                slivers: [
                                  const MainTopAppBar(),
                                  // Main List View
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 12.0),
                                  ),
                                  SliverList(
                                      delegate: SliverChildListDelegate(
                                    rows
                                        .animate(
                                          interval: 100.ms,
                                        )
                                        .slideY(
                                            curve: Curves.easeOutSine,
                                            begin: -1.0,
                                            duration: 400.ms)
                                        .fadeIn(
                                          //delay: 100.ms,
                                          curve: Curves.easeOutSine,
                                          //  duration: 600.ms,
                                        ),
                                  )
                                      // SliverChildBuilderDelegate(
                                      //     childCount: rows.length,
                                      //     (context, index) {
                                      //   return rows[index];
                                      // }),
                                      )
                                ],
                              );
                              //  else {
                              //   return const Center(
                              //     child: Text('Something Went Wrong...'),
                              //   );
                              // }
                            });
                      } else {
                        return const Center(
                          child: Text('Something Went Wrong...'),
                        );
                      }
                    },
                  ),
                  floatingActionButton: Showcase(
                    targetPadding: const EdgeInsets.all(8.0),
                    targetBorderRadius: BorderRadius.circular(50),
                    key: _createListButtonKey,
                    description:
                        'You can use this button to create a list too!',
                    child: FloatingActionButton(
                      shape: const StadiumBorder(),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return const CreateListDialog();
                          },
                        );
                      },
                      tooltip: 'Increment',
                      child: const Icon(Icons.post_add_outlined),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

class IncompleteProfileDialog extends StatefulWidget {
  const IncompleteProfileDialog({super.key});

  @override
  State<IncompleteProfileDialog> createState() =>
      _IncompleteProfileDialogState();
}

class _IncompleteProfileDialogState extends State<IncompleteProfileDialog> {
  var maxLength = 15;
  var textLength = 0;
  var userNameFieldController = TextEditingController();

  final GlobalKey<FormState> resetProfileFormKey = GlobalKey<FormState>();
  final TextEditingController nameFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var user = context.watch<ProfileBloc>().state.user;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.7,
          initialChildSize: 0.7,
          maxChildSize: 1.0,
          builder: (context, controller) {
            return BottomSheet(
                enableDrag: false,
                onClosing: () {},
                builder: (context) {
                  return Form(
                    key: resetProfileFormKey,
                    child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Whoops!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'We had some serious bugs & are incredibly sorry for the inconvenience. We have fixed them now, but we need you to set your missing profile information.\n\nWe promise it will be worth it! 😊',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                ResetProfilePhotoAvatar(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp('[ ]'),
                                ),
                                LowerCaseTextFormatter(),
                              ],
                              validator: (value) {
                                if (value!.length < 3) {
                                  return 'Must be 3 characters or more.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              maxLength: 15,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: userNameFieldController,
                              onChanged: (value) {
                                setState(() {
                                  textLength = value.length;
                                });
                              },
                              decoration: InputDecoration(
                                suffixText:
                                    '${textLength.toString()}/${maxLength.toString()}',
                                suffixStyle:
                                    Theme.of(context).textTheme.bodySmall,
                                counterText: "",
                                prefix: const Text('@'),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 24.0),
                                label: const Text('Username'),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context)
                                            .inputDecorationTheme
                                            .enabledBorder!
                                            .borderSide
                                            .color)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        width: 2.0, color: Colors.redAccent)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        width: 2.0, color: Colors.redAccent)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context)
                                            .inputDecorationTheme
                                            .enabledBorder!
                                            .borderSide
                                            .color)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: TextFormField(
                              // autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 24.0),
                                label: const Text('Name'),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context)
                                            .inputDecorationTheme
                                            .enabledBorder!
                                            .borderSide
                                            .color)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        width: 2.0, color: Colors.redAccent)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: const BorderSide(
                                        width: 2.0, color: Colors.redAccent)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context)
                                            .inputDecorationTheme
                                            .enabledBorder!
                                            .borderSide
                                            .color)),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                // Check if user provided a first and last name
                                if (value.split(' ').length < 2) {
                                  return 'Please enter your first & last name';
                                }
                                return null;
                              },
                              controller: nameFieldController,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 8.0, top: 4.0, left: 48.0, right: 48.0),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(100, 40)),
                                onPressed: () async {
                                  if (resetProfileFormKey.currentState!
                                          .validate() &&
                                      context
                                              .read<ProfileBloc>()
                                              .state
                                              .user
                                              .profilePicture !=
                                          '') {
                                    context.read<ProfileBloc>().add(
                                          UpdateProfile(
                                              user: context
                                                  .read<ProfileBloc>()
                                                  .state
                                                  .user
                                                  .copyWith(
                                                    name: nameFieldController
                                                        .text,
                                                    userName:
                                                        userNameFieldController
                                                            .text,
                                                  )),
                                        );
                                    await Future.delayed(
                                        const Duration(seconds: 1), () {
                                      Navigator.pop(context);
                                    });
                                  } else {
                                    if (context
                                            .read<ProfileBloc>()
                                            .state
                                            .user
                                            .profilePicture ==
                                        '') {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Please select a profile picture!',
                                          textColor: Colors.white,
                                          backgroundColor: Colors.redAccent);
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(const SnackBar(
                                      //   content: Text(
                                      //     'Please select a profile picture!',
                                      //     style: TextStyle(color: Colors.white),
                                      //   ),
                                      //   backgroundColor: Colors.redAccent,
                                      // ));
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: 'Please fill out all fields!',
                                          textColor: Colors.white,
                                          backgroundColor: Colors.redAccent);
                                    }
                                  }
                                },
                                child: context.watch<ProfileBloc>().state
                                            is ProfileLoaded &&
                                        (user.name != '' &&
                                            user.userName != '' &&
                                            user.profilePicture != '')
                                    ? Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          ).animate().rotate(),
                                          const Text('Updated!'),
                                        ],
                                      )
                                    : const Text('Update')),
                          ),
                        ]),
                  );
                });
          }),
    );
  }
}

Future<void> resetUserProfilePicture(BuildContext context) async {
  ImagePicker picker = ImagePicker();
  final XFile? image;

  image = await picker.pickImage(source: ImageSource.gallery);
  if (image == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No Image was selected!')));
  }

  if (image != null) {
    context.read<ProfileBloc>().add(UpdateProfilePicture(
        user: context.read<ProfileBloc>().state.user, image: image));
  }
}

class ResetProfilePhotoAvatar extends StatelessWidget {
  const ResetProfilePhotoAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.white,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              var profilePicture =
                  context.watch<ProfileBloc>().state.user.profilePicture;
              if ((state is ProfileLoaded || state is ProfileIncomplete) &&
                  profilePicture == '') {
                return InkWell(
                  onTap: () async => await resetUserProfilePicture(context),
                  child: CircleAvatar(
                      radius: 40,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Add a Photo!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                        ),
                      )),
                );
              }
              if (state is ProfileLoading) {
                return CircleAvatar(
                  radius: 40.0,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: FlexColor.bahamaBlueDarkSecondary, size: 30.0),
                );
              }
              if ((state is ProfileLoaded || state is ProfileIncomplete) &&
                  profilePicture != '') {
                return InkWell(
                  onTap: () async => await resetUserProfilePicture(context),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircleAvatar(
                      radius: 40,
                      child: LoadingAnimationWidget.staggeredDotsWave(
                          color: FlexColor.bahamaBlueDarkSecondary, size: 30.0),
                    ),
                    imageUrl: profilePicture!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      foregroundImage: imageProvider,
                      radius: 40,
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('Something Went Wrong...'),
                );
              }
            },
          ),
        ),
        Positioned(
          right: -8,
          bottom: -4,
          child: IconButton(
            onPressed: () async {
              await resetUserProfilePicture(context);
            },
            icon: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.white),
              child: const Icon(
                Icons.add_circle_rounded,
                color: FlexColor.bahamaBlueDarkSecondaryContainer,
              ),
            ),
          ),
        )
      ],
    );
  }
}
