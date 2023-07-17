import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
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
      bottomNavigationBar: MainBottomNavBar(),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return CustomScrollView(
              slivers: [
                const MainTopAppBar(),
                SliverFillRemaining(
                  child: LoadingAnimationWidget.inkDrop(
                      color: Theme.of(context).primaryIconTheme.color!,
                      size: 30.0),
                )
              ],
            );
          }
          if (state is ProfileLoaded) {
            return CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                const MainTopAppBar(),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40.0),
                ),
                SliverToBoxAdapter(
                  child: Center(
                      child: CachedNetworkImage(
                    placeholder: (context, url) => CircleAvatar(
                      radius: 50,
                      child: LoadingAnimationWidget.staggeredDotsWave(
                          color: FlexColor.bahamaBlueDarkSecondary, size: 30.0),
                    ),
                    imageUrl: state.user.profilePicture!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? FlexColor.bahamaBlueLightPrimaryContainer
                              : FlexColor.bahamaBlueDarkPrimaryContainer,
                      radius: 54,
                      child: CircleAvatar(
                        foregroundImage: imageProvider,
                        radius: 50,
                      ),
                    ),
                  )),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Column(
                        children: [
                          Text(
                            state.user.name!,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text('@${state.user.userName!}'),
                        ],
                      )),
                ),
                SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 8.0),
                    child: FractionallySizedBox(
                      heightFactor: 0.9,
                      widthFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Your Lists & Places',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    children: [
                                      Icon(
                                        Icons.list_alt_rounded,
                                        size: 40,
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Text('Lists')
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        state.user.placeListIds?.length
                                                .toString() ??
                                            '0',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      const Text('Lists')
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        context
                                            .read<SavedListsBloc>()
                                            .myPlaceLists
                                            .where((element) =>
                                                element.contributorIds !=
                                                    null &&
                                                element
                                                    .contributorIds!.isNotEmpty)
                                            .length
                                            .toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      const Text(
                                        'Shared',
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        height: 4.0,
                                      ),
                                      Text('Places')
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      FutureBuilder(
                                          future: context
                                              .read<PlaceListRepository>()
                                              .getSavedPlacesTotalCount(
                                                  state.user),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;
                                            if (data is int) {
                                              return Text(
                                                data.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              );
                                            } else {
                                              return SizedBox(
                                                height: 28,
                                                child: LoadingAnimationWidget
                                                    .staggeredDotsWave(
                                                        color: FlexColor
                                                            .bahamaBlueDarkSecondary,
                                                        size: 16.0),
                                              );
                                            }
                                          }),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      const Text(
                                        'Not Visited',
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      FutureBuilder(
                                          future: context
                                              .read<PlaceListRepository>()
                                              .getVisitedPlacesTotalCount(
                                                  state.user),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;
                                            if (data is int) {
                                              return Text(
                                                data.toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge,
                                              );
                                            } else {
                                              return SizedBox(
                                                height: 28,
                                                child: LoadingAnimationWidget
                                                    .staggeredDotsWave(
                                                        color: FlexColor
                                                            .bahamaBlueDarkSecondary,
                                                        size: 16.0),
                                              );
                                            }
                                          }),
                                      const SizedBox(
                                        height: 4.0,
                                      ),
                                      const Text(
                                        'Visited',
                                        textAlign: TextAlign.center,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is ProfileFailed) {
            return const CustomScrollView(
              slivers: [
                MainTopAppBar(),
                SliverFillRemaining(child: Text('Failed to Load Profile..'))
              ],
            );
          }
          return const CustomScrollView(
            slivers: [
              MainTopAppBar(),
              SliverFillRemaining(child: Text('Something Went Wrong...'))
            ],
          );
        },
      ),
    );
  }
}
