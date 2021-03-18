import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:hypixel_bedwars_stats/config.dart';
import 'dart:convert';

class Player {
  String ign, uuid, prefix, rank, monthlyPackageRank, monthlyRankColor, newPackageRank, rankPlusColor;
  int bwLevel;
  Map mcColorCodes = {
    '§0': 0xFF000000,
    '§1': 0xFF0000AA,
    '§2': 0xFF00AA00,
    '§3': 0xFF00AAAA,
    '§4': 0xFFAA0000,
    '§5': 0xFFAA00AA,
    '§6': 0xFFFFAA00,
    '§7': 0xFFAAAAAA,
    '§8': 0xFF555555,
    '§9': 0xFF5555FF,
    '§a': 0xFF55FF55,
    '§b': 0xFF55FFFF,
    '§c': 0xFFFF5555,
    '§d': 0xFFFF55FF,
    '§e': 0xFFFFFF55,
    '§f': 0xFFFFFFFF,
  };
  Map colors = {
    'BLACK': '§0',
    'DARK_BLUE': '§1',
    'DARK_GREEN': '§2',
    'DARK_AQUA': '§3',
    'DARK_RED': '§4',
    'DARK_PURPLE': '§5',
    'GOLD': '§6',
    'GREY': '§7',
    'DARK_GREY': '§8',
    'BLUE': '§9',
    'GREEN': '§a',
    'AQUA': '§b',
    'RED': '§c',
    'LIGHT_PURPLE': '§d',
    'YELLOW': '§e',
    'WHITE': '§f',
  };

  Player(this.ign);

  Future<String> getPlayerData() async {
    // Minecraft Account UUID
    Response uuidResponse = await get(Uri.https('api.mojang.com', '/users/profiles/minecraft/$ign'));
    Map uuidData = jsonDecode(uuidResponse.body);
    uuid = uuidData['id'];

    // Hypixel Player Info and Bedwars Stats
    Response playerResponse = await get(Uri.https('api.hypixel.net', '/player', {'uuid': uuid, 'key': HYPIXEL_API_KEY}));
    Map playerData = jsonDecode(playerResponse.body)['player'];
    prefix = playerData['prefix'];
    rank = playerData['rank'];
    monthlyPackageRank = playerData['monthlyPackageRank'];
    monthlyRankColor = playerData['monthyRankColor'];
    newPackageRank = playerData['newPackageRank'];
    rankPlusColor = playerData['rankPlusColor'];
    bwLevel = playerData['achievements']['bedwars_level'];
    // Using correct casing of ign
    for (String knownAlias in playerData['knownAliases']) {
      if (knownAlias.toLowerCase() == ign.toLowerCase()) {
        ign = knownAlias;
        break;
      }
    }
    return 'Fetch Complete!';
  }

