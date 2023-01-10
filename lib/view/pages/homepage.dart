import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/lists/blank_category_card.dart';
import 'package:leggo/view/widgets/lists/category_card.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../widgets/lists/sample_category_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _createListShowcaseKey = GlobalKey();
  final GlobalKey _createListButtonKey = GlobalKey();
  final ScrollController mainScrollController = ScrollController();
  BuildContext? buildContext;
  List<Widget> rows = [];

  @override
  Widget build(BuildContext context) {
    List<PlaceList>? samplePlaceLists = [
      PlaceList(
          name: 'Breakfast Ideas',
          listOwnerId: '12345',
          placeCount: 5,
          contributorIds: [],
          icon: {'pack': 'material', 'key': 'egg_alt_outlined'}),
      PlaceList(
          name: 'Iceland Trip',
          listOwnerId: '12345',
          placeCount: 12,
          contributorIds: [],
          icon: {'pack': 'fontAwesomeIcons', 'key': 'earthAmericas'}),
      PlaceList(
          name: 'Lunch Spots',
          listOwnerId: '12345',
          placeCount: 7,
          contributorIds: [],
          icon: {'pack': 'fontAwesomeIcons', 'key': 'bowlFood'}),
      PlaceList(
          name: 'Experiences',
          listOwnerId: '12345',
          placeCount: 9,
          contributorIds: [],
          icon: {'pack': 'material', 'key': 'airplane_ticket_rounded'}),
      PlaceList(
        name: 'Local Spots',
        listOwnerId: '12345',
        placeCount: 10,
        contributorIds: [],
        icon: {'pack': 'material', 'key': 'local_dining'},
      ),
    ];
    return FutureBuilder<bool?>(
        future: getShowcaseStatus('createListShowcaseComplete'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              (snapshot.data == null || snapshot.data == false)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
              await Future.delayed(
                const Duration(seconds: 0),
                () => ShowCaseWidget.of(buildContext!).startShowCase(
                    [_createListShowcaseKey, _createListButtonKey]),
              );
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
                      if (state is SavedListsLoading ||
                          state is SavedListsInitial ||
                          state is SavedListsUpdated) {
                        return CustomScrollView(
                          controller: mainScrollController,
                          slivers: [
                            const MainTopAppBar(),
                            // Main List View
                            SliverFillRemaining(
                              child: Center(
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                    color: FlexColor.materialDarkPrimaryHc,
                                    size: 40.0),
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is SavedListsFailed) {
                        return const Center(
                          child: Text('Error Loading Lists!'),
                        );
                      }
                      if (state is SavedListsLoaded) {
                        void _onReorder(int oldIndex, int newIndex) {
                          PlaceList placeList =
                              state.placeLists!.removeAt(oldIndex);
                          state.placeLists!.insert(newIndex, placeList);
                          if (!mounted) return;
                          setState(() {
                            Widget row = rows.removeAt(oldIndex);
                            rows.insert(newIndex, row);
                          });
                        }

                        void _onReorderSampleItem(int oldIndex, int newIndex) {
                          PlaceList placeList =
                              samplePlaceLists.removeAt(oldIndex);
                          samplePlaceLists.insert(newIndex, placeList);
                          setState(() {
                            Widget row = rows.removeAt(oldIndex);
                            rows.insert(newIndex, row);
                          });
                        }

                        var placeLists =
                            context.watch<SavedListsBloc>().myPlaceLists;
                        if (placeLists.isNotEmpty) {
                          rows.clear();
                          rows = [
                            for (PlaceList placeList in placeLists)
                              Animate(
                                  effects: const [SlideEffect()],
                                  child: CategoryCard(placeList: placeList))
                          ];
                          if (placeLists.length < 5) {
                            for (int i = 0; i < 5 - placeLists.length; i++) {
                              rows.add(Animate(
                                  effects: const [SlideEffect()],
                                  child: SampleCategoryCard(
                                      placeList: samplePlaceLists[i])));
                            }
                          }
                        } else {
                          rows.clear();
                          for (PlaceList placeList in samplePlaceLists) {
                            rows.add(Animate(
                                effects: const [SlideEffect()],
                                child:
                                    SampleCategoryCard(placeList: placeList)));
                          }
                          rows.insert(
                              0,
                              Showcase(
                                descriptionAlignment: TextAlign.center,
                                targetShapeBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                key: _createListShowcaseKey,
                                description:
                                    'Create lists for different categories, locations, etc.',
                                child: Animate(
                                    effects: const [SlideEffect()],
                                    child: const BlankCategoryCard()),
                              ));
                        }

                        return CustomScrollView(
                          controller: mainScrollController,
                          slivers: [
                            const MainTopAppBar(),
                            // Main List View
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 12.0),
                            ),
                            ReorderableSliverList(
                                enabled: false,
                                delegate: ReorderableSliverChildBuilderDelegate(
                                    childCount: rows.length, (context, index) {
                                  return rows[index];
                                }),
                                onReorder: _onReorderSampleItem)
                          ],
                        );
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
