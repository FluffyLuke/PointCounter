// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Table _$TableFromJson(Map<String, dynamic> json) => Table(
      tableNumber: json['tableNumber'] as int,
      isFree: json['isFree'] as bool? ?? true,
    )
      ..p1 = json['p1'] == null ? null : Player.fromJson(json['p1'] as Map<String, dynamic>)
      ..p2 = json['p2'] == null ? null : Player.fromJson(json['p2'] as Map<String, dynamic>);

Map<String, dynamic> _$TableToJson(Table instance) => <String, dynamic>{
      'tableNumber': instance.tableNumber,
      'isFree': instance.isFree,
      'p1': instance.p1?.toJson(),
      'p2': instance.p2?.toJson(),
    };

Options _$OptionsFromJson(Map<String, dynamic> json) => Options(
      remaches: json['remaches'] as int? ?? 1,
      gameStarted: json['gameStarted'] as bool? ?? false,
    )
      ..secondWindowId = json['secondWindowId'] as int?
      ..players = (json['players'] as List<dynamic>).map((e) => Player.fromJson(e as Map<String, dynamic>)).toList();

Map<String, dynamic> _$OptionsToJson(Options instance) => <String, dynamic>{
      'gameStarted': instance.gameStarted,
      'remaches': instance.remaches,
      'secondWindowId': instance.secondWindowId,
      'players': instance.players,
    };

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      name: json['name'] as String,
      group: json['group'] as int,
      options: Options.fromJson(json['options'] as Map<String, dynamic>),
    )..currentGame = json['currentGame'] == null ? null : GameToPlay.fromJson(json['currentGame'] as Map<String, dynamic>);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'name': instance.name,
      'group': instance.group,
      'currentGame': instance.currentGame,
      'options': instance.options,
    };

GameToPlay _$GameToPlayFromJson(Map<String, dynamic> json) => GameToPlay(
      player1: Player.fromJson(json['player1'] as Map<String, dynamic>),
      player2: Player.fromJson(json['player2'] as Map<String, dynamic>),
    )
      ..isOver = json['isOver'] as bool
      ..roundsPlayed = (json['roundsPlayed'] as List<dynamic>)
          .map((e) => _$recordConvert(
                e,
                ($jsonValue) => (
                  Round.fromJson($jsonValue[r'$1'] as Map<String, dynamic>),
                  Round.fromJson($jsonValue[r'$2'] as Map<String, dynamic>),
                ),
              ))
          .toList();

Map<String, dynamic> _$GameToPlayToJson(GameToPlay instance) => <String, dynamic>{
      'player1': instance.player1.toJson(),
      'player2': instance.player2.toJson(),
      'isOver': instance.isOver,
      'roundsPlayed': instance.roundsPlayed
          .map((e) => {
                r'$1': e.$1.toJson(),
                r'$2': e.$2.toJson(),
              })
          .toList(),
    };

$Rec _$recordConvert<$Rec>(
  Object? value,
  $Rec Function(Map) convert,
) =>
    convert(value as Map<String, dynamic>);

Round _$RoundFromJson(Map<String, dynamic> json) => Round(
      smallPoints: json['smallPoints'] as int,
      bigPoints: json['bigPoints'] as int,
    );

Map<String, dynamic> _$RoundToJson(Round instance) => <String, dynamic>{
      'smallPoints': instance.smallPoints,
      'bigPoints': instance.bigPoints,
    };
