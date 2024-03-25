import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _nextGroup = 1;
  List<Table> _tables = List.empty(growable: true);
  List<GroupPage> _groups = List.empty(growable: true);
  List<Player> _players = List.empty(growable: true);
  GroupPage? _currentGroup;

  final _playerNumberInputController = TextEditingController();
  final _tableCountController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _playerNumberInputController.dispose();
    super.dispose();
  }

  _createNextGroup() async {
    if (_tables.isEmpty) {
      _showTableAlert();
    }

    var group = GroupPage(
      groupNumber: _nextGroup,
      players: _players,
    );
    _groups.add(group);
    _currentGroup = group;
    print("Created new group number $_nextGroup");
    print("Number of groups: ${_groups.length}");
    _nextGroup++;
    setState(() {});
  }

  void _changeGroup(int jump) {
    print("Changing group!");
    print("Current + jump -> ${_currentGroup?.groupNumber} + ($jump)");
    var calculatedGroup = (_currentGroup!.groupNumber + jump);
    print("Calculated group: $calculatedGroup");
    if (calculatedGroup < 1) {
      _currentGroup = _groups[0];
      return;
    }
    if (calculatedGroup > _groups.length) {
      _currentGroup = _groups[_groups.length - 1];
      return;
    }
    _currentGroup = _groups[calculatedGroup - 1];
    setState(() {});
  }

  Future _showTableAlert() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Ile jest stołów do gry?"),
            content: TextField(controller: _tableCountController, decoration: const InputDecoration(hintText: "Liczba stołów")),
            actions: [
              TextButton(
                  onPressed: () => {
                        if (int.tryParse(_tableCountController.text) != null) {_generateTables(), Navigator.of(context).pop()}
                      },
                  child: Text("Ok"))
            ],
          ));
  void _generateTables() {
    var numberOfTables = _tableCountController.text;
    for (int i = 0; i <= int.parse(numberOfTables); i++) {
      _tables.add(Table(tableNumber: i));
    }
    print("Generated $numberOfTables tables");
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
                  onPressed: () => {_changeGroup(-1)},
                  child: const Icon(Icons.arrow_left),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 50),
                child: FloatingActionButton(
                  onPressed: () => {_changeGroup(1)},
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
              ),
              // SizedBox(
              //   width: 300,
              //   child: TextField(
              //       controller: _playerNumberInputController,
              //       decoration: InputDecoration(labelText: "Liczba zawodników"),
              //       keyboardType: TextInputType.number,
              //       inputFormatters: <TextInputFormatter>[
              //         FilteringTextInputFormatter.digitsOnly
              //       ], // Only numbers can be entered
              //     ),
              //   )
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
  var nameController = TextEditingController();
  var lastNameController = TextEditingController();

  void _addPlayer() {
    var name = nameController.text;
    var lname = lastNameController.text;
    var newPlayer = Player(name: name, lastName: lname, group: widget.groupNumber);
    widget.players.add(newPlayer);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          child: Text(
            "Grupa ${widget.groupNumber}",
            textScaler: TextScaler.linear(2.0),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Podaj nazwisko',
                  )),
            ),
            SizedBox(
              width: 300,
              child: TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Podaj nazwisko',
                  )),
            ),
            FloatingActionButton(
              onPressed: _addPlayer,
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: () => {}, // TODO end this
              child: Icon(Icons.shuffle),
            )
          ],
        ),
        ListView.builder(
          // Let the ListView know how many items it needs to build.
          itemCount: widget.players.where((e) => e.group == widget.groupNumber).length,
          shrinkWrap: true,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final p = widget.players.where((e) => e.group == widget.groupNumber).toList()[index];

            return Row(children: [
              Text("Gracz: ${p.name} ${p.lastName}"),
              TextButton(onPressed: () => {widget.players.remove(p), setState(() {})}, child: Text("Usuń"))
            ]);
          },
        ),
      ],
    );
  }
}

class Player {
  Player({required this.name, required this.lastName, this.ifPlaying = false, required this.group});

  final String name;
  final String lastName;
  final int group;
  bool ifPlaying;
  //final List<GamePlayed> gamesPlayed;
}

class Table {
  int tableNumber;
  bool isFree;
  Table({required this.tableNumber, this.isFree = false});
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
