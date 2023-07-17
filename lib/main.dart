import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leggo/bloc/autocomplete/bloc/autocomplete_bloc.dart';
import 'package:leggo/bloc/bloc/auth/bloc/auth_bloc.dart';
import 'package:leggo/bloc/bloc/invite/bloc/invite_bloc.dart';
import 'package:leggo/bloc/bloc/invite_inbox/invite_inbox_bloc.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/explore/explore_bloc.dart';
import 'package:leggo/bloc/onboarding/bloc/onboarding_bloc.dart';
import 'package:leggo/bloc/place/place_bloc.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/bloc/settings/settings_bloc.dart';
import 'package:leggo/cubit/cubit/cubit/view_place_cubit.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/cubit/cubit/signup/sign_up_cubit.dart';
import 'package:leggo/firebase_options.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/repository/auth_repository.dart';
import 'package:leggo/repository/chat_gpt/chat_gpt_repository.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:leggo/repository/invite_repository.dart';
import 'package:leggo/repository/place_list_repository.dart';
import 'package:leggo/repository/places_repository.dart';
import 'package:leggo/repository/purchases_repository.dart';
import 'package:leggo/repository/storage/storage_repository.dart';
import 'package:leggo/repository/user_repository.dart';
import 'package:leggo/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // * Force onboarding pref
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // prefs.setInt('initScreen', 0);
  await Future.wait([
    dotenv.load(fileName: '.env'),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);
  FirebaseUIAuth.configureProviders([
    GoogleProvider(clientId: dotenv.get('GOOGLE_CLIENT_ID')),
    AppleProvider(scopes: {'email', 'fullName'}),
  ]);
  // await FirebaseFirestore.instance.clearPersistence();
  // FirebaseAuth.instance.signOut();

// TODO: Uncomment this line to set up Crashlytics.
  // Pass all uncaught errors from the framework to Crashlytics.
  //  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => PurchasesRepository()..initPlatformState(),
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
        RepositoryProvider(create: (context) => ChatGPTRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => AuthBloc(
                purchasesRepository: context.read<PurchasesRepository>(),
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
            create: (context) => PurchasesBloc(
                purchasesRepository: context.read<PurchasesRepository>(),
                authBloc: context.read<AuthBloc>(),
                databaseRepository: context.read<DatabaseRepository>())
              ..add(LoadPurchases()),
          ),
          BlocProvider(
            create: (context) =>
                LoginCubit(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
                storageRepository: context.read<StorageRepository>(),
                userRepository: context.read<UserRepository>(),
                authBloc: context.read<AuthBloc>())
              ..add(LoadProfile(
                  userId: context.read<AuthBloc>().state.authUser!.uid)),
          ),
          BlocProvider(
            create: (context) => InviteInboxBloc(
                inviteRepository: context.read<InviteRepository>())
              ..add(LoadInvites()),
          ),
          BlocProvider(
              create: (context) => SavedListsBloc(
                  profileBloc: context.read<ProfileBloc>(),
                  userRepository: context.read<UserRepository>(),
                  placeListRepository: context.read<PlaceListRepository>())),
          BlocProvider(
            create: (context) => InviteBloc(
                placeListRepository: context.read<PlaceListRepository>()),
          ),
          BlocProvider(
            create: (context) => SavedPlacesBloc(
                userRepository: context.read<UserRepository>(),
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
          BlocProvider(
            create: (context) => SettingsBloc(
                authRepository: context.read<AuthRepository>(),
                databaseRepository: context.read<DatabaseRepository>()),
          ),
          BlocProvider(
            create: (context) => ExploreBloc(
                chatGPTRepository: context.read<ChatGPTRepository>(),
                placesRepository: context.read<PlacesRepository>()),
            child: Container(),
          )
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: snackbarKey,
          theme: FlexThemeData.light(
            scheme: FlexScheme.bahamaBlue,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurfaces,
            blendLevel: 9,
            secondary: const Color(0xFFDD520F),
            applyElevationOverlayColor: false,
            subThemesData: const FlexSubThemesData(
              popupMenuElevation: 0.2,
              elevatedButtonSchemeColor: SchemeColor.onPrimary,
              elevatedButtonSecondarySchemeColor: SchemeColor.secondary,
              fabSchemeColor: SchemeColor.secondary,
              bottomSheetModalElevation: 0,
              cardElevation: 0,
              defaultRadius: 20,
              blendOnLevel: 10,
              blendOnColors: false,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            fontFamily: GoogleFonts.archivo().fontFamily,
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.bahamaBlue,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            blendLevel: 15,
            secondary: const Color(0xFFDD520F),
            subThemesData: const FlexSubThemesData(
              elevatedButtonSchemeColor: SchemeColor.onPrimary,
              elevatedButtonSecondarySchemeColor: SchemeColor.secondary,
              fabSchemeColor: SchemeColor.secondary,
              bottomSheetModalElevation: 0,
              cardElevation: 0.6,
              defaultRadius: 24,
              blendOnLevel: 20,
            ),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
            swapLegacyOnMaterial3: true,
            fontFamily: GoogleFonts.archivo().fontFamily,
          ),
          themeMode: ThemeMode.system,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          routerDelegate: router.routerDelegate,
        ),
      ),
    );
  }
}
