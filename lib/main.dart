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
  Options _options = Options();

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

  _createNextGroup() {
    // Sometimes main widget does not get refreshed when game is starting.
    // In such case check and refresh.
    if (_options.gameStarted) {
      setState(() {});
      return;
    }
    var group = GroupPage(
      groupNumber: _nextGroup,
      addPlayer: _addPlayer,
      removePlayer: _removePlayer,
      getPlayersFromGroup: _getPlayers,
      pageNumber: _nextPage,
      options: _options,
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
    //print("Changing group!");
    //print("Current + jump -> ${_currentPage?.pageNumber} + ($jump)");
    var calculatedPage = (_currentPage!.pageNumber + jump);
    //print("Calculated group: $calculatedPage");
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
    if (!_options.gameStarted) {
      _players.add(player);
    }
  }

  void _removePlayer(Player player) {
    if (!_options.gameStarted) {
      _players.remove(player);
    }
  }

  void _setTables(int numberOfTables) {
    print("Setting tables...");
    var tablePage = TablePage(
      numberOfTables: numberOfTables,
      options: _options,
      getFreePlayers: _getFreePlayers,
      pageNumber: 1,
    );
    _pages[0] = tablePage;
    _currentPage = tablePage;
    setState(() {});
  }

  List<Player> _getFreePlayers() {
    return _players.where((e) => e.currentGame == null).toList();
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
                  onPressed: _options.gameStarted ? null : _createNextGroup,
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
      {required this.options,
      required this.groupNumber,
      required this.addPlayer,
      required this.getPlayersFromGroup,
      required this.removePlayer,
      required super.pageNumber});
  final int groupNumber;
  final Function(Player) addPlayer;
  final Function(Player) removePlayer;
  final Function(int) getPlayersFromGroup;
  final Options options;
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
              onPressed: widget.options.gameStarted ? null : _addPlayer,
              child: Icon(Icons.add),
            ),
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
  final Function() getFreePlayers;
  final Options options;
  final List<Table> tables = List.empty(growable: true);

  TablePage({super.key, required this.getFreePlayers, required this.options, required super.pageNumber, required int numberOfTables}) {
    for (int i = 0; i < numberOfTables; i++) {
      tables.add(Table(tableNumber: i + 1));
    }
  }
  @override
  State<StatefulWidget> createState() => _tablePageState();
}

class _tablePageState extends State<TablePage> {
  @override
  void initState() {
    super.initState();
    _setPlayersGames();
  }

  var _smallPointsController1 = TextEditingController();
  var _smallPointsController2 = TextEditingController();
  var _bigPointsController1 = TextEditingController();
  var _bigPointsController2 = TextEditingController();

  void _setPlayersGames() {
    for (Table table in widget.tables) {
      if (!table.isFree) {
        continue;
      }
      var result = _generateMatchup();
      if (result == null) {
        continue;
      }
      Player p1 = result.$1;
      Player p2 = result.$2;
      table.p1 = p1;
      table.p2 = p2;
    }
    setState(() {});
  }

  void _addRoundToPlayers(Player p1, Player p2) {
    if (p1.currentGame == null) {
      throw Exception("Player1 is not in game");
    }
    if (p2.currentGame == null) {
      throw Exception("Player2 is not in game");
    }
    if (p1.currentGame != p2.currentGame) {
      throw Exception("Players are in two different games");
    }
    Round round1 = Round(smallPoints: int.parse(_smallPointsController1.text), bigPoints: int.parse(_bigPointsController1.text));
    Round round2 = Round(smallPoints: int.parse(_smallPointsController2.text), bigPoints: int.parse(_bigPointsController2.text));
    p1.currentGame?.addRound(round1, round2);
    if (p1.currentGame?.checkIfGameOver() != null) {
      print("Game is over for player ${p1.name} and ${p2.name}");
      p1.gamesPlayed.add(p1.currentGame!);
      p1.currentGame = null;
      p2.gamesPlayed.add(p2.currentGame!);
      p2.currentGame = null;
      bool foundPlayerFlag = false;
      for (Table table in widget.tables) {
        if (table.p1 == p1 && table.p2 == p2) {
          foundPlayerFlag = true;
          table.setFree();
          break;
        }
      }
      if (!foundPlayerFlag) {
        throw Exception("Cound not find the table with players");
      }
    }
    print("Added new round to player ${p1.name} and ${p2.name}");
    _setPlayersGames();
  }

