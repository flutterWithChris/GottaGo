import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/bloc/bloc/invite_inbox/invite_inbox_bloc.dart';
import 'package:leggo/model/invite.dart';
import 'package:leggo/view/widgets/invites/invites.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class InviteList extends StatelessWidget {
  const InviteList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InviteInboxBloc, InviteInboxState>(
      builder: (context, state) {
        if (state.status == InviteInboxStatus.loading) {
          return LoadingAnimationWidget.fourRotatingDots(
              color: Colors.blue, size: 20.0);
        }
        if (state.status == InviteInboxStatus.accepted) {
          return Center(
            child: Wrap(
              spacing: 8.0,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade400,
                ),
                const Text('Invite Accepted'),
              ],
            ),
          );
        }
        if (state.status == InviteInboxStatus.declined) {
          return Center(
            child: Wrap(
              spacing: 8.0,
              children: const [
                Icon(
                  Icons.remove_circle_rounded,
                  color: Colors.redAccent,
                ),
                Text('Invite Declined'),
              ],
            ),
          );
        }
        if (state.status == InviteInboxStatus.loaded) {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: state.invites!.isNotEmpty ? state.invites!.length : 1,
              itemBuilder: (context, index) {
                if (state.invites!.isNotEmpty) {
                  Invite thisInvite = state.invites![index];
                  if (thisInvite.inviteStatus == 'declined') {
                    return DeclinedGroupInvite(thisInvite: thisInvite);
                  }
                  if (thisInvite.inviteStatus == 'accepted') {
                    return AcceptedGroupInvite(thisInvite: thisInvite);
                  } else {
                    return CollabInvite(thisInvite: thisInvite);
                  }
                }
                return SizedBox(
                  height: 100,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 36.0),
                      child: Text(
                        'No Invites!',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                );
              });
        } else {
          return const Center(
            child: Text('Something Went Wrong..'),
          );
        }
      },
    );
  }
}
