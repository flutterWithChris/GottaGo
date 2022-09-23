import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/model/place_list.dart';

class DeleteListDialog extends StatefulWidget {
  const DeleteListDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<DeleteListDialog> createState() => _DeleteListDialogState();
}

class _DeleteListDialogState extends State<DeleteListDialog> {
  bool buttonEnabled = false;
  final TextEditingController deleteConfirmFieldController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 250,
        width: 350,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Delete List?',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 270,
              height: 60,
              child: TextField(
                onChanged: (value) {
                  if (value == 'Breakfast Ideas') {
                    setState(() {
                      buttonEnabled = true;
                    });
                  }
                },
                controller: deleteConfirmFieldController,
                autofocus: true,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).highlightColor,
                            width: 1.0),
                        borderRadius: BorderRadius.circular(24.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(20.0)),
                    //  prefixIcon: const Icon(Icons.lock),
                    hintText: "Type 'Breakfast Ideas'"),
              ),
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: buttonEnabled
                    ? () {
                        if (deleteConfirmFieldController.text.isNotEmpty) {
                          context.read<SavedListsBloc>().add(RemoveList(
                              placeList: PlaceList(
                                  listOwnerId:
                                      FirebaseAuth.instance.currentUser!.uid,
                                  name: deleteConfirmFieldController.text)));
                          Navigator.pop(context);
                        }
                      }
                    : null,
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete Forever')),
          ],
        ),
      ),
    );
  }
}
