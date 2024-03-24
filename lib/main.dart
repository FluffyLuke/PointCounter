import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:popover/popover.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const PointCounter(title: 'Point counter'),
    );
  }
}

class PointCounter extends StatefulWidget {
  const PointCounter({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PointCounter> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<PointCounter> {
  int _currentPage = 1;
  int _numberOfPages = 1;
  int _nextPage = 1;
  List<GroupPage> _groups = List.empty(growable: true);
  GroupPage? _currentGroup;

  void _incrementCounter() {
    setState(() {});
  }

  void _createNextGroup() {
    showPopover(
      context: context,
      bodyBuilder: 
      );

    var group = GroupPage(groupNumber: _nextPage);
    _groups.add(group);
    _currentGroup = group;
    print("Created new group number $_nextPage");
    print("Number of groups: ${_groups.length}");
    _nextPage++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: Container(margin: EdgeInsets.all(40), child: _currentGroup)),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: 10),
                child: FloatingActionButton(
                  onPressed: _incrementCounter,
                  child: const Icon(Icons.arrow_left),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 50),
                child: FloatingActionButton(
                  onPressed: _incrementCounter,
                  child: const Icon(Icons.arrow_right),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 50, right: 20),
                child: FloatingActionButton(
                  onPressed: _createNextGroup,
                  backgroundColor: Color.fromRGBO(0, 0, 0, 1),
                  child: const Icon(
                    Icons.add,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              )
            ],
          )),
    );
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required this.groupNumber, required this.players});

  final int groupNumber;
  final List<Player> players;
  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Column(),
      ),
      body: Text("Group: ${widget.groupNumber}"),
    );
  }
}

class Player {
  const Player({required this.name, required this.lastName});

  final String name;
  final String lastName;
  //final List<GamePlayed> gamesPlayed;
}

// class GamePlayed {
//   GamePlayed({required this.player1, required this.player2});
//   Player player1;
//   Player player2;
//   List<(Set, Set)> setsPlayed = List.empty();

//   void addSet(Set set) {
//     if
//   }
// }

// class Set {
//   Set({required this.smallPoints, required this.bigPoints});
//   int smallPoints;
//   int bigPoints;
// }
