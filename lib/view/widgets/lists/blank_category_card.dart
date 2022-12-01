import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';

class BlankCategoryCard extends StatelessWidget {
  const BlankCategoryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 4.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 1.618,
                //color: FlexColor.materialDarkPrimaryContainerHc,
                child: ListTile(
                  minVerticalPadding: 30.0,
                  onTap: () {
                    //context.read<SavedPlacesBloc>().add(LoadPlaces());
                    // context.go('/placeList-page');
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const CreateListDialog();
                      },
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  minLeadingWidth: 20,

                  //tileColor: categoryColor,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10.0,
                    children: [
                      const Icon(
                        FontAwesomeIcons.list,
                        size: 18,
                      ),
                      Text(
                        'Create a List',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // subtitle: const Padding(
                  //   padding: EdgeInsets.only(left: 24.0),
                  //   child: Text('0 Saved Places'),
                  // ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: SizedBox(
                      child: Stack(clipBehavior: Clip.none, children: [
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: Container(
                                  color: FlexColor
                                      .materialDarkTertiaryContainerHc),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Container(
                                color: FlexColor.materialDarkSecondaryHc),
                          ),
                        ),
                      ]),
                    ),
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
