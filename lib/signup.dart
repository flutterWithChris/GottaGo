import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/animate.dart';
import 'package:flutter_animate/effects/effects.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leggo/bloc/onboarding/bloc/onboarding_bloc.dart';
import 'package:leggo/cubit/cubit/signup/sign_up_cubit.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Scaffold(
      body: PageView(
        // physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: [
          WelcomePage(pageController: pageController),
          ProfileInfo(pageController: pageController),
          IntroPaywall(pageController: pageController),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: FlexColor.bahamaBlueDarkPrimaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SmoothPageIndicator(
              controller: pageController,
              count: 3,
              effect: WormEffect(
                  activeDotColor: FlexColor.bahamaBlueDarkSecondary,
                  dotColor: Theme.of(context).scaffoldBackgroundColor),
            ),
          ]),
        ),
      ),
    );
  }
}

class IntroPaywall extends StatefulWidget {
  final PageController pageController;
  const IntroPaywall({super.key, required this.pageController});

  @override
  State<IntroPaywall> createState() => _IntroPaywallState();
}

class _IntroPaywallState extends State<IntroPaywall> {
  bool yearlySelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        'Try Premium For Free!',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const Padding(
        padding:
            EdgeInsets.only(left: 24.0, right: 24.0, bottom: 12.0, top: 8.0),
        child: Text.rich(
          TextSpan(style: TextStyle(height: 1.618), children: [
            TextSpan(text: 'Get a 7-day free trial of all premium features.'),
          ]),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Card(
          elevation: 1.25,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeatureChecklistItem(
                  description: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall,
                      children: const [
                        TextSpan(
                          text: 'Invite friends ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'to collabarate on lists.'),
                      ]),
                  icon: Icons.person_add_alt_1,
                  iconSize: 24.0,
                  wrapSpacing: 8.0,
                ),
                FeatureChecklistItem(
                  description: TextSpan(
                    style: Theme.of(context).textTheme.titleSmall,
                    children: const [
                      TextSpan(
                        text: 'Random wheel ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: 'makes choosing plans easy.'),
                    ],
                  ),
                  icon: FontAwesomeIcons.dice,
                  iconSize: 17.0,
                  wrapSpacing: 14.0,
                ),
                FeatureChecklistItem(
                  description: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall,
                      children: const [
                        TextSpan(text: 'Unlock'),
                        TextSpan(
                          text: ' custom icons ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'for your lists.'),
                      ]),
                  icon: FontAwesomeIcons.icons,
                  iconSize: 20,
                  wrapSpacing: 12.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Monthly (\$4.99)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Switch.adaptive(
                          value: yearlySelected,
                          onChanged: (value) => setState(() {
                            yearlySelected = value;
                          }),
                        ),
                        const Text(
                          'Yearly (\$29.99)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(fixedSize: const Size(200, 30)),
                onPressed: () async {
                  // * Set Onboarding Complete Pref
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('initScreen', 1);
                  if (!mounted) return;
                  context.go('/');
                },
                icon: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50)),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: Colors.blue.shade300,
                  ),
                ),
                label: const Text('Count Me In!')),
            TextButton(
                onPressed: () async {
                  // * Set Onboarding Complete Pref
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('initScreen', 1);
                  if (!mounted) return;
                  context.go('/');
                },
                child: const Text('I don\'t like free stuff.')),
          ],
        ),
      ),
    ]);
  }
}

class FeatureChecklistItem extends StatelessWidget {
  final IconData icon;
  final TextSpan description;
  final double wrapSpacing;
  final double iconSize;
  const FeatureChecklistItem({
    required this.description,
    required this.icon,
    required this.iconSize,
    required this.wrapSpacing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: wrapSpacing,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: FlexColor.bahamaBlueDarkPrimaryVariant,
          ),
          Text.rich(description),
        ],
      ),
    );
  }
}

Future<void> setUserProfilePicture(BuildContext context, XFile? image) async {
  ImagePicker picker = ImagePicker();
  image = await picker.pickImage(source: ImageSource.gallery);

  if (image == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No Image was selected!')));
  }

  if (image != null) {
    context.read<OnboardingBloc>().add(UpdateUserProfilePicture(image: image));
  }
}

