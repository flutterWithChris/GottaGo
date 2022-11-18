import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leggo/bloc/autocomplete/bloc/autocomplete_bloc.dart';
import 'package:leggo/bloc/bloc/auth/bloc/auth_bloc.dart';
import 'package:leggo/bloc/bloc/invite/bloc/invite_bloc.dart';
import 'package:leggo/bloc/bloc/invite_inbox/invite_inbox_bloc.dart';
import 'package:leggo/bloc/onboarding/bloc/onboarding_bloc.dart';

import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/category_page.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/cubit/cubit/signup/sign_up_cubit.dart';
import 'package:leggo/firebase_options.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/login.dart';
import 'package:leggo/model/invite.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/random_wheel_page.dart';
import 'package:leggo/repository/auth_repository.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:leggo/repository/invite_repository.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/places_repository.dart';
import 'package:leggo/repository/storage/storage_repository.dart';
import 'package:leggo/repository/user_repository.dart';
import 'package:leggo/signup.dart';
import 'package:leggo/widgets/lists/blank_category_card.dart';
import 'package:leggo/widgets/lists/category_card.dart';
import 'package:leggo/widgets/lists/create_list_dialog.dart';
import 'package:leggo/widgets/main_bottom_navbar.dart';
import 'package:leggo/widgets/lists/sample_category_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:reorderables/reorderables.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/place/place_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // * Force onboarding pref
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('initScreen', 0);
  await Future.wait([
    dotenv.load(fileName: '.env'),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthBloc bloc;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider(
          create: (context) => PlaceListRepository(),
        ),
        RepositoryProvider(
          create: (context) => PlacesRepository(),
        ),
        RepositoryProvider(
          create: (context) => DatabaseRepository(),
        ),
        RepositoryProvider(
          create: (context) => StorageRepository(),
        ),
        RepositoryProvider(
          create: (context) => InviteRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
                userRepository: context.read<UserRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                SignUpCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => OnboardingBloc(
                databaseRepository: context.read<DatabaseRepository>(),
                storageRepository: context.read<StorageRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                LoginCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => InviteInboxBloc(
                inviteRepository: context.read<InviteRepository>())
              ..add(LoadInvites()),
          ),
          BlocProvider(
            create: (context) => SavedListsBloc(
                placeListRepository: context.read<PlaceListRepository>())
              ..add(LoadSavedLists()),
          ),
          BlocProvider(
            create: (context) => InviteBloc(
                placeListRepository: context.read<PlaceListRepository>()),
          ),
          BlocProvider(
            create: (context) => SavedPlacesBloc(
                savedListsBloc: context.read<SavedListsBloc>(),
                placeListRepository: context.read<PlaceListRepository>()),
          ),
          BlocProvider(
            create: (context) => RandomWheelCubit(),
          ),
          BlocProvider(
            create: (context) => ViewPlaceCubit(),
          ),
          BlocProvider(
            create: (context) => AutocompleteBloc(
                placesRepository: context.read<PlacesRepository>())
              ..add(const LoadAutocomplete()),
          ),
          BlocProvider(
            create: (context) =>
                PlaceBloc(placesRepository: context.read<PlacesRepository>()),
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            bloc = context.read<AuthBloc>();
            return MaterialApp.router(
              scaffoldMessengerKey: snackbarKey,
              theme: FlexThemeData.light(
                fontFamily: GoogleFonts.archivo().fontFamily,
                scheme: FlexScheme.bahamaBlue,
                surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
                blendLevel: 20,
                appBarOpacity: 0.95,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 20,
                  blendOnColors: false,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
              ),
              darkTheme: FlexThemeData.dark(
                fontFamily: GoogleFonts.archivo().fontFamily,
                scheme: FlexScheme.bahamaBlue,
                surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
                blendLevel: 15,
                appBarOpacity: 0.90,
                subThemesData: const FlexSubThemesData(
                  blendOnLevel: 30,
                ),
                visualDensity: FlexColorScheme.comfortablePlatformDensity,
                useMaterial3: true,
              ),
              themeMode: ThemeMode.system,
              routeInformationParser: router.routeInformationParser,
              routeInformationProvider: router.routeInformationProvider,
              routerDelegate: router.routerDelegate,
              title: 'Flutter Demo',
            );
          },
        ),
      ),
    );
  }

  late final router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(bloc.stream),
      redirect: (context, state) async {
        bool loggedIn =
            context.read<AuthBloc>().state.status == AuthStatus.authenticated;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? initScreen = prefs.getInt("initScreen");
        bool isLoggingIn = state.location == '/login';
        bool isOnboarding = state.location == '/signup';
        bool completedOnboarding = initScreen == 1;

        if (!loggedIn) {
          return isLoggingIn
              ? completedOnboarding
                  ? null
                  : '/signup'
              : isOnboarding
                  ? null
                  : '/login';
        }

        final isLoggedIn = state.location == '/';

        if (loggedIn && isLoggingIn) return isLoggedIn ? null : '/';

        return null;
      },
      routes: [
        GoRoute(
          name: 'signup',
          path: '/signup',
          builder: (context, state) => const SignUp(),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              const MaterialPage<void>(child: LoginPage()),
        ),
        GoRoute(
            name: '/',
            path: '/',
            pageBuilder: (context, state) => const MaterialPage<void>(
                    child: MyHomePage(
                  title: 'Leggo',
                )),
            routes: [
              GoRoute(
                  path: 'home/placeList-page',
                  pageBuilder: (context, state) =>
                      const MaterialPage<void>(child: CategoryPage()),
                  routes: [
                    GoRoute(
                      name: 'random-wheel',
                      path: 'home/placeList-page/random-wheel',
                      pageBuilder: (context, state) =>
                          const MaterialPage<void>(child: RandomWheelPage()),
                    )
                  ])
            ]),
      ]);
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> rows = [];
  @override
  Widget build(BuildContext context) {
    List<PlaceList>? samplePlaceLists = [
      PlaceList(
          name: 'Breakfast Ideas',
          listOwnerId: '12345',
          placeCount: 5,
          contributorIds: []),
      PlaceList(
          name: 'Iceland Trip',
          listOwnerId: '12345',
          placeCount: 12,
          contributorIds: []),
      PlaceList(
          name: 'Lunch Spots',
          listOwnerId: '12345',
          placeCount: 7,
          contributorIds: []),
      PlaceList(
          name: 'Experiences',
          listOwnerId: '12345',
          placeCount: 9,
          contributorIds: []),
      PlaceList(
          name: 'Local Spots',
          listOwnerId: '12345',
          placeCount: 10,
          contributorIds: []),
    ];
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: const MainBottomNavBar(),
        body: BlocBuilder<SavedListsBloc, SavedListsState>(
          builder: (context, state) {
            if (state is SavedListsLoading || state is SavedListsUpdated) {
              return Center(
                child: LoadingAnimationWidget.inkDrop(
                    color: FlexColor.materialDarkPrimaryHc, size: 40.0),
              );
            }
            if (state is SavedListsFailed) {
              return const Center(
                child: Text('Error Loading Lists!'),
              );
            }
            if (state is SavedListsLoaded) {
              final ScrollController mainScrollController = ScrollController();

              void addCategoriesToList() {
                for (PlaceList placeList in state.placeLists!) {
                  rows.add(CategoryCard(placeList: placeList));
                }
              }

              if (state.placeLists!.isNotEmpty) {
                addCategoriesToList();
              }

              void _onReorder(int oldIndex, int newIndex) {
                PlaceList placeList = state.placeLists!.removeAt(oldIndex);
                state.placeLists!.insert(newIndex, placeList);
                setState(() {
                  Widget row = rows.removeAt(oldIndex);
                  rows.insert(newIndex, row);
                });
              }

              void _onReorderSampleItem(int oldIndex, int newIndex) {
                PlaceList placeList = samplePlaceLists.removeAt(oldIndex);
                samplePlaceLists.insert(newIndex, placeList);
                setState(() {
                  Widget row = rows.removeAt(oldIndex);
                  rows.insert(newIndex, row);
                });
              }

              return CustomScrollView(
                controller: mainScrollController,
                slivers: [
                  SliverAppBar.medium(
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu),
                      ),
                    ),
                    title: Wrap(
                      spacing: 18.0,
                      children: const [
                        Icon(FontAwesomeIcons.buildingCircleCheck),
                        Text(
                          'GottaGo',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    expandedHeight: 120,
                    actions: [
                      const InboxButton(),
                      // IconButton(
                      //     onPressed: () {}, icon: const Icon(Icons.more_vert)),
                      IconButton(
                          onPressed: () {
                            context.read<LoginCubit>().logout();
                          },
                          icon: const Icon(Icons.logout_rounded)),
                    ],
                  ),
                  // Main List View
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 12.0),
                  ),
                  ReorderableSliverList(
                      enabled: false,
                      delegate: ReorderableSliverChildBuilderDelegate(
                          childCount: state.placeLists!.isNotEmpty
                              ? state.placeLists!.length
                              : 6, (context, index) {
                        if (state.placeLists!.isNotEmpty) {
                          rows.clear();
                          rows = [
                            for (PlaceList placeList in state.placeLists!)
                              Animate(
                                  effects: const [SlideEffect()],
                                  child: CategoryCard(placeList: placeList))
                          ];
                        } else {
                          rows.clear();
                          // List<SampleCategoryCard> sampleCategoryCards = [];
                          for (PlaceList placeList in samplePlaceLists) {
                            rows.add(Animate(
                                effects: const [SlideEffect()],
                                child:
                                    SampleCategoryCard(placeList: placeList)));
                          }
                          rows.insert(
                              0,
                              Animate(
                                  effects: const [SlideEffect()],
                                  child: const BlankCategoryCard()));
                        }
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
        floatingActionButton: FloatingActionButton(
          shape: const StadiumBorder(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const CreateListDialog();
              },
            );
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add_circle_outline_rounded),
        ),
      ),
    );
  }
}

class InboxButton extends StatelessWidget {
  const InboxButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topStart,
      children: [
        PopupMenuButton(
          // color: Colors.grey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          position: PopupMenuPosition.under,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: SizedBox(
                // height: 150,
                width: 300,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Invites',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: InviteList(),
                  )
                ]),
              ))
            ];
          },
          child: IgnorePointer(
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.inbox,
                  size: 22,
                  color: Theme.of(context).iconTheme.color,
                )),
          ),
        ),
        BlocBuilder<InviteInboxBloc, InviteInboxState>(
          builder: (context, state) {
            if (state.status == InviteInboxStatus.loaded) {
              if (context.watch<InviteInboxBloc>().invites.isNotEmpty) {
                int inviteCount =
                    context.watch<InviteInboxBloc>().invites.length;
                return Animate(
                  effects: const [
                    ShakeEffect(
                        duration: Duration(seconds: 1),
                        hz: 2,
                        offset: Offset(-0.1, 1.0),
                        rotation: 1),
                    // ScaleEffect(),
                    // SlideEffect(
                    //   begin: Offset(0.5, 0.5),
                    //   end: Offset(0, 0),
                    // )
                  ],
                  child: Positioned(
                    top: 4,
                    left: 2,
                    child: CircleAvatar(
                      radius: 10.0,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        '$inviteCount',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        )
      ],
    );
  }
}

class InviteList extends StatelessWidget {
  const InviteList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InviteInboxBloc, InviteInboxState>(
      listener: (context, state) {
        if (state.status == InviteInboxStatus.accepted ||
            state.status == InviteInboxStatus.declined) {
          //  context.read<SavedListsBloc>().add(UpdateSavedLists());
        }
      },
      builder: (context, state) {
        if (state.status == InviteInboxStatus.loading) {
          return LoadingAnimationWidget.fourRotatingDots(
              color: Colors.blue, size: 20.0);
        }
        if (state.status == InviteInboxStatus.accepted) {
          return Center(
            child: Wrap(
              spacing: 8.0,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade400,
                ),
                const Text('Invite Accepted'),
              ],
            ),
          );
        }
        if (state.status == InviteInboxStatus.declined) {
          return Center(
            child: Wrap(
              spacing: 8.0,
              children: const [
                Icon(
                  Icons.remove_circle_rounded,
                  color: Colors.redAccent,
                ),
                Text('Invite Declined'),
              ],
            ),
          );
        }
        if (state.status == InviteInboxStatus.loaded) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: state.invites!.isNotEmpty ? state.invites!.length : 1,
              itemBuilder: (context, index) {
                if (state.invites!.isNotEmpty) {
                  Invite thisInvite = state.invites![index];
                  if (thisInvite.inviteStatus == 'declined') {
                    return DeclinedGroupInvite(thisInvite: thisInvite);
                  }
                  if (thisInvite.inviteStatus == 'accepted') {
                    return AcceptedGroupInvite(thisInvite: thisInvite);
                  } else {
                    return CollabInvite(thisInvite: thisInvite);
                  }
                }
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36.0),
                      child: Text(
                        'No Invites!',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                );
              });
        } else {
          return const Center(
            child: Text('Something Went Wrong..'),
          );
        }
      },
    );
  }
}

