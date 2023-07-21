import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/bloc/auth/bloc/auth_bloc.dart';
import 'package:leggo/bloc/place/edit_places_bloc.dart';
import 'package:leggo/model/place.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/view/pages/explore.dart';
import 'package:leggo/view/pages/explore/explore_details.dart';
import 'package:leggo/view/pages/homepage.dart';
import 'package:leggo/view/pages/login.dart';
import 'package:leggo/view/pages/my_subscription.dart';
import 'package:leggo/view/pages/profile.dart';
import 'package:leggo/view/pages/settings.dart';
import 'package:leggo/view/pages/signup.dart';
import 'package:leggo/view/pages/view_place_page.dart';
import 'package:leggo/view/widgets/dialogs/review_card_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/lists/list_sort_cubit.dart';
import '../random_wheel_page.dart';
import '../view/pages/category_page.dart';

final GoRouter router = GoRouter(
    observers: [HeroController()],
    initialLocation: '/',
    redirect: (context, state) async {
      bool loggedIn =
          context.read<AuthBloc>().state.status == AuthStatus.authenticated;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? initScreen = prefs.getInt("initScreen");
      bool isLoggingIn = state.location == '/login';
      bool isOnboarding = state.location == '/signup';
      bool completedOnboarding = initScreen == 1;
      if (isOnboarding) {
        return null;
      }
      if (!completedOnboarding) {
        return '/signup';
      }
      if (!loggedIn) {
        return isLoggingIn ? null : '/login';
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
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) =>
            const MaterialPage<void>(child: ProfilePage()),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) =>
            const MaterialPage<void>(child: SettingsPage()),
      ),
      GoRoute(
        path: '/my-subscription',
        name: 'my-subscription',
        pageBuilder: (context, state) =>
            const MaterialPage<void>(child: MySubscription()),
      ),
      GoRoute(
        path: '/review-card-dialog',
        name: 'review-card-dialog',
        pageBuilder: (context, state) => MaterialPage<void>(
            fullscreenDialog: true,
            child: ReviewCardDialog(review: state.extra! as dynamic)),
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
                pageBuilder: (context, state) => MaterialPage<void>(
                        child: MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => EditPlacesBloc(
                              placeListRepository:
                                  context.read<PlaceListRepository>()),
                        ),
                        BlocProvider(
                          create: (context) => ListSortCubit(),
                        ),
                      ],
                      child: const CategoryPage(),
                    )),
                routes: [
                  GoRoute(
                    name: 'random-wheel',
                    path: 'home/placeList-page/random-wheel',
                    pageBuilder: (context, state) =>
                        const MaterialPage<void>(child: RandomWheelPage()),
                  ),
                ])
          ]),
      GoRoute(
          path: '/explore',
          name: 'explore',
          pageBuilder: (context, state) =>
              const MaterialPage<void>(child: ExplorePage()),
          routes: [
            GoRoute(
              path: 'details',
              pageBuilder: (context, state) => CustomTransitionPage(
                transitionDuration: 400.ms,
                reverseTransitionDuration: 400.ms,
                child: ExploreDetailsPage(
                  photoIndex: state.extra as double?,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.scaled,
                    child: child,
                  );
                },
              ),
            )
          ]),
      GoRoute(
          path: '/view-place',
          name: 'view-place',
          pageBuilder: (context, state) => CustomTransitionPage(
                transitionDuration: 400.ms,
                reverseTransitionDuration: 400.ms,
                child: ViewPlacePage(place: state.extra as Place),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.scaled,
                    child: child,
                  );
                },
              ))
    ]);
