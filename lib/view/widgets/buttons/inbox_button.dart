import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:leggo/bloc/bloc/invite_inbox/invite_inbox_bloc.dart';
import 'package:leggo/view/widgets/invites/invite_list.dart';

class InboxButton extends StatelessWidget {
  const InboxButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.topStart,
      children: [
        PopupMenuButton(
          // color: Colors.grey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          position: PopupMenuPosition.under,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: SizedBox(
                // height: 150,
                width: 300,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Invites',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: InviteList(),
                  )
                ]),
              ))
            ];
          },
          child: IgnorePointer(
            child: IconButton(
                onPressed: () {},
                icon: Icon(
                  FontAwesomeIcons.inbox,
                  size: 22,
                  color: Theme.of(context).iconTheme.color,
                )),
          ),
        ),
        BlocBuilder<InviteInboxBloc, InviteInboxState>(
          builder: (context, state) {
            if (state.status == InviteInboxStatus.loaded) {
              if (context.watch<InviteInboxBloc>().invites.isNotEmpty) {
                int inviteCount =
                    context.watch<InviteInboxBloc>().invites.length;
                return Animate(
                  effects: const [
                    ShakeEffect(
                        duration: Duration(seconds: 1),
                        hz: 2,
                        offset: Offset(-0.1, 1.0),
                        rotation: 1),
                    // ScaleEffect(),
                    // SlideEffect(
                    //   begin: Offset(0.5, 0.5),
                    //   end: Offset(0, 0),
                    // )
                  ],
                  child: Positioned(
                    top: 10,
                    left: 2,
                    child: CircleAvatar(
                      radius: 10.0,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        '$inviteCount',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white),
                      ),
                    ),
                  ),
                );
              }
            }
            return const SizedBox();
          },
        )
      ],
    );
  }
}
