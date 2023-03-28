import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/model/user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/onboarding/bloc/onboarding_bloc.dart';
import '../../../cubit/cubit/signup/sign_up_cubit.dart';
import '../../widgets/main_logo.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final nameFieldKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                                      ?.displayName,
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
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                            label: const Text('Sign Up With Apple'))
                        : ElevatedButton.icon(
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
                                      .user!
                                      .displayName,
                                  email: context
                                      .read<SignUpCubit>()
                                      .state
                                      .user!
                                      .email,
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
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ])))
                  ],
                );
              },
            ))
      ]),
    );
  }
}
