import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../algorithms/a_star.dart';
import '../algorithms/dijkstra.dart';
import '../algorithms/bfs.dart';
import '../algorithms/dfs.dart';
import '../algorithms/bellman-ford.dart';
import '../algorithms/floyd-warshall.dart';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

class GridStateManager extends ChangeNotifier {
  int gridHeight, gridWidth;
  bool startDefined = false;
  bool stopDefined = false;
  List<List<int>> gridState;

  GridStateManager({this.gridHeight, this.gridWidth}) {
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
    if (gridState[x][y] != 2 && gridState[x][y] != 3 && gridState[x][y] != 1) {
      gridState[x][y] = tileType;
      notifyListeners();
    }
  }

  void visualizeAstar() async {
    aStar2D(Maze.parse(gridState), this);
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

  void visualizeDijkstras() {
    Dijkstra d = new Dijkstra(this);
    d.findPathFromGraph(d.parse(gridState));
  }

  void visualizeBFS() {
    BFS bfs = new BFS(this);
    bfs.runBFS(bfs.parse(this.gridState));
  }

  void visualizeDFS() {
    DFS dfs = new DFS(this);
    dfs.runDFS(dfs.parse(this.gridState));
  }

  void visualizeBFord() {
    BFord bford = new BFord(this);
    bford.fillEdges(bford.parse(this.gridState));
    bford.bellmanFordShortestDistances();
  }

  void visualizeFWarshall() {
    FWarshall fWarshall = new FWarshall(gridHeight, gridWidth, this);
    fWarshall.parse(gridState);
    fWarshall.floydwarshall();
  }
}
