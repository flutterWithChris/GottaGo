import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/globals.dart';
import 'package:leggo/view/widgets/main_bottom_navbar.dart';
import 'package:leggo/view/widgets/main_top_app_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import 'package:purchases_flutter/models/store_product_wrapper.dart';

class MySubscription extends StatelessWidget {
  const MySubscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MainBottomNavBar(),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          const MainTopAppBar(),
          BlocBuilder<PurchasesBloc, PurchasesState>(
            builder: (context, state) {
              if (state is PurchasesLoading || state is PurchasesUpdated) {
                return SliverFillRemaining(
                  child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                          color: FlexColor.bahamaBlueDarkSecondary,
                          size: 20.0)),
                );
              }
              if (state is PurchasesLoaded && state.isSubscribed == true) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'My Subscription',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  context
                                      .read<PurchasesBloc>()
                                      .add(RestorePurchases());
                                },
                                child: Wrap(
                                  spacing: 4.0,
                                  children: const [
                                    Icon(
                                      Icons.restart_alt_outlined,
                                      size: 20,
                                    ),
                                    Text('Restore Purchases'),
                                  ],
                                ))
                          ],
                        ),
                        for (StoreProduct product in state.products!)
                          SizedBox(
                              height: 120,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product.title.split('(')[0],
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(product.priceString),
                                          ],
                                        ),
                                        Row(
                                          children: const [
                                            Text('Status: Active')
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await launchWebView(Uri.parse(
                                      'https://www.termsfeed.com/live/80c41a79-6cf2-404c-9daa-b469b07a7c58'));
                                },
                                child: const Text('Privacy Policy')),
                            TextButton(
                                onPressed: () async {
                                  await launchWebView(Uri.parse(
                                      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                                },
                                child: const Text('Terms & Conditions')),
                          ],
                        ),
                        Platform.isIOS
                            ? const Text(
                                'To manage your subscription visit your Apple subscription settings.',
                                textAlign: TextAlign.center,
                              )
                            : const Text(
                                'To manage your subscription visit your Google Play subscription settings.',
                                textAlign: TextAlign.center,
                              )
                      ],
                    ),
                  ),
                );
              }
              if (state is PurchasesLoaded && state.isSubscribed != true) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'My Subscription',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  context
                                      .read<PurchasesBloc>()
                                      .add(RestorePurchases());
                                },
                                child: Wrap(
                                  spacing: 4.0,
                                  children: const [
                                    Icon(
                                      Icons.restart_alt_outlined,
                                      size: 20,
                                    ),
                                    Text('Restore Purchases'),
                                  ],
                                ))
                          ],
                        ),
                        SizedBox(
                            height: 120,
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('No Active Subscription!'),
                                    ElevatedButton(
                                        onPressed: () {
                                          Package? package = state.offerings!
                                              .getOffering(
                                                  'premium_individual_monthly')!
                                              .getPackage('\$rc_monthly');
                                          context.read<PurchasesBloc>().add(
                                              AddPurchase(package: package!));
                                        },
                                        child: const Text('Subscribe Now'))
                                  ],
                                ),
                              ),
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await launchWebView(Uri.parse(
                                      'https://www.termsfeed.com/live/80c41a79-6cf2-404c-9daa-b469b07a7c58'));
                                },
                                child: const Text('Privacy Policy')),
                            TextButton(
                                onPressed: () async {
                                  await launchWebView(Uri.parse(
                                      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                                },
                                child: const Text('Terms & Conditions')),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Something Went Wrong...'),
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
