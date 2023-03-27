import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/onboarding/bloc/onboarding_bloc.dart';
import 'package:leggo/cubit/cubit/signup/sign_up_cubit.dart';
import 'package:leggo/view/pages/signup/intro_paywall.dart';
import 'package:leggo/view/pages/signup/welcome_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'signup/profile_info.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final PageController pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var signupState = context.watch<SignUpCubit>().state;
    var onboardingState = context.watch<OnboardingBloc>().state;
    var purchasesState = context.watch<PurchasesBloc>().state;

    Future.delayed(Duration.zero, () async {
      if (signupState.status == SignupStatus.success) {
        //  pageController = PageController(initialPage: 0);
        if (pageController.hasClients && pageController.page == 0) {
          await Future.delayed(const Duration(seconds: 1), () async {
            await pageController.animateToPage(1,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutSine);
          });
        }
      }
      if (onboardingState.user?.profilePicture != null &&
          onboardingState.user?.profilePicture != '' &&
          onboardingState.user?.userName != '' &&
          onboardingState.user?.userName != null) {
        print('navigate to paywall');
        print('username: ${onboardingState.user?.userName}');
        await Future.delayed(const Duration(seconds: 1), () async {
          if (pageController.hasClients) {
            await pageController.animateToPage(2,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutSine);
          }
        });
      }
    });

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: const [
          WelcomePage(),
          ProfileInfo(),
          IntroPaywall(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        // color: FlexColor.bahamaBlueDarkPrimaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SmoothPageIndicator(
              controller: pageController,
              count: 3,
              effect: const WormEffect(
                  activeDotColor: FlexColor.bahamaBlueDarkSecondary,
                  dotColor: FlexColor.bahamaBlueDarkPrimaryContainer),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }
}

Future<void> setUserProfilePicture(BuildContext context) async {
  ImagePicker picker = ImagePicker();
  final XFile? image;

  image = await picker.pickImage(source: ImageSource.gallery);
  if (image == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No Image was selected!')));
  }

  if (image != null) {
    context.read<OnboardingBloc>().add(UpdateUserProfilePicture(image: image));
  }
}
