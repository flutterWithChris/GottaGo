import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/bloc/settings/settings_bloc.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/model/bug_report.dart';
import 'package:leggo/model/user.dart';
import 'package:leggo/repository/database/database_repository.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../globals.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User currentUser = context.read<ProfileBloc>().state.user;

    return Scaffold(
      bottomNavigationBar: MainBottomNavBar(),
      body: CustomScrollView(
        slivers: [
          const MainTopAppBar(),
          SliverFillRemaining(
            child: BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return SettingsList(
                    darkTheme: SettingsThemeData(
                        settingsListBackground:
                            Theme.of(context).scaffoldBackgroundColor),
                    lightTheme: SettingsThemeData(
                        settingsListBackground:
                            Theme.of(context).scaffoldBackgroundColor),
                    sections: [
                      SettingsSection(title: const Text('Account'), tiles: [
                        SettingsTile.navigation(
                          onPressed: (context) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const ChangeNameDialog();
                              },
                            );
                          },
                          leading: const Icon(Icons.person_rounded),
                          title: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text('Name'),
                          ),
                          value: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: FittedBox(
                                  alignment: Alignment.centerRight,
                                  fit: BoxFit.scaleDown,
                                  child: Text(context
                                      .read<ProfileBloc>()
                                      .state
                                      .user
                                      .name!))),
                        ),
                        SettingsTile.navigation(
                          onPressed: (context) => showDialog(
                              context: context,
                              builder: (context) =>
                                  const ChangeUsernameDialog()),
                          leading: const Icon(
                            FontAwesomeIcons.at,
                            size: 20,
                          ),
                          title: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text('Username'),
                          ),
                          value: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: FittedBox(
                                  alignment: Alignment.centerRight,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                      '@${context.read<ProfileBloc>().state.user.userName!}'))),
                        ),
                        SettingsTile.navigation(
                          leading: const Icon(Icons.logout_rounded),
                          onPressed: (context) =>
                              context.read<LoginCubit>().logout(),
                          title: const Text('Sign Out'),
                        ),
                        SettingsTile.navigation(
                          onPressed: (context) {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  DeleteAccountDialog(currentUser: currentUser),
                            );
                          },
                          leading: const Icon(Icons.delete_forever_rounded),
                          title: const Text('Delete Account'),
                        )
                      ]),
                      SettingsSection(
                          title: const Text('Subscription'),
                          tiles: [
                            SettingsTile.navigation(
                                leading: const Icon(Icons.receipt_rounded),
                                title: const Text('My Subscription'))
                          ]),
                      SettingsSection(
                          title: const Text('Help & Support'),
                          tiles: [
                            SettingsTile.navigation(
                              leading: const Icon(Icons.report),
                              title: const Text('Report an Issue / Bug'),
                              onPressed: (context) => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ReportBugDialog()),
                            ),
                          ]),
                    ]);
              },
            ),
          )
        ],
      ),
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 225,
        width: 150,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Delete Account?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'To confirm you want to delete your account you must re-sign in.',
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () => context
                      .read<SettingsBloc>()
                      .add(DeleteAccount(user: currentUser)),
                  child: const Text('Confirm Deletion')),
              const Text(
                '(Cannot be undone.)',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeUsernameDialog extends StatefulWidget {
  const ChangeUsernameDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ChangeUsernameDialog> createState() => _ChangeUsernameDialogState();
}

class _ChangeUsernameDialogState extends State<ChangeUsernameDialog> {
  final TextEditingController usernameFieldController = TextEditingController();
  var maxLength = 15;
  var textLength = 0;

  @override
  void initState() {
    // TODO: implement initState
    usernameFieldController.text =
        context.read<ProfileBloc>().state.user.userName!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    textLength = usernameFieldController.value.text.length;
    return Dialog(
      child: SizedBox(
        height: 250,
        width: 160,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Change Username:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                autofocus: true,
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
                controller: usernameFieldController,
                onChanged: (value) {
                  setState(() {
                    textLength = value.length;
                  });
                },
                decoration: InputDecoration(
                  suffixText:
                      '${textLength.toString()}/${maxLength.toString()}',
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
                      borderSide: const BorderSide(
                          width: 2.0, color: Colors.redAccent)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: const BorderSide(
                          width: 2.0, color: Colors.redAccent)),
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
              BlocConsumer<SettingsBloc, SettingsState>(
                listener: (context, state) async {
                  if (state is SettingsUpdated) {
                    await Future.delayed(const Duration(seconds: 2),
                        () => Navigator.pop(context));
                  }
                },
                builder: (context, state) {
                  if (state is SettingsLoading) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: FlexColor.bahamaBlueDarkSecondary,
                            size: 18.0));
                  }
                  if (state is SettingsUpdated) {
                    return ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.check,
                          color: Colors.green.shade400,
                        ),
                        label: const Text('Username Updated!'));
                  }
                  if (state is SettingsFailed) {
                    return ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        label: const Text('Updating Failed!'));
                  }
                  return ElevatedButton(
                      onPressed: context
                                      .read<ProfileBloc>()
                                      .state
                                      .user
                                      .profilePicture !=
                                  '' &&
                              usernameFieldController.value.text != '' &&
                              usernameFieldController.value.text.length > 2
                          ? () async {
                              bool userNameAvailable =
                                  await DatabaseRepository()
                                      .checkUsernameAvailability(
                                          usernameFieldController.value.text);
                              if (userNameAvailable == true) {
                                if (!mounted) return;
                                context.read<SettingsBloc>().add(UpdateUsername(
                                    userName:
                                        usernameFieldController.value.text,
                                    user: context
                                        .read<ProfileBloc>()
                                        .state
                                        .user));

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
                      child: const Text('Update Name'));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeNameDialog extends StatefulWidget {
  const ChangeNameDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ChangeNameDialog> createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  final TextEditingController bugReportFieldController =
      TextEditingController();

  @override
  void initState() {
    bugReportFieldController.text =
        context.read<ProfileBloc>().state.user.name!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 250,
        width: 160,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Change Name:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextField(
                autofocus: true,
                controller: bugReportFieldController,
              ),
              BlocConsumer<SettingsBloc, SettingsState>(
                listener: (context, state) async {
                  if (state is SettingsUpdated) {
                    await Future.delayed(const Duration(seconds: 2),
                        () => Navigator.pop(context));
                  }
                },
                builder: (context, state) {
                  if (state is SettingsLoading) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: FlexColor.bahamaBlueDarkSecondary,
                            size: 18.0));
                  }
                  if (state is SettingsUpdated) {
                    return ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.check,
                          color: Colors.green.shade400,
                        ),
                        label: const Text('Name Updated!'));
                  }
                  if (state is SettingsFailed) {
                    return ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        label: const Text('Updating Failed!'));
                  }
                  return ElevatedButton(
                      onPressed: () {
                        context.read<SettingsBloc>().add(UpdateName(
                            user: context
                                .read<ProfileBloc>()
                                .state
                                .user
                                .copyWith(
                                    name:
                                        bugReportFieldController.value.text)));
                      },
                      child: const Text('Update Name'));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ReportBugDialog extends StatefulWidget {
  const ReportBugDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ReportBugDialog> createState() => _ReportBugDialogState();
}

class _ReportBugDialogState extends State<ReportBugDialog> {
  final TextEditingController bugReportFieldController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 300,
        width: 200,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Report a Bug:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text('Tell us what\'s going wrong!'),
              TextField(
                autofocus: true,
                minLines: 3,
                maxLines: 4,
                controller: bugReportFieldController,
              ),
              BlocConsumer<SettingsBloc, SettingsState>(
                listener: (context, state) async {
                  if (state is SettingsUpdated) {
                    await Future.delayed(const Duration(seconds: 2),
                        () => Navigator.pop(context));
                  }
                },
                builder: (context, state) {
                  if (state is SettingsLoading) {
                    return ElevatedButton(
                        onPressed: () {},
                        child: LoadingAnimationWidget.staggeredDotsWave(
                            color: FlexColor.bahamaBlueDarkSecondary,
                            size: 18.0));
                  }
                  if (state is SettingsUpdated) {
                    return ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.check,
                          color: Colors.green.shade400,
                        ),
                        label: const Text('Bug Report Sent!'));
                  }
                  if (state is SettingsFailed) {
                    return ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        label: const Text('Sending Failed!'));
                  }
                  return ElevatedButton(
                      onPressed: () {
                        context.read<SettingsBloc>().add(ReportIssue(
                            bugReport: BugReport(
                                userId:
                                    context.read<ProfileBloc>().state.user.id!,
                                userName: context
                                    .read<ProfileBloc>()
                                    .state
                                    .user
                                    .name!,
                                dateTime: DateTime.now().toIso8601String(),
                                device: Platform.operatingSystem,
                                report: bugReportFieldController.value.text)));
                      },
                      child: const Text('Send Bug Report'));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
