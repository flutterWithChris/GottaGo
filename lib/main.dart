import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
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
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
      title: 'Flutter Demo',
      theme: ThemeData.from(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          //primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
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
            categoryTitle: 'Breakfast',
            totalPlaces: 13,
            openPlaces: 9,
            categoryColor: Color(0xffB8E1FF),
          ),
          const CategoryCard(
            categoryTitle: 'Lunch',
            totalPlaces: 20,
            openPlaces: 11,
            categoryColor: Color(0xff94FBAB),
          ),
          const CategoryCard(
            categoryTitle: 'Dinner',
            totalPlaces: 40,
            openPlaces: 21,
            categoryColor: Color(0xffBCB6FF),
          ),
          const CategoryCard(
            categoryTitle: 'Dessert',
            totalPlaces: 18,
            openPlaces: 7,
            categoryColor: Color(0xff82ABA1),
          ),
          const CategoryCard(
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Color categoryColor;
  final String categoryTitle;
  final int totalPlaces;
  final int openPlaces;
  const CategoryCard({
    Key? key,
    required this.categoryColor,
    required this.categoryTitle,
    required this.totalPlaces,
    required this.openPlaces,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '$categoryTitle >',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  context.go('/category-page');
                },
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 24.0),
                minLeadingWidth: 40,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                tileColor: categoryColor,
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
          ],
        ),
      ),
    ));
  }
}
