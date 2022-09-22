import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/model/place_list.dart';

class InviteDialog extends StatelessWidget {
  final PlaceList placeList;
  const InviteDialog({
    Key? key,
    required this.placeList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailFieldController = TextEditingController();
    return Dialog(
      //backgroundColor: FlexColor.,
      child: SizedBox(
        height: 275,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Invite Contributor',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Text('Enter their email address.'),
            const SizedBox(
              height: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: emailFieldController,
                autofocus: true,
                decoration: InputDecoration(
                    filled: true,
                    label: const Text("Email Address"),
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0)
                      // backgroundColor: FlexColor.espressoDarkTertiary,
                      ),
                  onPressed: () {
                    print(
                        'PlaceList Added: ${emailFieldController.value.text}');
                    context.read<SavedListsBloc>().add(AddList(
                            placeList: PlaceList(
                          listOwnerId: FirebaseAuth.instance.currentUser!.uid,
                          name: emailFieldController.value.text,
                        )));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text.rich(TextSpan(children: [
                    const TextSpan(text: 'Invite to '),
                    TextSpan(
                        text: placeList.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis)),
                  ]))),
            )
          ],
        ),
      ),
    );
  }
}