class ProfileInfo extends StatefulWidget {
  final PageController pageController;
  const ProfileInfo({required this.pageController, super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  var maxLength = 15;
  var textLength = 0;
  var userNameFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    XFile? image;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Profile Setup',
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
        const Text('Choose a profile photo & username.'),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.white,
                child: BlocBuilder<OnboardingBloc, OnboardingState>(
                  builder: (context, state) {
                    if (state is OnboardingLoaded &&
                        (state).user.profilePicture == '') {
                      return InkWell(
                        onTap: () => setUserProfilePicture(context, image),
                        child: CircleAvatar(
                            radius: 60,
                            child: Text(
                              'Add a Photo!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            )),
                      );
                    }
                    if (state is OnboardingLoading) {
                      return CircleAvatar(
                        radius: 60.0,
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: FlexColor.bahamaBlueDarkSecondary,
                            size: 30.0),
                      );
                    }
                    if (state is OnboardingLoaded &&
                        state.user.profilePicture != '') {
                      return InkWell(
                        onTap: () => setUserProfilePicture(context, image),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => CircleAvatar(
                            radius: 60,
                            child: LoadingAnimationWidget.staggeredDotsWave(
                                color: FlexColor.bahamaBlueDarkSecondary,
                                size: 30.0),
                          ),
                          imageUrl: state.user.profilePicture!,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            foregroundImage: imageProvider,
                            radius: 60,
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
                    setUserProfilePicture(context, image);
                  },
                  icon: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white),
                    child: const Icon(
                      Icons.add_circle_rounded,
                      color: FlexColor.bahamaBlueDarkSecondaryContainer,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FractionallySizedBox(
            widthFactor: 0.70,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                suffixText: '${textLength.toString()}/${maxLength.toString()}',
                suffixStyle: Theme.of(context).textTheme.bodySmall,
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
                    borderSide:
                        const BorderSide(width: 2.0, color: Colors.redAccent)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide:
                        const BorderSide(width: 2.0, color: Colors.redAccent)),
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
        ),
        BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state is OnboardingLoading) {
              return LoadingAnimationWidget.staggeredDotsWave(
                  color: FlexColor.bahamaBlueDarkSecondary, size: 30.0);
            }
            if (state is OnboardingLoaded) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: state.user.profilePicture != '' &&
                            userNameFieldController.value.text != '' &&
                            userNameFieldController.value.text.length > 2
                        ? () async {
                            bool userNameAvailable = await DatabaseRepository()
                                .checkUsernameAvailability(
                                    userNameFieldController.value.text);
                            if (userNameAvailable == true) {
                              if (!mounted) return;
                              context.read<OnboardingBloc>().add(UpdateUser(
                                  user: (state).user.copyWith(
                                      userName:
                                          userNameFieldController.value.text)));

                              FocusManager.instance.primaryFocus?.unfocus();
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'Username already taken!',
                                        style: TextStyle(color: Colors.white),
                                      )));
                            }
                          }
                        : null,
                    child: BlocConsumer<OnboardingBloc, OnboardingState>(
                      listener: (context, state) async {
                        if (state.user?.profilePicture != '' &&
                            state.user?.userName != '') {
                          await Future.delayed(
                            const Duration(milliseconds: 800),
                            () async => await widget.pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutSine),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is OnboardingLoading) {
                          return LoadingAnimationWidget.staggeredDotsWave(
                              color: FlexColor.bahamaBlueDarkSecondary,
                              size: 20.0);
                        }
                        if (state is OnboardingLoaded) {
                          if (state.user.profilePicture != '' &&
                              state.user.userName != '') {
                            return Animate(
                              effects: const [RotateEffect()],
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.green.shade400,
                              ),
                            );
                          }
                          return const Text('Set Username & Photo');
                        } else {
                          return const Center(
                            child: Text('Something Went Wrong...'),
                          );
                        }
                      },
                    )),
              );
            } else {
              return const Center(
                child: Text('Something Went Wrong...'),
              );
            }
          },
        ),
      ],
    );
  }
}

