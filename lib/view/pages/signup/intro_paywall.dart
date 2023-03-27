import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroPaywall extends StatefulWidget {
  const IntroPaywall({super.key});

  @override
  State<IntroPaywall> createState() => _IntroPaywallState();
}

class _IntroPaywallState extends State<IntroPaywall> {
  bool yearlySelected = false;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text(
        'Try Premium For Free!',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const Padding(
        padding:
            EdgeInsets.only(left: 24.0, right: 24.0, bottom: 12.0, top: 8.0),
        child: Text.rich(
          TextSpan(style: TextStyle(height: 1.618), children: [
            TextSpan(text: 'Get a '),
            TextSpan(
                text: '7-day free trial ',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: 'of all premium features.')
          ]),
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 1.25,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
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
                      TextSpan(text: 'to help choose plans!'),
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Wrap(
                //       spacing: 8.0,
                //       crossAxisAlignment: WrapCrossAlignment.center,
                //       children: [
                //         const Text(
                //           'Monthly (\$4.99)',
                //           style: TextStyle(fontWeight: FontWeight.bold),
                //         ),
                //         Switch.adaptive(
                //           value: yearlySelected,
                //           onChanged: (value) => setState(() {
                //             yearlySelected = value;
                //           }),
                //         ),
                //         const Text(
                //           'Yearly (\$29.99)',
                //           style: TextStyle(fontWeight: FontWeight.bold),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            BlocConsumer<PurchasesBloc, PurchasesState>(
              listener: (context, state) async {
                if (state is PurchasesUpdated) {
                  // * Set Onboarding Complete Pref
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('initScreen', 1);
                  if (!mounted) return;
                  context.go('/');
                }
                if (state is PurchasesFailed) {}
              },
              builder: (context, state) {
                if (state is PurchasesLoading) {
                  return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(300, 30)),
                      onPressed: () async {},
                      child: LoadingAnimationWidget.staggeredDotsWave(
                          color: FlexColor.bahamaBlueDarkSecondary,
                          size: 20.0));
                }
                if (state is PurchasesLoaded) {
                  return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(300, 30)),
                      onPressed: () async {
                        Package? monthlyPackage = state.offerings!
                            .getOffering('premium_individual_monthly')!
                            .getPackage('\$rc_monthly');
                        context
                            .read<PurchasesBloc>()
                            .add(AddPurchase(package: monthlyPackage!));
                      },
                      child: const Text('Subscribe & Start Trial'));
                } else {
                  return ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(300, 30)),
                      onPressed: () async {},
                      icon: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50)),
                        child: const Icon(
                          Icons.error,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                      label: const Text('Error!'));
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text.rich(
                const TextSpan(children: [
                  TextSpan(text: 'After the free trial, you\'ll pay'),
                  TextSpan(
                      text: ' \$4.99/mo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
                onPressed: () async {
                  // * Set Onboarding Complete Pref
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setInt('initScreen', 1);
                  if (!mounted) return;
                  context.go('/');
                },
                child: const Text('No thanks.')),
            Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 36.0),
                child: Platform.isIOS
                    ? Text(
                        'Payment will be charged to your Apple ID account after 7 days. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.\n\nYou can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : Text(
                        'Payment will be charged to your Google Play account after 7 days. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.\n\nYou can manage and cancel your subscriptions by going to your account settings in the Google Play Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      )),
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
      child: Row(
        children: [
          Flexible(
            child: Icon(
              icon,
              size: iconSize,
              color: FlexColor.bahamaBlueDarkPrimaryVariant,
            ),
          ),
          Flexible(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text.rich(description),
              )),
        ],
      ),
    );
  }
}
