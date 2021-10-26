import 'package:flash_chat/screens/components/rounded_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../algorithms/a_star.dart';
import 'dart:collection';
import '../models/GridStateManagement.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

int gridHeight = 20;
int gridWidth = 10;
int tileType = 0;
String algo;
bool startDefined = false;
bool stopDefined = false;
List<Color> gridTileColors = [
  Colors.white,
  Colors.black,
  Colors.green,
  Colors.red,
  Colors.blue,
  Colors.lightGreenAccent,
  Colors.amber,
];
List<List<int>> gridState;

void eraseGrid() {
  gridState = [List.filled(gridWidth, 0)];
  for (int i = 1; i < gridHeight; i++) {
    gridState.add(List.filled(gridWidth, 0));
  }
}

List<Expanded> generateGridList(int gridHeight, int gridWidth) {
  List<Expanded> list = [];
  for (int i = 0; i < gridHeight; i++) {
    List<Widget> temp = [];
    for (int j = 0; j < gridWidth; j++) {
      temp.add(Expanded(child: GridTile(x: i, y: j)));
    }
    list.add(Expanded(child: Row(children: temp)));
  }
  // initGrid();
  return list;
}

class GridTile extends StatefulWidget {
  final int x;
  final int y;
  GridTile({@required this.x, @required this.y});
  @override
  _GridTileState createState() => _GridTileState();
}

class _GridTileState extends State<GridTile> {
  @override
  Widget build(BuildContext context) {
    var x1 = widget.x;
    var y1 = widget.y;
    return Consumer<GridStateManager>(
      builder: (context, gridStateManager, child) {
        return GestureDetector(
          onTap: () {
            int c;
            c = gridStateManager.updateGridTileState(x1, y1, tileType);
            switch (c) {
              case 2:
                Fluttertoast.showToast(
                    msg: "Cannot have multiple start nodes",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                break;
              case 3:
                Fluttertoast.showToast(
                    msg: "Cannot have multiple stop nodes",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                break;
              default:
                break;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.3),
              color: gridTileColors[gridStateManager.gridState[x1][y1]],
            ),
          ),
        );
      },
    );
  }
}

class VisualizerMenu extends StatefulWidget {
  @override
  _VisualizerMenuState createState() => _VisualizerMenuState();
}

class _VisualizerMenuState extends State<VisualizerMenu> {
  @override
  var menuTileType;
  var menuAlgo;
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            child: DropdownButton<String>(
              value: menuAlgo,
              onChanged: (String newValue) {
                algo = newValue;
                setState(() {
                  menuAlgo = algo;
                });
                print(algo);
              },
              style: TextStyle(color: Colors.deepPurple),
              // underline: Container(
              //   height: 2,
              //   width: 10,
              //   color: Colors.deepPurpleAccent,
              // ),
              items: [
                DropdownMenuItem(
                  child: Text('A*'),
                  value: 'A*',
                ),
                DropdownMenuItem(
                  child: Text('Dijkstra'),
                  value: 'Dijkstra',
                ),
                DropdownMenuItem(
                  child: Text('BFS'),
                  value: 'BFS',
                ),
                DropdownMenuItem(
                  child: Text('DFS'),
                  value: 'DFS',
                ),
                DropdownMenuItem(
                  child: Text('Bellman-Ford'),
                  value: 'BFord',
                ),
                DropdownMenuItem(
                  child: Text('Floyd-Warshall'),
                  value: 'FWarshall',
                ),
              ],
            ),
            margin: EdgeInsets.all(15.0),
          ),
        ),
        Expanded(
          child: Container(
            child: DropdownButton<int>(
              value: menuTileType,
              onChanged: (int newValue) {
                tileType = newValue;
                setState(() {
                  menuTileType = tileType;
                });
                print(tileType);
              },
              style: TextStyle(color: Colors.deepPurple),
              // underline: Container(
              //   height: 2,
              //   color: Colors.deepPurpleAccent,
              // ),
              items: [
                DropdownMenuItem(
                  child: Text('Empty'),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text('Grid'),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text('Start'),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text('Stop'),
                  value: 3,
                ),
              ],
            ),
            margin: EdgeInsets.all(15.0),
          ),
        ),
      ],
    );
  }
}

