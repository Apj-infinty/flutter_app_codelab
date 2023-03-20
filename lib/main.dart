import 'dart:async';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  //fav button
  var fav = <WordPair>[];

  void toggleFav() {
    if (fav.contains(current)) {
      fav.remove(current);
    } else {
      fav.add(current);
    }
    notifyListeners();
  }
}

//split homepage into two
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Generator();
        break;
      case 1:
        page = FavouritesPage();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = FindUs();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text(
                      'Home',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 22,
                      ),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text(
                      'Favorites',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 22,
                      ),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.my_library_add),
                    label: Text(
                      'Library',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 22,
                      ),
                    ),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.map),
                    label: Text(
                      'Find Us',
                      style: TextStyle(
                        fontFamily: 'MontserratAlternates',
                        fontSize: 22,
                      ),
                    ),
                  )
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class Generator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    //icon
    IconData icon;
    if (appState.fav.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text('A random amazing idea: '),
          BigCard(pair: pair),
          SizedBox(height: 10),
          //button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFav();
                },
                icon: Icon(icon),
                label: Text(
                  'like',
                  style: TextStyle(
                    fontFamily: 'MontserratAlternates',
                    fontSize: 22,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text(
                  'next',
                  style: TextStyle(
                      fontFamily: 'MontserratAlternates', fontSize: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    if (appState.fav.isEmpty) {
      return Center(
        child: Text('No favourites yet!'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.fav.length} favourites'),
        ),
        for (var pair in appState.fav)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// ignore: must_be_immutable
class FindUs extends StatelessWidget {
  late GoogleMapController mapController;
  List <Marker>_markers=[];
  final List<Marker> marker = const [
    Marker(
        markerId: MarkerId("Kochi"),
        position: LatLng(9.9312, 76.2673),
        infoWindow: InfoWindow(
          title: "Kochi",
        )),
    Marker(
        markerId: MarkerId("Trivandrum"),
        position: LatLng(8.5241, 76.9366),
        infoWindow: InfoWindow(
          title: "Trivandrum",
        )),
    Marker(
        markerId: MarkerId("Goa"),
        position: LatLng(15.2993, 74.1240),
        infoWindow: InfoWindow(
          title: "Goa",
        )),
    Marker(
        markerId: MarkerId("Alappuzha"),
        position: LatLng(9.4981, 76.3388),
        infoWindow: InfoWindow(
          title: "Alappuzha",
        ))
  ];

   void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _markers.addAll(marker);

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          title: const Text(
            'Our Offices',
            style: TextStyle(
              fontFamily: 'MontserratAlternates',
              fontSize: 22,
            ),
          ),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(9.9312, 76.2673),
            zoom: 7,
          ),
          markers: Set.of(marker) ,
        ),
      ),
    );
  }
}
