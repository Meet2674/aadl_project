import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../algorithms/a_star.dart';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

class GridStateManager extends ChangeNotifier {
  int gridHeight, gridWidth;
  bool startDefined = false;
  bool stopDefined = false;
  List<List<int>> gridState;

  GridStateManager({this.gridHeight: 20, this.gridWidth: 10}) {
    print("HERE!!");
    gridState = [List.filled(gridWidth, 0)];
    for (int i = 1; i < gridHeight; i++) {
      gridState.add(List.filled(gridWidth, 0));
    }
  }

  void updateGridTileState(int x, int y, int tileType) {
    print('x = $x ,y = $y was tapped');
    if (gridState[x][y] == 2 && tileType == 0 || tileType == 1) {
      startDefined = false;
    }
    if (gridState[x][y] == 3 && tileType == 0 || tileType == 1) {
      stopDefined = false;
    }
    if (startDefined && tileType == 2) {
      print('Can\'t have multiple start nodes');
    } else if (stopDefined && tileType == 3) {
      print('Can\'t have multiple stop nodes');
    } else {
      if (tileType == 2) {
        if (gridState[x][y] == 3) {
          stopDefined = false;
        }
        startDefined = true;
      }
      if (tileType == 3) {
        if (gridState[x][y] == 2) {
          startDefined = false;
        }
        stopDefined = true;
      }
      gridState[x][y] = tileType;
      notifyListeners();
    }
  }

  void eraseGrid() {
    gridState = [List.filled(gridWidth, 0)];
    for (int i = 1; i < gridHeight; i++) {
      gridState.add(List.filled(gridWidth, 0));
    }
    startDefined = false;
    stopDefined = false;
    notifyListeners();
    print('grid erased');
  }

  void drawPathTiles(int x, int y, int tileType) async {
    gridState[x][y] = tileType;
    print('drawing tiles');
    notifyListeners();
  }

  void visualizeAstar() async {
    aStar2D(Maze.parse(gridState), this);
    print(this.gridState);
    // Tile pathTile;
    // path.removeFirst();
    // path.removeLast();
    // while (path.isNotEmpty) {
    //   await justWait(numberOfmilliSeconds: 200);
    //   pathTile = path.removeFirst();
    //   print('${pathTile.x} , ${pathTile.y}');
    //   // gridState[pathTile.y][pathTile.x] = 4;
    //   // notifyListeners();
    // }
  }
}