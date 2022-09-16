import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';

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
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Wrap(
                    spacing: 24.0,
                    children: [
                      const Icon(
                        FontAwesomeIcons.buildingCircleCheck,
                        size: 48,
                      ),
                      Text(
                        'GottaGo',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
                BlocBuilder<LoginCubit, LoginState>(
                  buildWhen: (previous, current) =>
                      previous.email != current.email,
                  builder: (context, state) {
                    return SizedBox(
                      width: 350,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {},
                              child: RichText(
                                textAlign: TextAlign.end,
                                text: const TextSpan(children: [
                                  TextSpan(text: 'New?'),
                                  TextSpan(
                                      text: ' Sign Up.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ]),
                              )),
                        ],
                      ),
                    );
                  },
                ),
                BlocBuilder<LoginCubit, LoginState>(
                  buildWhen: (previous, current) =>
                      previous.password != current.password,
                  builder: (context, state) {
                    return SizedBox(
                      width: 350,
                      child: TextField(
                        onChanged: (email) {
                          context.read<LoginCubit>().emailChanged(email);
                        },
                        controller: emailFieldController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).highlightColor,
                                    width: 1.0),
                                borderRadius: BorderRadius.circular(20.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2.0),
                                borderRadius: BorderRadius.circular(20.0)),
                            label: const Text('Email Address'),
                            prefixIcon: const Icon(Icons.email_rounded)),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 12.0,
                ),
                SizedBox(
                  width: 350,
                  child: TextField(
                    onChanged: (password) {
                      context.read<LoginCubit>().passwordChanged(password);
                    },
                    controller: passFieldController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).highlightColor,
                                width: 1.0),
                            borderRadius: BorderRadius.circular(20.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(20.0)),
                        prefixIcon: const Icon(Icons.lock),
                        label: const Text('Password')),
                  ),
                ),
                SizedBox(
                  width: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password?')),
                    ],
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(225, 32)),
                    onPressed: () {
                      context.read<LoginCubit>().logInWithCredentials();
                    },
                    child: const Text('Login')),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
