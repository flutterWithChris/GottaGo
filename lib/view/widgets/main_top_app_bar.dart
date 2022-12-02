import 'package:flutter/material.dart';
import 'package:leggo/main.dart';
import 'package:leggo/view/widgets/main_logo.dart';

class MainTopAppBar extends StatelessWidget {
  const MainTopAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      automaticallyImplyLeading: false,
      // leadingWidth: 0,
      centerTitle: true,
      // titleSpacing: 16.0,
      // leading: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //   child: IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Icons.menu),
      //   ),
      // ),
      title: const Padding(
        padding: EdgeInsets.only(right: 24.0),
        child: FractionallySizedBox(
            widthFactor: 0.4, child: FittedBox(child: MainLogo())),
      ),
      expandedHeight: 120,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: InboxButton(),
        ),
        // IconButton(
        //     onPressed: () {}, icon: const Icon(Icons.more_vert)),
        // IconButton(
        //     onPressed: () {
        //       context.read<LoginCubit>().logout();
        //     },
        //     icon: const Icon(Icons.logout_rounded)),
      ],
    );
  }
}
