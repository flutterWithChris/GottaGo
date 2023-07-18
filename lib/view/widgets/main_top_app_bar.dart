import 'package:flutter/material.dart';
import 'package:leggo/view/widgets/buttons/inbox_button.dart';
import 'package:leggo/view/widgets/main_logo.dart';

class MainTopAppBar extends StatelessWidget {
  const MainTopAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.medium(
      centerTitle: true,
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
      ],
    );
  }
}

class MainTopAppBarSmall extends StatelessWidget {
  const MainTopAppBarSmall({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      centerTitle: true,
      title: Padding(
        padding: EdgeInsets.only(right: 24.0),
        child: FractionallySizedBox(
            widthFactor: 0.4, child: FittedBox(child: MainLogo())),
      ),
      expandedHeight: 60,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: InboxButton(),
        ),
      ],
    );
  }
}
