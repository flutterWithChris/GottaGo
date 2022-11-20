import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/signup.dart';

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
          // SliverAppBar.medium(
          //   // leading: Padding(
          //   //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //   //   child: IconButton(
          //   //     onPressed: () {},
          //   //     icon: const Icon(Icons.menu),
          //   //   ),
          //   // ),
          //   title: Wrap(
          //     spacing: 18.0,
          //     children: const [
          //       Icon(FontAwesomeIcons.buildingCircleCheck),
          //       Text(
          //         'GottaGo',
          //         style: TextStyle(fontWeight: FontWeight.bold),
          //       ),
          //     ],
          //   ),
          //   expandedHeight: 120,
          //   actions: [
          //     IconButton(
          //         onPressed: () {}, icon: const Icon(Icons.more_vert))
          //   ],
          // ),

          SliverFillRemaining(
            // hasScrollBody: false,
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MainLogo(),

                  // BlocBuilder<LoginCubit, LoginState>(
                  //   buildWhen: (previous, current) =>
                  //       previous.password != current.password,
                  //   builder: (context, state) {
                  //     return SizedBox(
                  //       width: 350,
                  //       child: TextField(
                  //         onChanged: (email) {
                  //           context.read<LoginCubit>().emailChanged(email);
                  //         },
                  //         controller: emailFieldController,
                  //         keyboardType: TextInputType.emailAddress,
                  //         decoration: InputDecoration(
                  //             enabledBorder: OutlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                     color: Theme.of(context).highlightColor,
                  //                     width: 1.0),
                  //                 borderRadius: BorderRadius.circular(20.0)),
                  //             focusedBorder: OutlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                     color: Theme.of(context).primaryColor,
                  //                     width: 2.0),
                  //                 borderRadius: BorderRadius.circular(20.0)),
                  //             label: const Text('Email Address'),
                  //             prefixIcon: const Icon(Icons.email_rounded)),
                  //       ),
                  //     );
                  //   },
                  // ),
                  // const SizedBox(
                  //   height: 12.0,
                  // ),
                  // SizedBox(
                  //   width: 350,
                  //   child: TextField(
                  //     onChanged: (password) {
                  //       context.read<LoginCubit>().passwordChanged(password);
                  //     },
                  //     controller: passFieldController,
                  //     keyboardType: TextInputType.text,
                  //     obscureText: true,
                  //     decoration: InputDecoration(
                  //         enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(
                  //                 color: Theme.of(context).highlightColor,
                  //                 width: 1.0),
                  //             borderRadius: BorderRadius.circular(20.0)),
                  //         focusedBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(
                  //                 color: Theme.of(context).primaryColor,
                  //                 width: 2.0),
                  //             borderRadius: BorderRadius.circular(20.0)),
                  //         prefixIcon: const Icon(Icons.lock),
                  //         label: const Text('Password')),
                  //   ),
                  // ),
                  // SizedBox(
                  //   width: 350,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       TextButton(
                  //           onPressed: () {},
                  //           child: const Text('Forgot Password?')),
                  //     ],
                  //   ),
                  // ),
                  // ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //         fixedSize: const Size(225, 32)),
                  //     onPressed: () async {
                  //       await context.read<LoginCubit>().logInWithCredentials();
                  //     },
                  //     child: const Text('Login')),
                  Platform.isIOS
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(180, 30)),
                          onPressed: () async {
                            await context.read<LoginCubit>().logInWithApple();
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
                          label: const Text('Login with Apple'))
                      : const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      direction: Axis.vertical,
                      spacing: 4.0,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(180, 30)),
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
                            label: const Text('Login with Google')),
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
                                //textAlign: TextAlign.end,
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
