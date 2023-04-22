import 'package:flutter/material.dart';
import 'package:leggo/view/widgets/lists/create_list_dialog.dart';

class BlankCategoryCard extends StatelessWidget {
  const BlankCategoryCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 125,
              width: MediaQuery.of(context).size.width,
              child: Card(
                //   elevation: 2.0,
                //  color: FlexColor.deepBlueDarkSecondaryContainer,
                child: ListTile(
                  // trailing: SizedBox(
                  //   width: 40,
                  //   height: 40,
                  //   child: Icon(
                  //     Icons.more_vert_rounded,
                  //     color: Theme.of(context).brightness == Brightness.light
                  //         ? Colors.grey[800]
                  //         : Colors.white,
                  //   ),
                  // ),
                  minVerticalPadding: 24.0,
                  onTap: () async {
                    //context.read<SavedPlacesBloc>().add(LoadPlaces());
                    // context.go('/placeList-page');
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return const CreateListDialog();
                      },
                    );
                  },
                  contentPadding:
                      const EdgeInsets.fromLTRB(10.0, 12.0, 16.0, 12.0),
                  minLeadingWidth: 20,

                  //tileColor: categoryColor,
                  title: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10.0,
                    children: [
                      // placeList.icon != null
                      //     ? Icon(
                      //         placeList.icon,
                      //         size: 16,
                      //       )
                      //     : const SizedBox(),
                      Text(
                        'Create your first list!',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: const Text('Add a new list to get started.'),
                  leading: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 8.0),
                    child: SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.post_add_rounded,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.grey[800]
                                  : Colors.white,
                          size: 30,
                        )),
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