class CollabInvite extends StatelessWidget {
  const CollabInvite({
    Key? key,
    required this.thisInvite,
  }) : super(key: key);

  final Invite thisInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${thisInvite.inviterName.split(' ')[0]} ',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.blue),
                ),
                Text(
                  'invited you to:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: FittedBox(
                      child: Text(
                        thisInvite.placeListName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(AcceptInvite(invite: thisInvite));
                        },
                        icon: Icon(
                          color: Colors.green.shade400,
                          Icons.check_circle_rounded,
                        ),
                      ),
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(DeclineInvite(invite: thisInvite));
                        },
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Text(
            //       'As a',
            //       style: Theme.of(context).textTheme.titleSmall!,
            //     ),
            //     Text(
            //       ' ${thisInvite.inviteType}',
            //       style: Theme.of(context).textTheme.titleSmall!.copyWith(
            //             color: Colors.blue,
            //           ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

class DeclinedGroupInvite extends StatelessWidget {
  const DeclinedGroupInvite({
    Key? key,
    required this.thisInvite,
  }) : super(key: key);

  final Invite thisInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cancel_rounded,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '${thisInvite.inviterName.split(' ')[0]} ',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.blue),
                    ),
                    TextSpan(
                      text: 'declined your invite to:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Text(
                      thisInvite.placeListName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 1.0, top: 4.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(DeclineInvite(invite: thisInvite));
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Text(
            //       'As a',
            //       style: Theme.of(context).textTheme.subtitle2!,
            //     ),
            //     Text(
            //       ' ${thisInvite.inviteType}',
            //       style: Theme.of(context).textTheme.subtitle2!.copyWith(
            //             color: Colors.blue,
            //           ),
            //     ),
            //   ],
            // ),
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Divider(),
            // )
          ],
        ),
      ),
    );
  }
}

class AcceptedGroupInvite extends StatelessWidget {
  const AcceptedGroupInvite({
    Key? key,
    required this.thisInvite,
  }) : super(key: key);

  final Invite thisInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade400,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '${thisInvite.inviterName.split(' ')[0]} ',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.blue),
                    ),
                    TextSpan(
                      text: 'accepted your invite to:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Text(
                      thisInvite.placeListName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 1.0, top: 4.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(DeleteInvite(invite: thisInvite));
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            //     Text(
            //       'As a',
            //       style: Theme.of(context).textTheme.subtitle2!,
            //     ),
            //     Text(
            //       ' ${thisInvite.inviteType}',
            //       style: Theme.of(context).textTheme.subtitle2!.copyWith(
            //             color: Colors.blue,
            //           ),
            //     ),
            //   ],
            // ),
            // const Padding(
            //   padding: EdgeInsets.all(8.0),
            //   child: Divider(),
            // )
          ],
        ),
      ),
    );
  }
}