  Widget getIGNWidget() {
    List<InlineSpan> children = [];

    if (prefix != null && prefix != 'NORMAL') {
      String currentColCode = '';
      for (int i = 0; i < prefix.length; i++) {
        if (prefix[i] == '§') {
          currentColCode = prefix.substring(i, i + 2);
          i += 2;
        }
        children.add(
          TextSpan(
            text: prefix[i] + (i == prefix.length - 1 ? ' $ign' : ''),
            style: TextStyle(
              color: Color(
                mcColorCodes[currentColCode],
              ),
            ),
          ),
        );
      }
    } else if (rank != null && rank != 'NORMAL') {
      // TODO: GAME_MASTER rank
      if (rank == 'MODERATOR') {
        children = [
          TextSpan(
            text: '[MOD] $ign',
            style: TextStyle(
              color: Color(0xFF00AA00),
            ),
          ),
        ];
      } else if (rank == 'HELPER') {
        children = [
          TextSpan(
            text: '[HELPER] $ign',
            style: TextStyle(
              color: Color(0xFF5555FF),
            ),
          ),
        ];
      } else if (rank == 'YOUTUBER') {
        children = [
          TextSpan(
            text: '[',
            style: TextStyle(
              color: Color(0xFFFF5555),
            ),
          ),
          TextSpan(
            text: 'YOUTUBE',
            style: TextStyle(
              color: Color(0xFFAAAAAA),
            ),
          ),
          TextSpan(
            text: ']',
            style: TextStyle(
              color: Color(0xFFFF5555),
            ),
          ),
          TextSpan(
            text: ' $ign',
            style: TextStyle(
              color: Color(0xFFFF5555),
            ),
          ),
        ];
      }
    } else if (monthlyPackageRank == 'SUPERSTAR') {
      children = [
        TextSpan(
          text: '[MVP',
          style: TextStyle(
            color: Color(monthlyRankColor != null ? mcColorCodes[colors[monthlyRankColor]] : 0xFFFFAA00),
          ),
        ),
        TextSpan(
          text: '++',
          style: TextStyle(
            color: Color(mcColorCodes[colors[rankPlusColor]]),
          ),
        ),
        TextSpan(
          text: ']',
          style: TextStyle(
            color: Color(monthlyRankColor != null ? mcColorCodes[colors[monthlyRankColor]] : 0xFFFFAA00),
          ),
        ),
        TextSpan(
          text: ' $ign',
          style: TextStyle(
            color: Color(0xFFFFAA00),
          ),
        ),
      ];
    } else if (newPackageRank != null) {
      bool isVIP = newPackageRank.substring(0, 3) == 'VIP';
      int rankColor = isVIP ? 0xFF55FF55 : 0xFF55FFFF;
      rankPlusColor ??= 'WHITE';
      children = [
        TextSpan(
          text: '[${newPackageRank.substring(0, 3)}',
          style: TextStyle(
            color: Color(rankColor),
          ),
        ),
        TextSpan(
          text: '+' * 'PLUS'.allMatches(newPackageRank).length,
          style: TextStyle(
            color: Color(isVIP ? 0xFFFFAA00 : mcColorCodes[colors[rankPlusColor]]),
          ),
        ),
        TextSpan(
          text: ']',
          style: TextStyle(
            color: Color(rankColor),
          ),
        ),
        TextSpan(
          text: ' $ign',
          style: TextStyle(
            color: Color(rankColor),
          ),
        ),
      ];
    } else {
      children = [
        TextSpan(
          text: '$ign',
          style: TextStyle(
            color: Color(0xFFAAAAAA),
          ),
        ),
      ];
    }

    return FittedBox(
      child: RichText(
        text: TextSpan(
          children: children,
          style: TextStyle(
            fontSize: 32.0,
            fontFamily: 'Minecraft',
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                color: Color.fromARGB(127, 127, 127, 127),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBedwarsLevlWidget() {
    List prestigeColors = [
      'GREY',
      'WHITE',
      'GOLD',
      'AQUA',
      'DARK_GREEN',
      'DARK_AQUA',
      'DARK_RED',
      'LIGHT_PURPLE',
      'BLUE',
      'DARK_PURPLE',
      ['RED', 'GOLD', 'YELLOW', 'GREEN', 'AQUA', 'LIGHT_PURPLE', 'DARK_PURPLE'],
      ['WHITE', 'GREY'],
      ['YELLOW', 'GOLD'],
      ['AQUA', 'DARK_AQUA'],
      ['GREEN', 'DARK_GREEN'],
      ['DARK_AQUA', 'BLUE'],
      ['RED', 'DARK_RED'],
      ['LIGHT_PURPLE', 'DARK_PURPLE'],
      ['BLUE', 'DARK_BLUE'],
      ['DARK_PURPLE', 'DARK_GREY'],
      ['DARK_GREY', 'GREY', 'WHITE', 'WHITE', 'GREY', 'GREY', 'DARK_GREY'],
      ['WHITE', 'WHITE', 'YELLOW', 'YELLOW', 'GOLD', 'GOLD', 'GOLD'],
      ['GOLD', 'GOLD', 'WHITE', 'WHITE', 'AQUA', 'DARK_AQUA', 'DARK_AQUA'],
      ['DARK_PURPLE', 'DARK_PURPLE', 'LIGHT_PURPLE', 'LIGHT_PURPLE', 'GOLD', 'YELLOW', 'YELLOW'],
      ['AQUA', 'AQUA', 'WHITE', 'WHITE', 'GREY', 'GREY', 'DARK_GREY'],
      ['WHITE', 'WHITE', 'GREEN', 'GREEN', 'DARK_GREEN', 'DARK_GREEN', 'DARK_GREEN'],
      ['DARK_RED', 'DARK_RED', 'RED', 'RED', 'LIGHT_PURPLE', 'LIGHT_PURPLE', 'DARK_PURPLE'],
      ['YELLOW', 'YELLOW', 'WHITE', 'WHITE', 'DARK_GREY', 'DARK_GREY', 'DARK_GREY'],
      ['GREEN', 'GREEN', 'DARK_GREEN', 'DARK_GREEN', 'GOLD', 'GOLD', 'YELLOW'],
      ['AQUA', 'AQUA', 'DARK_AQUA', 'DARK_AQUA', 'BLUE', 'BLUE', 'DARK_BLUE'],
      ['YELLOW', 'YELLOW', 'GOLD', 'GOLD', 'RED', 'RED', 'DARK_RED'],
    ];
    List<InlineSpan> children = [];
    int index = (bwLevel / 100).floor();

    if (index < 10) {
      children = [
        TextSpan(
          text: '[$bwLevel✫]',
          style: TextStyle(
            color: Color(
              mcColorCodes[colors[prestigeColors[index]]],
            ),
          ),
        ),
      ];
    } else if (index > 10 && index < 20) {
      children = [
        TextSpan(
          text: '[',
          style: TextStyle(
            color: Color(0xFFAAAAAA),
          ),
        ),
        TextSpan(
          text: '$bwLevel',
          style: TextStyle(
            color: Color(
              mcColorCodes[colors[prestigeColors[index][0]]],
            ),
          ),
        ),
        TextSpan(
          text: '✪',
          style: TextStyle(
            color: Color(
              mcColorCodes[colors[prestigeColors[index][1]]],
            ),
          ),
        ),
        TextSpan(
          text: ']',
          style: TextStyle(
            color: Color(0xFFAAAAAA),
          ),
        ),
      ];
    } else {
      String bwLevelStr = '[${bwLevel.toString()}${bwLevel < 1100 ? '✫' : '⚝'}]';
      for (int i = 0; i < bwLevelStr.length; i++) {
        children.add(
          TextSpan(
            text: bwLevelStr[i],
            style: TextStyle(
              color: Color(mcColorCodes[colors[prestigeColors[index][i]]]),
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        children: children,
        style: TextStyle(
          fontSize: 32.0,
          fontFamily: 'Minecraft',
        ),
      ),
    );
  }
}