  (Player p1, Player p2)? _generateMatchup() {
    List<Player> freePlayers = widget.getFreePlayers();
    Player p1;
    Player p2;
    if (freePlayers.length < 2) {
      return null;
    }
    p1 = freePlayers[0];
    p2 = freePlayers[1];

    if (p1.currentGame != null) {
      throw Exception("Player ${p1.name} ${p1.lastName} is free, but is in an active game at the same time");
    }
    if (p2.currentGame != null) {
      throw Exception("Player ${p2.name} ${p2.lastName} is free, but is in an active game at the same time");
    }

    GamePlayed newGame = GamePlayed(player1: p1, player2: p2);
    p1.currentGame = newGame;
    p2.currentGame = newGame;
    return (p1, p2);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextButton(onPressed: widget.options.gameStarted ? null : startGame, child: Text("Start Game")),
        ListView.builder(
          itemCount: widget.tables.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var currentTable = widget.tables[index];
            //print("is table number ${currentTable.tableNumber} free: ${currentTable.isFree}");
            var emptyTableMessage = "Pusty stół numer ${index + 1}";

            // Check if game has started
            if (!widget.options.gameStarted) {
              return Row(
                children: [Text(emptyTableMessage)],
              );
            }

            // Check if table is occupied
            if (!currentTable.isFree) {
              String? matchup = currentTable.getCurrentMatchup();
              matchup ??= emptyTableMessage;
              return Row(
                children: [Text(matchup)],
              );
            }

            String? matchup = currentTable.getCurrentMatchup();
            matchup ??= emptyTableMessage;

            return Row(children: [
              Text(matchup),
              TextButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Dodaj punkty"),
                          actions: [
                            TextButton(
                                onPressed: () => {Navigator.of(context).pop(), _addRoundToPlayers(currentTable.p1!, currentTable.p2!)},
                                child: Text("Dodaj punkty"))
                          ],
                          content: Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: 300,
                                    width: 500,
                                    child: TextFormField(
                                        controller: _bigPointsController1,
                                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Podaj duże punkty dla gracza ${currentTable.p1?.name} ${currentTable.p1?.lastName}',
                                        )),
                                  ),
                                  SizedBox(
                                    height: 300,
                                    width: 500,
                                    child: TextFormField(
                                        controller: _smallPointsController1,
                                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Podaj małe punkty dla gracza ${currentTable.p1?.name} ${currentTable.p1?.lastName}',
                                        )),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    height: 300,
                                    width: 500,
                                    child: TextFormField(
                                        controller: _bigPointsController2,
                                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Podaj duże punkty dla gracza ${currentTable.p2?.name} ${currentTable.p2?.lastName}',
                                        )),
                                  ),
                                  SizedBox(
                                    height: 300,
                                    width: 500,
                                    child: TextFormField(
                                        controller: _smallPointsController2,
                                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                                        decoration: InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: 'Podaj małe punkty dla gracza ${currentTable.p2?.name} ${currentTable.p2?.lastName}',
                                        )),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      }),
                  child: Text("Dodaj punkty"))
            ]);
          },
        )
      ],
    );
  }

  void startGame() {
    setState(() {
      widget.options.gameStarted = true;
    });
  }
}

class Player {
  Player({required this.name, required this.lastName, required this.group});

  final String name;
  final String lastName;
  final int group;
  GamePlayed? currentGame;
  final List<GamePlayed> gamesPlayed = List.empty(growable: true);
}

class Table {
  int tableNumber;
  bool isFree;
  Player? p1;
  Player? p2;

  Table({required this.tableNumber, this.isFree = true});

  String? getCurrentMatchup() {
    if (p1 == null || p2 == null) {
      return null;
    }
    return "${p1?.name} ${p1?.lastName} VS ${p2?.name} ${p2?.lastName}";
  }

  void setFree() {
    p1 = null;
    p2 = null;
  }

  void setPlayers(Player p1, Player p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
}

// TODO add players here
class Options {
  bool gameStarted;

  Options({this.gameStarted = false});
}

class GamePlayed {
  GamePlayed({required this.player1, required this.player2});
  Player player1;
  Player player2;
  List<(Round, Round)> roundsPlayed = List.empty(growable: true);

  bool addRound(Round r1, Round r2) {
    if (roundsPlayed.length >= 3) {
      return false;
    }
    roundsPlayed.add((r1, r2));
    return true;
  }

  // If game is won, return player who has won. Of not - return null.
  Player? checkIfGameOver() {
    int player1Points = 0;
    int player2Points = 0;
    for (var (p1r, p2r) in roundsPlayed) {
      if (p1r.bigPoints > p2r.bigPoints) {
        player1Points++;
      } else {
        player2Points++;
      }
    }
    if (player1Points == 2) {
      return player1;
    }
    if (player2Points == 2) {
      return player2;
    }
    return null;
  }
}

class Round {
  Round({required this.smallPoints, required this.bigPoints});
  int smallPoints;
  int bigPoints;
}