class WelcomePage extends StatefulWidget {
  final PageController pageController;
  const WelcomePage({required this.pageController, super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) async {
        if (state.status == SignupStatus.success) {
          await Future.delayed(
              const Duration(milliseconds: 800),
              () => widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutSine));
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const MainLogo(),
            const Text(
              'Save places you want to visit, share them with friends, & let fate decide your plans.',
              textAlign: TextAlign.center,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (context, state) {
                    if (state.status == SignupStatus.submitting) {
                      return LoadingAnimationWidget.staggeredDotsWave(
                          color: FlexColor.bahamaBlueDarkSecondary, size: 30.0);
                    }
                    if (state.status == SignupStatus.success) {
                      return ElevatedButton(
                          onPressed: () {},
                          child: Animate(
                            effects: const [RotateEffect()],
                            child: Icon(
                              Icons.check,
                              color: Colors.green.shade400,
                            ),
                          ));
                    }
                    return Wrap(
                      direction: Axis.vertical,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      children: [
                        Platform.isIOS
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(240, 30)),
                                onPressed: () async {
                                  await context
                                      .read<SignUpCubit>()
                                      .signUpWithApple();
                                  if (!mounted) return;
                                  User user = User(
                                      id: context
                                          .read<SignUpCubit>()
                                          .state
                                          .user!
                                          .uid,
                                      userName: '',
                                      name: context
                                              .read<SignUpCubit>()
                                              .state
                                              .user
                                              ?.displayName ??
                                          '',
                                      email: context
                                              .read<SignUpCubit>()
                                              .state
                                              .user
                                              ?.email ??
                                          '',
                                      profilePicture: '',
                                      placeListIds: []);

                                  context
                                      .read<OnboardingBloc>()
                                      .add(StartOnboarding(user: user));
                                },
                                icon: SizedBox(
                                  height: 18,
                                  width: 24,
                                  //  width: 24,
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        'https://www.freepnglogos.com/uploads/apple-logo-png/apple-logo-png-dallas-shootings-don-add-are-speech-zones-used-4.png',
                                    color: Colors.white,
                                  ),
                                ),
                                label: const Text('Sign Up With Apple'))
                            : const SizedBox(),
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(240, 30)),
                            onPressed: () async {
                              await context
                                  .read<SignUpCubit>()
                                  .signUpWithGoogle();
                              if (!mounted) return;
                              User user = User(
                                  id: context
                                      .read<SignUpCubit>()
                                      .state
                                      .user!
                                      .uid,
                                  userName: '',
                                  name: context
                                          .read<SignUpCubit>()
                                          .state
                                          .user
                                          ?.displayName ??
                                      '',
                                  email: context
                                          .read<SignUpCubit>()
                                          .state
                                          .user
                                          ?.email ??
                                      '',
                                  profilePicture: '',
                                  placeListIds: []);

                              context
                                  .read<OnboardingBloc>()
                                  .add(StartOnboarding(user: user));
                            },
                            icon: SizedBox(
                              height: 16,
                              width: 24,
                              child: CachedNetworkImage(
                                  imageUrl:
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png'),
                            ),
                            label: const Text('Sign Up With Google')),
                        TextButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setInt('initScreen', 1);
                              if (!mounted) return;
                              context.go('/login');
                            },
                            child: const Text.rich(TextSpan(children: [
                              TextSpan(text: 'Already have an account?'),
                              TextSpan(
                                  text: ' Sign In.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ])))
                      ],
                    );
                  },
                ))
          ]),
        );
      },
    );
  }
}

class MainLogo extends StatelessWidget {
  const MainLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: const [
            Icon(
              FontAwesomeIcons.locationPin,
              color: FlexColor.bahamaBlueDarkSecondaryContainer,
              size: 55,
            ),
            Positioned(
              top: 12.0,
              child: Icon(
                FontAwesomeIcons.solidHeart,
                fill: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 4.0,
        ),
        Text(
          'GottaGo',
          style: GoogleFonts.exo2(
                  fontWeight: FontWeight.w700, fontStyle: FontStyle.italic)
              .copyWith(fontSize: 60),
        ),
      ],
    );
  }
}
