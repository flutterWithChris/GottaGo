import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/profile_bloc.dart';
import 'package:leggo/cubit/cubit/login/login_cubit.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MainBottomNavBar(),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const MainTopAppBar(),
          SliverFillRemaining(
            child: SettingsList(
                darkTheme: SettingsThemeData(
                    settingsListBackground:
                        Theme.of(context).scaffoldBackgroundColor),
                lightTheme: SettingsThemeData(
                    settingsListBackground:
                        Theme.of(context).scaffoldBackgroundColor),
                physics: const NeverScrollableScrollPhysics(),
                sections: [
                  SettingsSection(title: const Text('Account'), tiles: [
                    SettingsTile.navigation(
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
                      leading: const Icon(Icons.delete_forever_rounded),
                      title: const Text('Delete Account'),
                    )
                  ]),
                  SettingsSection(title: const Text('Help & Support'), tiles: [
                    SettingsTile.navigation(
                      leading: const Icon(Icons.report),
                      title: const Text('Report an Issue / Bug'),
                    ),
                    SettingsTile.navigation(
                      leading: const Icon(Icons.contact_support_rounded),
                      title: const Text('Contact Us'),
                    ),
                  ])
                ]),
          )
        ],
      ),
    );
  }
}
