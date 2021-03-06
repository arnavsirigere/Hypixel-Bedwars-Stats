import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:hypixel_bedwars_stats/config.dart';
import 'package:hypixel_bedwars_stats/constants.dart';
import 'package:hypixel_bedwars_stats/widgets/stat.dart';
import 'dart:convert';

class Player {
  String ign, uuid, prefix, rank, monthlyPackageRank, monthlyRankColor, newPackageRank, rankPlusColor;
  int bwLevel, winstreak, kills, deaths, fKills, fDeaths, bedsBroken, bedsLost, wins, losses;

  Player(this.ign);

  Future<String> getPlayerData() async {
    // Minecraft Account UUID
    Response uuidResponse = await get(Uri.https('api.mojang.com', '/users/profiles/minecraft/$ign'));
    Map uuidData = jsonDecode(uuidResponse.body);
    uuid = uuidData['id'];
    // Hypixel Rank
    Response playerResponse = await get(Uri.https('api.hypixel.net', '/player', {'uuid': uuid, 'key': HYPIXEL_API_KEY}));
    Map playerData = jsonDecode(playerResponse.body)['player'];
    prefix = playerData['prefix'];
    rank = playerData['rank'];
    monthlyPackageRank = playerData['monthlyPackageRank'];
    monthlyRankColor = playerData['monthyRankColor'];
    newPackageRank = playerData['newPackageRank'];
    rankPlusColor = playerData['rankPlusColor'];
    // Bedwars Stats
    Map bwStats = playerData['stats']['Bedwars'];
    bwLevel = playerData['achievements']['bedwars_level'];
    winstreak = bwStats['winstreak'] ?? 0;
    kills = bwStats['kills_bedwars'] ?? 0;
    deaths = bwStats['deaths_bedwars'] ?? 0;
    fKills = bwStats['final_kills_bedwars'] ?? 0;
    fDeaths = bwStats['final_deaths_bedwars'] ?? 0;
    bedsBroken = bwStats['beds_broken_bedwars'] ?? 0;
    bedsLost = bwStats['beds_lost_bedwars'] ?? 0;
    wins = bwStats['wins_bedwars'] ?? 0;
    losses = bwStats['losses_bedwars'] ?? 0;
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
        if (prefix[i] == '??') {
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
      if (rank == 'MODERATOR' || rank == 'GAME_MASTER') {
        children = [
          TextSpan(
            text: '[${rank == 'MODEARATOR' ? 'MOD' : 'GM'}] $ign',
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
              color: Color(0xFFFFFFFF),
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

  Widget getBedwarsLevelWidget() {
    List<InlineSpan> children = [];
    int index = (bwLevel / 100).floor();

    if (index < 10) {
      children = [
        TextSpan(
          text: '[$bwLevel???]',
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
          text: '???',
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
      String bwLevelStr = '[${bwLevel.toString()}${bwLevel < 1100 ? '???' : '???'}]';
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

  Widget getStatsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stat('Winstreak', '$winstreak'),
        Divider(color: Colors.grey[600]),
        Stat('Kills', '$kills'),
        Stat('Deaths', '$deaths'),
        Stat('K/D Ratio', '${kills == 0 ? 0 : (kills / deaths).toStringAsFixed(2)}'),
        Divider(color: Colors.grey[600]),
        Stat('Final Kills', '$fKills'),
        Stat('Final Deaths', '$fDeaths'),
        Stat('Final K/D Ratio', '${fKills == 0 ? 0 : (fKills / fDeaths).toStringAsFixed(2)}'),
        Divider(color: Colors.grey[600]),
        Stat('Beds Broken', '$bedsBroken'),
        Stat('Beds Lost', '$bedsLost'),
        Stat('Beds Broken/Lost Ratio', '${bedsBroken == 0 ? 0 : (bedsBroken / bedsLost).toStringAsFixed(2)}'),
        Divider(color: Colors.grey[600]),
        Stat('Wins', '$wins'),
        Stat('Losses', '$losses'),
        Stat('W/L Ratio', '${wins == 0 ? 0 : (wins / losses).toStringAsFixed(2)}'),
      ],
    );
  }
}
