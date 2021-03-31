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
              SizedBox(height: 30.0),
              player.getStatsWidget(),
              Expanded(child: SizedBox()),
              Row(
                children: [
                  Icon(Icons.search, color: Colors.white, size: 28.0),
                  SizedBox(width: 15.0),
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(),
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Search',
                        labelStyle: TextStyle(color: Colors.white),
                        isDense: true, // Added this
                        contentPadding: EdgeInsets.all(5), // Added t
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                        ),
                      ),
                      onFieldSubmitted: (term) async {
                        if (term == '' || term == null) return;
                        String prevIgn = player.ign;
                        try {
                          player.ign = term;
                          await player.getPlayerData();
                        } catch (_) {
                          player.ign = prevIgn;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red[600],
                              duration: Duration(seconds: 5),
                              content: Container(
                                height: 75.0,
                                child: Text(
                                  'There was an error! The ign you entered may not exist, or the player may have their api setting disabled!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    fontFamily: 'Minecraft',
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (snapshot.hasError) {
          column = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'There was an error! The ign you entered may not exist, or the player may have their api setting disabled!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.red[400],
                  fontFamily: 'Minecraft',
                ),
              ),
              SizedBox(height: 15.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Minecraft',
                  ),
                ),
              )
            ],
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
                    Center(
                      child: Text(
                        'Fetching Data . . .',
                        style: TextStyle(
                          fontSize: 26.0,
                          fontFamily: 'Minecraft',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xFF2B2B2B),
          appBar: AppBar(
            backgroundColor: Colors.yellow[600],
            title: Center(
              child: Text(
                'Hypixel Bedwars Stats',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.0,
                  fontFamily: 'Minecraft',
                ),
              ),
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: column,
            ),
          ),
        );
      },
    );
  }
}
