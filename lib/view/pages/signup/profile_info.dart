import 'package:cached_network_image/cached_network_image.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leggo/view/pages/signup.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../bloc/onboarding/bloc/onboarding_bloc.dart';
import '../../../cubit/cubit/signup/sign_up_cubit.dart';
import '../../../globals.dart';
import '../../../repository/database/database_repository.dart';

class ProfileInfo extends StatefulWidget {
  const ProfileInfo({super.key});

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  var maxLength = 15;
  var textLength = 0;
  var userNameFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: SetProfilePhotoAvatar(),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                        onPressed: state.user.profilePicture != '' &&
                                userNameFieldController.value.text != '' &&
                                userNameFieldController.value.text.length > 2
                            ? () async {
                                bool userNameAvailable =
                                    await DatabaseRepository()
                                        .checkUsernameAvailability(
                                            userNameFieldController.value.text);
                                if (userNameAvailable == true) {
                                  if (!mounted) return;
                                  context.read<OnboardingBloc>().add(UpdateUser(
                                      user: (state).user.copyWith(
                                          userName: userNameFieldController
                                              .value.text)));

                                  FocusManager.instance.primaryFocus?.unfocus();
                                } else {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            'Username already taken!',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )));
                                }
                              }
                            : null,
                        child: BlocBuilder<OnboardingBloc, OnboardingState>(
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Name: ${state.user.name}'),
                    ),
                  ],
                ),
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

class SetProfilePhotoAvatar extends StatelessWidget {
  const SetProfilePhotoAvatar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Future<void> setUserProfilePicture() async {
    //   ImagePicker picker = ImagePicker();
    //   final XFile? image;

    //   image = await picker.pickImage(source: ImageSource.gallery);
    //   if (image == null) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('No Image was selected!')));
    //   }

    //   if (image != null) {
    //     context
    //         .read<OnboardingBloc>()
    //         .add(UpdateUserProfilePicture(image: image));
    //   }
    // }

    return Stack(
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
                  onTap: () async => await setUserProfilePicture(context),
                  child: CircleAvatar(
                      radius: 60,
                      child: Text(
                        'Add a Photo!',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      )),
                );
              }
              if (state is OnboardingLoading) {
                return CircleAvatar(
                  radius: 60.0,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: FlexColor.bahamaBlueDarkSecondary, size: 30.0),
                );
              }
              if (state is OnboardingLoaded &&
                  state.user.profilePicture != '') {
                return InkWell(
                  onTap: () async => await setUserProfilePicture(context),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircleAvatar(
                      radius: 60,
                      child: LoadingAnimationWidget.staggeredDotsWave(
                          color: FlexColor.bahamaBlueDarkSecondary, size: 30.0),
                    ),
                    imageUrl: state.user.profilePicture!,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      foregroundImage: imageProvider,
                      radius: 60,
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: Text('Something Went Wrong...'),
                );
                Future<void> setUserProfilePicture() async {
                  ImagePicker picker = ImagePicker();
                  final XFile? image;

                  image = await picker.pickImage(source: ImageSource.gallery);
                  if (image == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No Image was selected!')));
                  }

                  if (image != null) {
                    context
                        .read<OnboardingBloc>()
                        .add(UpdateUserProfilePicture(image: image));
                  }
                }
              }
            },
          ),
        ),
        Positioned(
          right: -8,
          bottom: -4,
          child: IconButton(
            onPressed: () async {
              await setUserProfilePicture(context);
            },
            icon: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), color: Colors.white),
              child: const Icon(
                Icons.add_circle_rounded,
                color: FlexColor.bahamaBlueDarkSecondaryContainer,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class SetNameDialog extends StatelessWidget {
  const SetNameDialog({
    super.key,
    required this.nameFieldKey,
    required this.nameFieldController,
  });

  final GlobalKey<FormState> nameFieldKey;
  final TextEditingController nameFieldController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //  insetPadding: const EdgeInsets.symmetric(vertical: 24.0),
      titlePadding: const EdgeInsets.only(
        top: 24.0,
      ),
      title: const Text('Enter Your Name:', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 24.0),
            child: Text('So we know what to call you!'),
          ),
          Form(
            key: nameFieldKey,
            child: TextFormField(
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                // Check if user provided a first and last name
                if (value.split(' ').length < 2) {
                  return 'Please enter your first & last name';
                }
                return null;
              },
              controller: nameFieldController,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        // TextButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //       return;
        //     },
        //     child: const Text('Cancel')),
        ElevatedButton(
            style: ElevatedButton.styleFrom(fixedSize: const Size(140, 40)),
            onPressed: () async {
              if (nameFieldKey.currentState!.validate()) {
                context
                    .read<SignUpCubit>()
                    .nameChanged(nameFieldController.value.text.trim());
                await Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                });
              }
            },
            child: context.watch<SignUpCubit>().state.name == ''
                ? const Text('Submit')
                : Wrap(
                    direction: Axis.horizontal,
                    spacing: 8.0,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, color: Colors.white)
                          .animate()
                          .rotate(),
                      const Text('Name Set!'),
                    ],
                  )),
      ],
    );
  }
}
