import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/view/widgets/main_logo.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController passFieldController = TextEditingController();
    final TextEditingController emailFieldController = TextEditingController();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            // hasScrollBody: false,
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MainLogo(),
                  Platform.isIOS
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(200, 30)),
                              onPressed: () async {
                                await context
                                    .read<LoginCubit>()
                                    .logInWithApple();
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
                              label: const Text('Sign in with Apple')),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            direction: Axis.vertical,
                            spacing: 4.0,
                            children: [
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(200, 30)),
                                  onPressed: () async {
                                    await context
                                        .read<LoginCubit>()
                                        .logInWithGoogle();
                                  },
                                  icon: SizedBox(
                                    height: 16,
                                    width: 24,
                                    child: CachedNetworkImage(
                                        imageUrl:
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1200px-Google_%22G%22_Logo.svg.png'),
                                  ),
                                  label: const Text('Sign in with Google')),
                            ],
                          ),
                        ),
                  BlocBuilder<LoginCubit, LoginState>(
                    buildWhen: (previous, current) =>
                        previous.email != current.email,
                    builder: (context, state) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact),
                              onPressed: () {
                                context.pushNamed('signup');
                              },
                              child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? FlexColor.bahamaBlueLightPrimary
                                            : Colors.white),
                                    children: const [
                                      TextSpan(text: 'New?'),
                                      TextSpan(
                                        text: ' Sign Up.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ]),
                              )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
