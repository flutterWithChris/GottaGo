import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:leggo/bloc/bloc/place_search_bloc.dart';
import 'package:leggo/category_page.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

final router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
      name: '/',
      path: '/',
      pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const MyHomePage(
            title: 'Leggo',
          )),
      routes: [
        GoRoute(
          path: 'category-page',
          pageBuilder: (context, state) => MaterialPage<void>(
              key: state.pageKey, child: const CategoryPage()),
        )
      ]),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaceSearchBloc(),
      child: MaterialApp.router(
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.aquaBlue,
          useMaterial3: true,
          useMaterial3ErrorColors: true,
        ),
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        routerDelegate: router.routerDelegate,
        title: 'Flutter Demo',
        theme: FlexThemeData.light(
            scheme: FlexScheme.aquaBlue, useMaterial3: true),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.medium(
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
              ),
              title: const Text('Leggo'),
              expandedHeight: 120,
              actions: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
              ],
            ),
            const CategoryCard(
              categoryIcon: FontAwesomeIcons.egg,
              categoryTitle: 'Breakfast',
              totalPlaces: 13,
              openPlaces: 9,
              categoryColor: Color(0xffB8E1FF),
            ),
            const CategoryCard(
              categoryIcon: FontAwesomeIcons.bowlFood,
              categoryTitle: 'Lunch',
              totalPlaces: 20,
              openPlaces: 11,
              categoryColor: Color(0xff94FBAB),
            ),
            const CategoryCard(
              categoryIcon: FontAwesomeIcons.utensils,
              categoryTitle: 'Dinner',
              totalPlaces: 40,
              openPlaces: 21,
              categoryColor: Color(0xffBCB6FF),
            ),
            const CategoryCard(
              categoryIcon: FontAwesomeIcons.iceCream,
              categoryTitle: 'Dessert',
              totalPlaces: 18,
              openPlaces: 7,
              categoryColor: Color(0xff82ABA1),
            ),
            const CategoryCard(
              categoryIcon: FontAwesomeIcons.earthAmericas,
              categoryTitle: 'Travel',
              totalPlaces: 23,
              openPlaces: 14,
              categoryColor: Color(0xffB8E1FF),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData? categoryIcon;
  final Color categoryColor;
  final String categoryTitle;
  final int totalPlaces;
  final int openPlaces;
  const CategoryCard({
    Key? key,
    this.categoryIcon,
    required this.categoryColor,
    required this.categoryTitle,
    required this.totalPlaces,
    required this.openPlaces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10.0,
                children: [
                  categoryIcon != null
                      ? Icon(
                          categoryIcon,
                          size: 18,
                        )
                      : const SizedBox(),
                  Text(
                    '$categoryTitle >',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  onTap: () {
                    context.go('/category-page');
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  minLeadingWidth: 40,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  //tileColor: categoryColor,
                  title: Text('$totalPlaces Saved Places'),
                  subtitle: Text('$openPlaces Open Now'),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned(
                        right: 20,
                        bottom: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: SizedBox(
                            height: 42,
                            width: 42,
                            child: Image.network(
                              'https://www.google.com/maps/uv?pb=!1s0x89e8287866d3ffff:0xa6734768501a1e3f!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe%3Dw258-h160-k-no!5shatch+huntington+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipNcnaL0OxmWX4zTLo_frU6Pa7eqglkMZcEcK9xe&hl=en&sa=X&ved=2ahUKEwiwmoaj84D6AhWWkIkEHfHKDhUQoip6BAhREAM',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: SizedBox(
                          height: 42,
                          width: 42,
                          child: Image.network(
                            'https://www.google.com/maps/uv?pb=!1s0x89e82b9897a768f9:0x2853132db2dacf1b!3m1!7e115!4shttps://lh5.googleusercontent.com/p/AF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur%3Dw168-h160-k-no!5sdown+diner+-+Google+Search!15zQ2dJZ0FRPT0&imagekey=!1e10!2sAF1QipPYj58DyJv2NTqWJItryUFImbcTUfqe67FHBrur&hl=en&sa=X&ved=2ahUKEwjwieGP9ID6AhVslokEHRRnBuIQoip6BAhnEAM',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
