import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/saved_categories/bloc/saved_lists_bloc.dart';
import 'package:leggo/model/place_list.dart';

class DeleteListDialog extends StatefulWidget {
  final PlaceList placeList;
  const DeleteListDialog({
    required this.placeList,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: SizedBox(
          height: 190,
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Confirm Deletion',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Are you sure you want to delete '),
                      TextSpan(
                          text: widget.placeList.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '?'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // SizedBox(
              //   width: 270,
              //   height: 60,
              //   child: TextField(
              //     onChanged: (value) {
              //       if (value == widget.placeList.name) {
              //         setState(() {
              //           buttonEnabled = true;
              //         });
              //       }
              //     },
              //     controller: deleteConfirmFieldController,
              //     autofocus: true,
              //     decoration: InputDecoration(
              //         enabledBorder: OutlineInputBorder(
              //             borderSide: BorderSide(
              //                 color: Theme.of(context).highlightColor,
              //                 width: 1.0),
              //             borderRadius: BorderRadius.circular(24.0)),
              //         focusedBorder: OutlineInputBorder(
              //             borderSide: BorderSide(
              //                 color: Theme.of(context).primaryColor, width: 2.0),
              //             borderRadius: BorderRadius.circular(20.0)),
              //         //  prefixIcon: const Icon(Icons.lock),
              //         hintText: "Type '${widget.placeList.name}' to confirm..."),
              //   ),
              // ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    context
                        .read<SavedListsBloc>()
                        .add(RemoveList(placeList: widget.placeList));
                    Navigator.pop(context);
                  },
                  // onPressed: buttonEnabled
                  //     ? () {
                  //         if (deleteConfirmFieldController.text.isNotEmpty) {
                  //           context
                  //               .read<SavedListsBloc>()
                  //               .add(RemoveList(placeList: widget.placeList));
                  //           Navigator.pop(context);
                  //         }
                  //       }
                  //     : null,
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Delete Forever')),
              const Text(
                '(Can\'t be undone.)',
                style: TextStyle(fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
      ),
    );
  }
}
