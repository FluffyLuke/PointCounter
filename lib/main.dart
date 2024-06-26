import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:json_annotation/json_annotation.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'main.g.dart';

void main(List<String> args) {
  print(args.firstOrNull);
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty ? const {} : jsonDecode(args[2]) as Map<String, dynamic>;
    runApp(SubApp(
      windowController: WindowController.fromWindowId(windowId),
      args: argument,
    ));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

  final String title;

  @override
  State<PointCounter> createState() => _PointCounterState();
}

class _PointCounterState extends State<PointCounter> {
  int _nextPage = 2;
  int _nextGroup = 1;
  List<Page> _pages = List.empty(growable: true);
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

  void _setTables(int numberOfTables) {
    print("Setting tables...");
    var tablePage = TablePage(
      numberOfTables: numberOfTables,
      options: _options,
      pageNumber: 1,
    );
    _pages[0] = tablePage;
    _currentPage = tablePage;
    setState(() {});
  }

  void _displayScoreWindow() async {
    // final window = await DesktopMultiWindow.createWindow(jsonEncode({'arg1': 'Sub Window'})).then((value) {
    //   value
    //     ..setFrame(const Offset(0, 0) & const Size(1200, 1000))
    //     ..center()
    //     ..setTitle("Wyniki")
    //     ..show();
    //});
    if (_options.secondWindowId != null) {
      print("Trying to create a second window, but one is already present");
      return;
    }
    final window = await DesktopMultiWindow.createWindow(jsonEncode({
      'args1': 'sub',
      'args2': 100,
      'args3': true,
      'bussiness': 'bussiness_test',
    }));
    window
      ..setFrame(const Offset(0, 0) & const Size(1280, 720))
      ..center()
      ..setTitle('Another window')
      ..show();
    _options.addSecondWindowId(window.windowId);
    _options.updateSecondWindow();
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
              Container(
                margin: EdgeInsets.only(left: 20),
                child: FloatingActionButton(
                  onPressed: _displayScoreWindow,
                  child: const Icon(Icons.score),
                ),
              )
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
  GroupPage({required this.options, required this.groupNumber, required super.pageNumber});
  final int groupNumber;
  final Options options;
  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  var nameController = TextEditingController();

  void _addPlayer() {
    var name = nameController.text;
    var newPlayer = Player(name: name, group: widget.groupNumber, options: widget.options);
    widget.options.addPlayer(newPlayer);
    setState(() {});
  }

  void _displayPlayer(Player player) {
    String isFree = "Tak";
    if (player.currentGame != null) {
      isFree = "Nie";
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(player.name),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Zamknij"))],
            content: Column(
              children: [
                Text("Imię: ${player.name}", textScaler: TextScaler.linear(2.0)),
                Text("Czy jest wolny? $isFree"),
                Text("Walczył przeciwko:", textScaler: TextScaler.linear(2.0)),
                SizedBox(
                  width: 1000,
                  height: 700,
                  child: Builder(builder: (context) {
                    return ListView.builder(
                        // Let the ListView know how many items it needs to build.
                        itemCount: player.gamesToPlay.length,
                        shrinkWrap: false,
                        // Provide a builder function. This is where the magic happens.
                        // Convert each item into a widget based on the type of item it is.
                        itemBuilder: (context, index) {
                          final gameToPlay = player.gamesToPlay[index];

                          return Row(children: [
                            Text("Gracz1: ${gameToPlay.player1.name}"),
                            Text("Gracz2: ${gameToPlay.player2.name}"),
                            Text("Czy skończona: ${gameToPlay.isOver}")
                          ]);
                        });
                  }),
                ),
              ],
            ),
          );
        });
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
              width: 600,
              child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Podaj imię i nazwisko gracza',
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
          itemCount: widget.options.getPlayers(widget.groupNumber).length,
          shrinkWrap: true,
          // Provide a builder function. This is where the magic happens.
          // Convert each item into a widget based on the type of item it is.
          itemBuilder: (context, index) {
            final p = widget.options.getPlayers(widget.groupNumber)[index];

            return Row(children: [
              Text("Gracz: ${p.name}"),
              TextButton(onPressed: () => _displayPlayer(p), child: Text("Opis")),
              TextButton(onPressed: () => {widget.options.removePlayer(p), setState(() {})}, child: Text("Usuń"))
            ]);
          },
        ),
      ],
    );
  }
}

