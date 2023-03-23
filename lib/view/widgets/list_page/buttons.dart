import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/bloc/purchases/purchases_bloc.dart';
import 'package:leggo/bloc/place/edit_places_bloc.dart';
import 'package:leggo/cubit/cubit/random_wheel_cubit.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/view/widgets/lists/invite_dialog.dart';
import 'package:leggo/view/widgets/premium_offer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../model/place.dart';

class GoButton extends StatelessWidget {
  final List<Place>? places;
  const GoButton({
    Key? key,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        if (state is PurchasesLoading) {
          return LoadingAnimationWidget.staggeredDotsWave(
              color: FlexColor.bahamaBlueDarkSecondary, size: 20.0);
        }
        if (state is PurchasesLoaded) {
          if (state.isSubscribed != true) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Animate(
                effects: const [SlideEffect()],
                child: ElevatedButton(
                  onPressed: () async => await showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => const PremiumOffer(),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(60, 35),
                    minimumSize: const Size(30, 30),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 6.0),
                    child: Icon(
                      FontAwesomeIcons.dice,
                      size: 18,
                    ),
                  ),
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Animate(
              effects: const [SlideEffect()],
              child: ElevatedButton(
                onPressed: places != null
                    ? places!.isEmpty && places!.length < 2
                        ? () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                'Add at least two places!',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ))
                        : () {
                            context.read<RandomWheelCubit>().loadWheel(places!);
                            //context.goNamed('random-wheel');
                          }
                    : () {},
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 30),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 6.0),
                  child: Icon(
                    FontAwesomeIcons.dice,
                    size: 18,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Error!'),
          );
        }
      },
    );
  }
}

class InviteButton extends StatelessWidget {
  final PlaceList? placeList;
  const InviteButton({
    required this.placeList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchasesBloc, PurchasesState>(
      builder: (context, state) {
        if (state is PurchasesLoading) {
          return LoadingAnimationWidget.staggeredDotsWave(
              color: FlexColor.bahamaBlueDarkSecondary, size: 20.0);
        }
        if (state is PurchasesLoaded && state.isSubscribed == true) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Animate(
              effects: const [SlideEffect()],
              child: ElevatedButton(
                onPressed: placeList != null
                    ? () {
                        WidgetsBinding.instance
                            .addPostFrameCallback((timeStamp) async {
                          await showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (dialogContext) {
                              return InviteDialog(
                                  placeList: placeList!,
                                  dialogContext: dialogContext);
                            },
                          );
                        });
                        //context.goNamed('random-wheel');
                      }
                    : () {},
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 20),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.person_add_alt_rounded,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        }
        if (state is PurchasesLoaded && state.isSubscribed != true) {
          return Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Animate(
              effects: const [SlideEffect()],
              child: ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return const PremiumOffer();
                      },
                    );
                  });
                  //context.goNamed('random-wheel');
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 20),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.person_add_alt_rounded,
                    size: 20,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text('Error!'),
          );
        }
      },
    );
  }
}

class EditButton extends StatelessWidget {
  final PlaceList? placeList;
  final List<Place>? places;
  const EditButton({
    required this.places,
    required this.placeList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Animate(
        effects: const [SlideEffect()],
        child: BlocBuilder<EditPlacesBloc, EditPlacesState>(
          builder: (context, state) {
            if (state is EditPlacesStarted) {
              return ElevatedButton(
                onPressed: () {
                  context.read<EditPlacesBloc>().add(CancelEditing());
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      width: 2.0,
                      color: FlexColor.bahamaBlueDarkPrimaryContainer),
                  fixedSize: const Size(60, 35),
                  minimumSize: const Size(30, 20),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(right: 4.0),
                  child: Icon(
                    Icons.checklist_outlined,
                    size: 20,
                  ),
                ),
              );
            }
            return ElevatedButton(
              onPressed: places != null && places!.isEmpty
                  ? () =>
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          'Add a place first!',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ))
                  : () {
                      context.read<EditPlacesBloc>().add(StartEditing());
                    },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(60, 35),
                minimumSize: const Size(30, 20),
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 4.0),
                child: Icon(
                  Icons.checklist_outlined,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
