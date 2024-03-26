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
  int _nextPage = 2;
  int _nextGroup = 1;
  List<Page> _pages = List.empty(growable: true);
  List<Player> _players = List.empty(growable: true);
  Page? _currentPage;
  bool _canModify = true;

  final _playerNumberInputController = TextEditingController();
  final _tableCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pages.add(MainPage(pageNumber: 1, setTables: _setTables));
    _currentPage = _pages[0];
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _playerNumberInputController.dispose();
    _tableCountController.dispose();
    super.dispose();
  }

  _createNextGroup() async {
    var group = GroupPage(
      groupNumber: _nextGroup,
      addPlayer: _addPlayer,
      removePlayer: _removePlayer,
      getPlayersFromGroup: _getPlayers,
      pageNumber: _nextPage,
    );
    _pages.add(group);
    _currentPage = group;
    print("Created new group number $_nextGroup");
    print("Number of groups/pages: ${_pages.length}");
    _nextGroup++;
    _nextPage++;
    setState(() {});
  }

  void _changeGroup(int jump) {
    print("Changing group!");
    print("Current + jump -> ${_currentPage?.pageNumber} + ($jump)");
    var calculatedPage = (_currentPage!.pageNumber + jump);
    print("Calculated group: $calculatedPage");
    if (calculatedPage < 1) {
      _currentPage = _pages[0];
      return;
    }
    if (calculatedPage > _pages.length) {
      _currentPage = _pages[_pages.length - 1];
      return;
    }
    _currentPage = _pages[calculatedPage - 1];
    setState(() {});
  }

  void _addPlayer(Player player) {
    if (_canModify) {
      _players.add(player);
    }
  }

  void _removePlayer(Player player) {
    if (_canModify) {
      _players.remove(player);
    }
  }

  void _setTables(int numberOfTables) {
    print("Setting tables...");
    var tablePage = TablePage(
      startGame: () => {}, // TODO end this
      numberOfTables: numberOfTables,
      getFreePlayers: _getFreePlayers,
      pageNumber: 1,
    );
    _pages[0] = tablePage;
    _currentPage = tablePage;
    setState(() {});
  }

  List<Player> _getFreePlayers() {
    return _players.where((e) => e.ifPlaying == false).toList();
  }

  List<Player> _getPlayers(int groupNumber) {
    return _players.where((e) => e.group == groupNumber).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("${widget.title} Page ${_currentPage?.pageNumber}/${_pages.length}"),
      ),
      body: Center(child: Container(margin: EdgeInsets.all(40), child: _currentPage)),
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

abstract class Page extends StatefulWidget {
  final int pageNumber;

  const Page({super.key, required this.pageNumber});
}

class MainPage extends Page {
  MainPage({required this.setTables, required super.pageNumber});

  final Function(int numberOfTables) setTables;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _tableInputController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _tableInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text("Podaj liczbę stołów do gry"),
        TextField(
          controller: _tableInputController,
          decoration: InputDecoration(labelText: "Liczba stołów"),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly], // Only numbers can be entered
        ),
        TextButton(onPressed: sendTableCount, child: Text("Ustaw stoły"))
      ],
    );
  }

  void sendTableCount() {
    print("Sending number of tables to the main widget. \nnumber of tables: ${_tableInputController.text}");
    widget.setTables(int.parse(_tableInputController.text));
  }
}

class GroupPage extends Page {
  GroupPage(
      {required this.groupNumber, required this.addPlayer, required this.getPlayersFromGroup, required this.removePlayer, required super.pageNumber});
  final int groupNumber;
  final Function(Player) addPlayer;
  final Function(Player) removePlayer;
  final Function(int) getPlayersFromGroup;
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
    widget.addPlayer(newPlayer);
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
          itemCount: widget.getPlayersFromGroup(widget.groupNumber).length,
          shrinkWrap: true,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final p = widget.getPlayersFromGroup(widget.groupNumber)[index];

            return Row(children: [
              Text("Gracz: ${p.name} ${p.lastName}"),
              TextButton(onPressed: () => {widget.removePlayer(p), setState(() {})}, child: Text("Usuń"))
            ]);
          },
        ),
      ],
    );
  }
}

class TablePage extends Page {
  final int numberOfTables;
  final Function() getFreePlayers;
  final Function() startGame;

  const TablePage({super.key, required this.numberOfTables, required this.getFreePlayers, required this.startGame, required super.pageNumber});
  @override
  State<StatefulWidget> createState() => _tablePageState();
}

class _tablePageState extends State<TablePage> {
  bool _gameStarted = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextButton(
            onPressed: null, // TODO end this
            child: Text("Start Game")),
        ListView.builder(
          itemCount: widget.numberOfTables,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            List<Player> freePlayers = widget.getFreePlayers();
            Player p1;
            Player p2;
            if (freePlayers.length < 2) {
              return Row(
                children: [Text("Pusty stół")],
              );
            } else {
              p1 = freePlayers[0];
              p2 = freePlayers[1];
            }
            return Row(children: [
              Text("Gracz: ${p1.name} ${p1.lastName} vs Gracz ${p2.name} ${p2.lastName}"),
            ]);
          },
        )
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
