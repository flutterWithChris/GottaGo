import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leggo/model/invite.dart';

import '../../../bloc/bloc/invite_inbox/invite_inbox_bloc.dart';

class CollabInvite extends StatelessWidget {
  const CollabInvite({
    Key? key,
    required this.thisInvite,
  }) : super(key: key);

  final Invite thisInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${thisInvite.inviterName.split(' ')[0]} ',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.blue),
                ),
                Text(
                  'invited you to:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: FittedBox(
                      child: Text(
                        thisInvite.placeListName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.all(0),
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(AcceptInvite(invite: thisInvite));
                        },
                        icon: Icon(
                          color: Colors.green.shade400,
                          Icons.check_circle_rounded,
                        ),
                      ),
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(DeclineInvite(invite: thisInvite));
                        },
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeclinedGroupInvite extends StatelessWidget {
  const DeclinedGroupInvite({
    Key? key,
    required this.thisInvite,
  }) : super(key: key);

  final Invite thisInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.cancel_rounded,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '${thisInvite.inviteeName.split(' ')[0]} ',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.blue),
                    ),
                    TextSpan(
                      text: 'declined your invite to:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Text(
                      thisInvite.placeListName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 1.0, top: 4.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(DeclineInvite(invite: thisInvite));
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AcceptedGroupInvite extends StatelessWidget {
  const AcceptedGroupInvite({
    Key? key,
    required this.thisInvite,
  }) : super(key: key);

  final Invite thisInvite;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade400,
                    size: 14,
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: '${thisInvite.inviteeName.split(' ')[0]} ',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(color: Colors.blue),
                    ),
                    TextSpan(
                      text: 'accepted your invite to:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ])),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FittedBox(
                    child: Text(
                      thisInvite.placeListName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 1.0, top: 4.0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        splashRadius: 18,
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          context
                              .read<InviteInboxBloc>()
                              .add(DeleteInvite(invite: thisInvite));
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
