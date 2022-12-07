import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/view/pages/signup.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumOffer extends StatefulWidget {
  const PremiumOffer({super.key});

  @override
  State<PremiumOffer> createState() => _PremiumOfferState();
}

class _PremiumOfferState extends State<PremiumOffer> {
  bool yearlySelected = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      builder: (context, controller) =>
          BlocBuilder<PurchasesBloc, PurchasesState>(
        builder: (context, state) {
          if (state is PurchasesLoading) {
            return LoadingAnimationWidget.staggeredDotsWave(
                color: FlexColor.bahamaBlueDarkSecondary, size: 30.0);
          }
          if (state is PurchasesLoaded &&
              state.customerInfo!.allPurchaseDates.isEmpty) {
            Offerings? offerings = state.offerings;
            Offering? monthlyOffer =
                state.offerings?.getOffering('premium_individual_monthly');
            return Padding(
              padding: const EdgeInsets.only(top: 36.0),
              child: Column(
                children: [
                  Text(
                    'Try Premium for Free!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        left: 24.0, right: 24.0, bottom: 12.0, top: 8.0),
                    child: Text.rich(
                      TextSpan(style: TextStyle(height: 1.618), children: [
                        TextSpan(text: 'Get a '),
                        TextSpan(
                            text: '7-day free trial ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: 'of all premium features.\nThen \$4.99/mo.')
                      ]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 1.65,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FeatureChecklistItem(
                              description: TextSpan(
                                  style: Theme.of(context).textTheme.titleSmall,
                                  children: const [
                                    TextSpan(
                                      text: 'Invite friends ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
                            //         Text(
                            //           'Monthly (${monthlyOffer!.monthly!.storeProduct.priceString})',
                            //           style: const TextStyle(
                            //               fontWeight: FontWeight.bold),
                            //         ),
                            //         Switch.adaptive(
                            //           value: yearlySelected,
                            //           onChanged: (value) => setState(() {
                            //             yearlySelected = value;
                            //           }),
                            //         ),
                            //         const Text(
                            //           'Yearly (\$29.99)',
                            //           style: TextStyle(
                            //               fontWeight: FontWeight.bold),
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
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(200, 30)),
                            onPressed: () async {
                              Package package =
                                  monthlyOffer!.getPackage('\$rc_monthly')!;
                              context
                                  .read<PurchasesBloc>()
                                  .add(AddPurchase(package: package));
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50)),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Colors.blue.shade300,
                              ),
                            ),
                            label: const Text('Count Me In!')),
                        TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            child: const Text('I don\'t like free stuff.')),
                      ],
                    ),
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
    );
  }
}