class TablePage extends Page {
  final Options options;

  TablePage({super.key, required this.options, required super.pageNumber, required int numberOfTables}) {
    for (int i = 0; i < numberOfTables; i++) {
      options.tables.add(Table(tableNumber: i + 1));
    }
  }
  @override
  State<StatefulWidget> createState() => _TablePageState();
}

class ScorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  @override
  Widget build(BuildContext context) {
    return Text("DUpson");
  }
}

class _TablePageState extends State<TablePage> {
  @override
  void initState() {
    super.initState();
    if (widget.options.gameStarted) {
      _setPlayersGames();
    }
  }

  void _startGame() {
    widget.options.gameStarted = true;
    widget.options.generateMatchupsForPlayers();
    _setPlayersGames();
  }

  var _smallPointsController1 = TextEditingController();
  var _smallPointsController2 = TextEditingController();
  var _bigPointsController1 = TextEditingController();
  var _bigPointsController2 = TextEditingController();

  void _setPlayersGames() {
    for (Table table in widget.options.tables) {
      if (!table.isFree) {
        continue;
      }

      for (Player p in widget.options.getFreePlayers()) {
        if (p.currentGame != null) {
          continue;
        }
        var nextMatchup = p.getNextMatchup();
        if (nextMatchup == null) {
          continue;
        }

        //print(
        //    "------\nPlayer 1 ${nextMatchup.player1.name} Player 2 ${nextMatchup.player2.name}\n${nextMatchup.player1.currentGame} ${nextMatchup.player2.currentGame}");
        if (nextMatchup.player1.currentGame != null || nextMatchup.player2.currentGame != null) {
          continue;
        }
        Player p1 = nextMatchup.player1;
        p1.currentGame = nextMatchup;
        Player p2 = nextMatchup.player2;
        p2.currentGame = nextMatchup;
        table.p1 = p1;
        table.p2 = p2;
        table.isFree = false;
        break;
      }
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
    p1.currentGame!.addRound(round1, round2);
    //print("Game is over for player ${p1.name} and ${p2.name}");
    if (p1.currentGame!.isOver) {
      bool foundPlayerFlag = false;
      for (Table table in widget.options.tables) {
        if (table.p1 == p1 && table.p2 == p2) {
          foundPlayerFlag = true;
          table.setFree();
          break;
        }
      }
      if (!foundPlayerFlag) {
        throw Exception("Cound not find the table with players");
      }
      p1.currentGame = null;
      p2.currentGame = null;
    }
    widget.options.updateSecondWindow();
    print("Added new round to player ${p1.name} and ${p2.name}");
    _setPlayersGames();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        TextButton(onPressed: widget.options.gameStarted ? null : _startGame, child: Text("Start Game")),
        ListView.builder(
          itemCount: widget.options.tables.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var currentTable = widget.options.tables[index];
            //print("is table number ${currentTable.tableNumber} free: ${currentTable.isFree}");
            var emptyTableMessage = "Pusty stół numer ${index + 1}";

            // Check if game has started
            if (!widget.options.gameStarted) {
              return Row(
                children: [Text(emptyTableMessage)],
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
                                          labelText: 'Podaj duże punkty dla gracza ${currentTable.p1?.name}',
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
                                          labelText: 'Podaj małe punkty dla gracza ${currentTable.p1?.name}',
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
                                          labelText: 'Podaj duże punkty dla gracza ${currentTable.p2?.name}',
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
                                          labelText: 'Podaj małe punkty dla gracza ${currentTable.p2?.name}',
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
}

@JsonSerializable()
class Table {
  int tableNumber;
  bool isFree;
  Player? p1;
  Player? p2;

  Table({required this.tableNumber, this.isFree = true});

  factory Table.fromJson(Map<String, dynamic> json) => _$TableFromJson(json);

  List<String> serializeTable() {
    final player1 = p1 == null ? "Nikt" : p1!.name;
    final player2 = p2 == null ? "Nikt" : p2!.name;
    return ["$tableNumber", player1, player2];
  }

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TableToJson(this);

  String? getCurrentMatchup() {
    if (p1 == null || p2 == null) {
      return null;
    }
    return "${p1?.name} VS ${p2?.name}";
  }

  void setFree() {
    p1 = null;
    p2 = null;
    isFree = true;
  }

  void setPlayers(Player p1, Player p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
}

class WeakTable {
  int tableNumber;
  String p1;
  String p2;

  WeakTable({required this.tableNumber, required this.p1, required this.p2});
}

@JsonSerializable()
class Options {
  bool gameStarted;
  int remaches;
  int? secondWindowId;
  List<Table> tables = List.empty(growable: true);
  List<Player> players = List.empty(growable: true);

  Options({this.remaches = 1, this.gameStarted = false});

  void updateSecondWindow() {
    if (secondWindowId == null) {
      return;
    }

    List<String> serializedTables = [];
    serializedTables.add(tables.length.toString());
    for (Table table in tables) {
      var st = table.serializeTable();
      serializedTables += st;
    }

    List<String> serializedPlayers = [];
    serializedPlayers.add(players.length.toString());
    for (Player player in players) {
      var sp = player.serializePlayer();
      serializedTables += sp;
    }

    DesktopMultiWindow.invokeMethod(secondWindowId!, "update", serializedTables + serializedPlayers);
  }

  factory Options.fromJson(Map<String, dynamic> json) => _$OptionsFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$OptionsToJson(this);

  void generateMatchupsForPlayers() {
    for (Player p in players) {
      List<Player> playersFromGroup = players.where((e) => e.group == p.group).toList();
      p.generateMatchups(playersFromGroup);
    }
  }

  void addPlayer(Player player) {
    if (!gameStarted) {
      players.add(player);
    }
  }

  void removePlayer(Player player) {
    if (!gameStarted) {
      players.remove(player);
    }
  }

  void addSecondWindowId(int id) {
    secondWindowId = id;
  }

  List<Player> getFreePlayers() {
    return players.where((e) => e.currentGame == null).toList();
  }

  List<Player> getPlayers(int groupNumber) {
    return players.where((e) => e.group == groupNumber).toList();
  }

  List<Player> getAllPlayers() {
    return players;
  }
}

@JsonSerializable()
class Player {
  Player({required this.name, required this.group, required this.options});

  final String name;
  final int group;
  GameToPlay? currentGame;
  final List<GameToPlay> gamesToPlay = List.empty(growable: true);
  final Options options;

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  List<String> serializePlayer() {
    List<String> fields = List.empty(growable: true);
    fields.add((2 + gamesToPlay.length).toString());
    fields.add(name);
    fields.add(group.toString());
    for (GameToPlay game in gamesToPlay) {
      if (!game.isOver) {
        fields.add("${game.player1.name} VS ${game.player2.name} => Nie rozegrane");
      } else {
        print("${game.player1.name} VS ${game.player2.name} => Nie rozegrane");
        fields.add("${game.player1.name} VS ${game.player2.name} => ${game.getBigPoints().$1} : ${game.getBigPoints().$2}");
      }
    }

    return fields;
  }

  bool canFightAgainst(Player anotherPlayer) {
    //print("$name - ${anotherPlayer.name}");
    if (group != anotherPlayer.group) {
      return false;
    }
    int foughtTimes = 0;
    for (GameToPlay game in gamesToPlay) {
      if (game.player1 == anotherPlayer || game.player2 == anotherPlayer) {
        foughtTimes++;
      }
    }
    if (foughtTimes >= options.remaches) {
      //print("Player $name cannot fight ${anotherPlayer.name}: Fought to many times");
      return false;
    }
    return true;
  }

  bool isAlreadyFightingWith(Player p) {
    for (GameToPlay game in gamesToPlay) {
      if (game.player1 == p || game.player2 == p) {
        return true;
      }
    }
    return false;
  }

  void generateMatchups(List<Player> playersFromGroup) {
    for (Player anotherPlayer in playersFromGroup) {
      if (anotherPlayer == this) {
        continue;
      }
      if (isAlreadyFightingWith(anotherPlayer)) {
        continue;
      }
      for (int i = 0; i < options.remaches; i++) {
        GameToPlay g = GameToPlay(player1: this, player2: anotherPlayer);
        gamesToPlay.add(g);
        anotherPlayer.gamesToPlay.add(g);
      }
    }
  }

  GameToPlay? getNextMatchup() {
    return gamesToPlay.where((e) => (e.isOver == false) && (e.player1.currentGame == null && e.player2.currentGame == null)).firstOrNull;
  }
}

class WeakPlayer {
  String name;
  int group;
  List<String> gamesToPlay;
  WeakPlayer({required this.name, required this.group, required this.gamesToPlay});
}

@JsonSerializable()
class GameToPlay {
  GameToPlay({required this.player1, required this.player2});
  Player player1;
  Player player2;
  bool isOver = false;
  List<(Round, Round)> roundsPlayed = List.empty(growable: true);

  factory GameToPlay.fromJson(Map<String, dynamic> json) => _$GameToPlayFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$GameToPlayToJson(this);

  (int, int) getBigPoints() {
    int player1Points = 0;
    int player2Points = 0;
    for (var (p1r, p2r) in roundsPlayed) {
      if (p1r.bigPoints > p2r.bigPoints) {
        player1Points++;
      } else {
        player2Points++;
      }
    }
    return (player1Points, player2Points);
  }

  bool addRound(Round r1, Round r2) {
    if (isOver) {
      return false;
    }
    if (roundsPlayed.length >= 3) {
      isOver = true;
      return false;
    }
    roundsPlayed.add((r1, r2));
    if (checkWhoWon() != null) {
      isOver = true;
    }
    return true;
  }

  // If game is won, return player who has won. Of not - return null.
  Player? checkWhoWon() {
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

@JsonSerializable()
class Round {
  Round({required this.smallPoints, required this.bigPoints});
  int smallPoints;
  int bigPoints;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RoundToJson(this);
}

class SubApp extends StatefulWidget {
  const SubApp({
    super.key,
    required this.windowController,
    required this.args,
  });

  final WindowController windowController;
  final Map? args;

  @override
  State<StatefulWidget> createState() => _SubAppState();
}

class _SubAppState extends State<SubApp> {
  List<WeakPlayer> weakPlayers = List.empty(growable: true);
  List<WeakTable> weakTables = List.empty(growable: true);
  int lastGroup = 0;
  int currentGroup = 0;
  static const int groupChangeInterval = 5;

  @override
  void initState() {
    currentGroup = 1;
    Timer.periodic(const Duration(seconds: groupChangeInterval), (timer) {
      if ((currentGroup + 1) > lastGroup) {
        currentGroup = 1;
      } else {
        currentGroup++;
      }
      setState(() {});
    });
    DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
    super.initState();
  }

  Future<dynamic> _handleMethodCallback(MethodCall call, int fromWindowID) async {
    if (call.method.toString() == "update") {
      List<Object?> args = call.arguments as List<Object?>;
      List<String> parsedArgs = List.empty(growable: true);
      //print(args.length);
      for (Object? s in args) {
        parsedArgs.add(s as String);
        //print(s as String);
      }
      getGameState(parsedArgs);
    }
  }

  void getGameState(List<String> args) {
    List<WeakPlayer> newWeakPlayers = List.empty(growable: true);
    List<WeakTable> newWeakTables = List.empty(growable: true);

    int numberOfTables;
    int sizeOfTable = 3;
    //int numberOfPlayers;

    numberOfTables = int.parse(args[0]);
    //numberOfPlayers = int.parse(args[numberOfTables * sizeOfTable + 1]);

    int index = 1; // Start after first argument containing number of tables;
    while (index < 1 + numberOfTables * sizeOfTable) {
      var tableFields = args.sublist(index, index + sizeOfTable);
      newWeakTables.add(WeakTable(tableNumber: int.parse(tableFields[0]), p1: tableFields[1], p2: tableFields[2]));
      index += sizeOfTable;
    }

    // for (WeakTable t in newWeakTables) {
    //   print("WEAK TABLE : ${t.tableNumber}, ${t.p1}, ${t.p2}");
    // }

    while (index < args.length - 1) {
      //print("INDEX: $index");
      int sizeOfPlayer = int.parse(args[index]);
      index++;
      var playerFields = args.sublist(index, index + sizeOfPlayer);
      if (lastGroup < int.parse(playerFields[1])) {
        lastGroup = int.parse(playerFields[1]);
      }
      newWeakPlayers.add(WeakPlayer(name: playerFields[0], group: int.parse(playerFields[1]), gamesToPlay: playerFields.sublist(2)));
      index += sizeOfPlayer;
    }
    // for (WeakPlayer p in newWeakPlayers) {
    //   print("WEAK PLAYER : ${p.name}, ${p.group}");
    //   for (var g in p.gamesToPlay) {
    //     print(g);
    //   }
    // }
    weakPlayers = newWeakPlayers;
    weakTables = newWeakTables;
    setState(() {});
  }

  int getCurrentGroupSize() {
    return weakPlayers.where((element) => element.group == currentGroup).length;
  }

  List<WeakPlayer> getCurrentGroup() {
    return weakPlayers.where((element) => element.group == currentGroup).toList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Sub window",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              "Tablica wyników",
              textScaler: TextScaler.linear(2),
            ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Row(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height - 300,
                  child: Builder(builder: (context) {
                    return ListView.builder(
                        itemCount: weakTables.length,
                        shrinkWrap: false,
                        itemBuilder: (context, index) {
                          final table = weakTables[index];

                          return Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Text(
                                  "Stół nr ${table.tableNumber}",
                                  textScaler: TextScaler.linear(1.5),
                                ),
                                Text(
                                  "${table.p1} VS ${table.p2}",
                                  textScaler: TextScaler.linear(1.5),
                                )
                              ],
                            ),
                          );
                        });
                  })),
              Column(
                children: [
                  Container(margin: EdgeInsets.all(10), child: Text("Grupa $currentGroup", textScaler: TextScaler.linear(2))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height - 300,
                      child: Builder(builder: (context) {
                        return ListView.builder(
                            itemCount: getCurrentGroupSize(),
                            shrinkWrap: false,
                            itemBuilder: (context, index) {
                              final player = getCurrentGroup()[index];
                              String games = "";
                              int switcher = 0;
                              for (String g in player.gamesToPlay) {
                                if (switcher == 0 || switcher == 1) {
                                  games += "$g   |   ";
                                  switcher++;
                                  continue;
                                }
                                games += "$g\n";
                                switcher = 0;
                              }
                              return Column(
                                children: [
                                  Text(
                                    "Gracz ${player.name}",
                                    textScaler: TextScaler.linear(2),
                                  ),
                                  Text(
                                    games,
                                    textScaler: TextScaler.linear(1.2),
                                  ),
                                ],
                              );
                            });
                      })),
                ],
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      widget.windowController.close();
                    },
                    child: const Text('Zamknij'),
                  ),
                ],
              )),
        ));
  }
}
