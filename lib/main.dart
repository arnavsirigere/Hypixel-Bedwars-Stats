import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hypixel_bedwars_stats/classes/Player.dart';

void main() {
  return runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Player player = Player('Arnav_S');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: player.getPlayerData(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        Widget column;
        if (snapshot.hasData) {
          column = Column(
            children: [
              Center(
                child: player.getIGNWidget(),
              ),
              SizedBox(height: 15.0),
              Row(
                children: [
                  Image(
                    height: 90.0,
                    width: 90.0,
                    image: NetworkImage('https://visage.surgeplay.com/face/${player.uuid}'),
                  ),
                  Expanded(
                    child: SizedBox(),
                    flex: 1,
                  ),
                  player.getBedwarsLevelWidget(),
                  SizedBox(width: 20.0),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          column = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    //TODO: Add try again button
                    'X Oh no! There was an error!',
                    style: TextStyle(
                      fontSize: 27.0,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          column = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    SpinKitDualRing(
                      color: Colors.yellowAccent,
                      size: 100.0,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Fetching Data . . .',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontFamily: 'Minecraft',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Scaffold(
          backgroundColor: Color(0xFF2B2B2B),
          appBar: AppBar(
            backgroundColor: Colors.yellow[600],
            title: Center(
              child: Text(
                'Hypixel Bedwars Stats',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.0,
                  fontFamily: 'Minecraft',
                ),
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(20.0),
            child: column,
          ),
        );
      },
    );
  }
}
