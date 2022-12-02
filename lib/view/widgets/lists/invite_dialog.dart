import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/bloc/invite/bloc/invite_bloc.dart';
import 'package:leggo/model/place_list.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../bloc/bloc/invite_inbox/invite_inbox_bloc.dart';

class InviteDialog extends StatelessWidget {
  final PlaceList placeList;
  final BuildContext dialogContext;
  const InviteDialog({
    Key? key,
    required this.dialogContext,
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
              'Invite a Collaborator',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 12.0,
            ),
            const Text('Enter their username to send an invite!'),
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
                    label: const Text("Username"),
                    prefix: const Text('@'),
                    hintText: 'yourfriend',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: BlocConsumer<InviteBloc, InviteState>(
                listener: (context, state) async {
                  if (state.status == InviteStatus.sent) {
                    context.read<InviteInboxBloc>().add(LoadInvites());
                    await Future.delayed(const Duration(seconds: 2),
                        () => Navigator.pop(context));
                  }
                },
                builder: (context, state) {
                  if (state.status == InviteStatus.sending) {
                    return LoadingAnimationWidget.staggeredDotsWave(
                        color: FlexColor.bahamaBlueDarkSecondary, size: 20.0);
                  }
                  if (state.status == InviteStatus.sent) {
                    return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0)
                            // backgroundColor: FlexColor.espressoDarkTertiary,
                            ),
                        onPressed: () {},
                        icon: Icon(
                          Icons.check,
                          color: Colors.green.shade400,
                        ),
                        label: const Text.rich(TextSpan(children: [
                          TextSpan(text: 'Invite Sent! '),
                        ])));
                  }
                  if (state.status == InviteStatus.initial) {
                    return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0)
                            // backgroundColor: FlexColor.espressoDarkTertiary,
                            ),
                        onPressed: () {
                          print(
                              'PlaceList Added: ${emailFieldController.value.text}');
                          context.read<InviteBloc>().add(SendInvite(
                              placeList: placeList,
                              userName: emailFieldController.value.text));
                          //Navigator.pop(context);
                        },
                        icon: const Icon(Icons.person_add_alt_1_outlined),
                        label: Text.rich(TextSpan(children: [
                          const TextSpan(text: 'Invite to '),
                          TextSpan(
                              text: placeList.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis)),
                        ])));
                  }
                  if (state.status == InviteStatus.failed) {
                    return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0)
                            // backgroundColor: FlexColor.espressoDarkTertiary,
                            ),
                        onPressed: () {},
                        icon: const Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        label: const Text.rich(TextSpan(children: [
                          TextSpan(text: 'User Not Found!'),
                        ])));
                  } else {
                    return const Center(
                      child: Text('Something Went Wrong...'),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