class Visualizer extends StatefulWidget {
  static const String id = 'visualizer';
  @override
  _VisualizerState createState() => _VisualizerState();
}

class _VisualizerState extends State<Visualizer> {
  List<Expanded> list = [];
  @override
  // Future playLocal(url) async {
  //   AudioPlayer audioPlayer = new AudioPlayer();
  //   final result = await audioPlayer.play(url);
  //   if (result == 1) setState(() => playerState = PlayerState.playing);
  // }

  void initState() {
    super.initState();
    print('init called');
    gridState = [List.filled(gridWidth, 0)];
    for (int i = 1; i < gridHeight; i++) {
      gridState.add(List.filled(gridWidth, 0));
    }
  }

  Widget build(BuildContext context) {
    const title = 'Visualizer';
    return ChangeNotifierProvider(
      create: (context) =>
          GridStateManager(gridHeight: gridHeight, gridWidth: gridWidth),
      child: MaterialApp(
        title: title,
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: TextStyle(color: Colors.black),
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: TextButton(
                  onPressed: () => onCustomizePressed(),
                  child: Text("Customize"),
                ),
              )
            ],
            backgroundColor: Colors.white,
          ),
          body: Column(children: [
            Expanded(
              child: VisualizerMenu(),
              flex: 1,
            ),
            Expanded(
              child: Container(
                child: Column(
                  children: generateGridList(gridHeight, gridWidth),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                    top: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                    left: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                    right: BorderSide(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                ),
              ),
              flex: 8,
            ),
            Expanded(
              child: Consumer<GridStateManager>(
                  builder: (context, gridStateManager, child) {
                return Row(
                  children: [
                    Expanded(
                      child: RoundedButton(
                        title: 'Visualize!',
                        colour: Colors.lightBlueAccent,
                        onPressed: () async {
                          switch (algo) {
                            case 'A*':
                              await gridStateManager.visualizeAstar();
                              break;
                            case 'Dijkstra':
                              await gridStateManager.visualizeDijkstras();
                              break;
                            case 'BFS':
                              gridStateManager.visualizeBFS();
                              break;
                            case 'DFS':
                              gridStateManager.visualizeDFS();
                              break;
                            case 'BFord':
                              gridStateManager.visualizeBFord();
                              break;
                            case 'FWarshall':
                              gridStateManager.visualizeFWarshall();
                              break;
                            default:
                              break;
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: RoundedButton(
                        title: 'Erase',
                        colour: Colors.deepOrangeAccent,
                        onPressed: () {
                          gridStateManager.eraseGrid();
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ]),
        ),
      ),
    );
  }

  void onCustomizePressed() {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ListTile(
                    title: Text('Empty Grid Cells'),
                    onTap: () => showcolorpicker(0),
                  ),
                  ListTile(
                    title: Text('Obstacles'),
                    onTap: () => showcolorpicker(1),
                  ),
                  ListTile(
                    title: Text('Start Node'),
                    onTap: () => showcolorpicker(2),
                  ),
                  ListTile(
                    title: Text('Stop Node'),
                    onTap: () => showcolorpicker(3),
                  ),
                  ListTile(
                    title: Text('Path'),
                    onTap: () => showcolorpicker(4),
                  ),
                  ListTile(
                    title: Text('Visited Nodes'),
                    onTap: () => showcolorpicker(5),
                  ),
                  ListTile(
                    title: Text('Current Nodes'),
                    onTap: () => showcolorpicker(6),
                  ),
                  ListTile(
                    title: Text('Reset to Default'),
                    onTap: () => {
                      setState(() {
                        gridTileColors[0] = Colors.white;
                        gridTileColors[1] = Colors.black;
                        gridTileColors[2] = Colors.green;
                        gridTileColors[3] = Colors.red;
                        gridTileColors[4] = Colors.blue;
                        gridTileColors[5] = Colors.lightGreenAccent;
                        gridTileColors[6] = Colors.amber;
                      })
                    },
                  ),
                ],
              ),
            ],
          );
        });
  }

  void showcolorpicker(int i) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Pick a color"),
            children: <Widget>[
              MaterialColorPicker(
                onColorChange: (Color color) {
                  setState(() {
                    gridTileColors[i] = color;
                  });
                },
                selectedColor: Colors.red,
              )
            ],
          );
        });
  }
}
