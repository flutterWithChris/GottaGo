import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/saved_places/bloc/saved_places_bloc.dart';
import 'package:leggo/model/place_list.dart';
import 'package:leggo/widgets/lists/delete_list_dialog.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CategoryCard extends StatelessWidget {
  final PlaceList placeList;

  const CategoryCard({
    Key? key,
    required this.placeList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                //color: FlexColor.deepBlueDarkPrimaryContainer.withOpacity(0.15),
                child: ListTile(
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PopupMenuButton(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        // onSelected: (value) {},
                        icon: const Icon(Icons.more_vert_rounded),
                        itemBuilder: (context) => <PopupMenuEntry>[
                              PopupMenuItem(
                                  onTap: () {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((timeStamp) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DeleteListDialog(
                                            placeList: placeList,
                                          );
                                        },
                                      );
                                    });
                                  },
                                  child: const Text('Delete List'))
                            ]),
                  ),
                  onTap: () {
                    context
                        .read<SavedPlacesBloc>()
                        .add(LoadPlaces(placeList: placeList));
                    context.go('/home/placeList-page');
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 24.0),
                  minLeadingWidth: 20,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      children: [
                        placeList.icon != null
                            ? Icon(
                                placeList.icon,
                                size: 18,
                              )
                            : Icon(
                                FontAwesomeIcons.earthAmericas,
                                size: 16,
                                color: Theme.of(context).iconTheme.color,
                              ),
                        Text(
                          placeList.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 23.0),
                    child: Wrap(
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '${placeList.placeCount} ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' Saved Places'),
                        ])),
                      ],
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        right: 20,
                        bottom: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://www.google.com/maps/uv?pb=!1s0x89e8287866d3ffff:0xa6734768501a1e3f!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe%3Dw258-h160-k-no!5shatch+huntington+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe&hl=en&sa=X&ved=2ahUKEwiwmoaj84D6AhWWkIkEHfHKDhUQoip6BAhREAM',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://www.google.com/maps/uv?pb=!1s0x89e82b9897a768f9:0x2853132db2dacf1b!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur%3Dw168-h160-k-no!5sdown+diner+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur&hl=en&sa=X&ved=2ahUKEwjwieGP9ID6AhVslokEHRRnBuIQoip6BAhnEAM',
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return LoadingAnimationWidget.discreteCircle(
                                  color: Theme.of(context).primaryColor,
                                  size: 18.0);
                            },
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
