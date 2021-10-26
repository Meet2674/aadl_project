import 'dart:math' as math;
import 'package:flash_chat/models/GridStateManagement.dart';

class Node {
  Node(this.x, this.y);
  @override
  String toString() => ' Tile:($x,$y)';
  @override
  bool operator ==(Object other) =>
      other is Node && x == other.x && y == other.y;
  @override
  int get hashCode => '$x,$y'.hashCode;
  int x;
  int y;
}

class FWarshall {
  var pred = [];
  var weight = {};
  Node start;
  Node stop;
  int rows;
  int cols;
  Map graph;
  GridStateManager gridStateManager;

  void justWait({int numberOfmilliSeconds}) async {
    await Future.delayed(Duration(microseconds: numberOfmilliSeconds));
  }

  FWarshall(this.rows, this.cols, this.gridStateManager) {
    graph = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        var row = {};
        for (int i = 0; i < rows; i++) {
          for (int j = 0; j < cols; j++) {
            row[Node(i, j)] = 9999;
          }
        }
        weight[Node(r, c)] = row;
      }
    }
  }

  void parse(gridState) {
    int rows = gridState.length;
    int cols = gridState[0].length;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        List currList = [];
        if (gridState[i][j] == 1) {
          continue;
        }

        if (gridState[i][j] == 2) {
          start = Node(i, j);
        }
        if (gridState[i][j] == 3) {
          stop = Node(i, j);
        }
        for (var newX = math.max(0, i - 1);
            newX <= math.min(rows - 1, i + 1);
            newX++) {
          for (var newY = math.max(0, j - 1);
              newY <= math.min(cols - 1, j + 1);
              newY++) {
            if ((newX == i || newY == j) && gridState[newX][newY] != 1) {
              currList.add(Node(newX, newY));
            }
          }
        }
        currList.remove(Node(i, j));
        graph[Node(i, j)] = currList;
      }
    }
    this.parseList();
  }

  void parseList() {
    graph.keys.forEach((parent) {
      weight[parent][parent] = 0;
      graph[parent].forEach((child) {
        weight[parent][child] = 1;
      });
    });
  }

  int minimum(var a, var b) {
    if (a <= b) {
      return a;
    } else {
      return b;
    }
  }

  void floydwarshall() async {
    for (int k1 = 0; k1 < rows; k1++) {
      for (int k2 = 0; k2 < cols; k2++) {
        for (int r = 0; r < rows; r++) {
          for (int c = 0; c < cols; c++) {
            for (int i = 0; i < rows; i++) {
              for (int j = 0; j < cols; j++) {
                weight[Node(r, c)][Node(i, j)] = minimum(
                    weight[Node(r, c)][Node(i, j)],
                    weight[Node(r, c)][Node(k1, k2)] +
                        weight[Node(k1, k2)][Node(i, j)]);
                // gridStateManager.drawPathTiles(r, c, 6);
                // gridStateManager.drawPathTiles(i, j, 6);
                // gridStateManager.drawPathTiles(k1, k2, 6);
                // await justWait(numberOfmilliSeconds: 0);
                // gridStateManager.drawPathTiles(r, c, 0);
                // gridStateManager.drawPathTiles(i, j, 0);
                // gridStateManager.drawPathTiles(k1, k2, 0);
              }
            }
          }
        }
      }
    }
    var curr = stop;
    var path = [];
    while (curr != start) {
      int mincost = 10000;
      for (var adjnode in graph[curr]) {
        if (!path.contains(adjnode)) {
          gridStateManager.drawPathTiles(adjnode.x, adjnode.y, 5);
          await justWait(numberOfmilliSeconds: 1000);
        }
        if (weight[start][adjnode] < mincost) {
          curr = adjnode;
          mincost = weight[start][adjnode];
        }
      }
      path.add(curr);
      gridStateManager.drawPathTiles(curr.x, curr.y, 4);
      await justWait(numberOfmilliSeconds: 1000);
    }

    // var dist = [];
    // for (var i = 0; i < n; i++) {
    //   var distlist = [];
    //   var predlist = [];
    //   for (var j = 0; j < n; j++) {
    //     distlist.insert(j, weight[i][j]);
    //     predlist.insert(j, -999);
    //   }
    //   dist.insert(i, distlist);
    //   pred.insert(i, predlist);
    // }
    // for (int k = 0; k < n; k++) {
    //   for (int i = 0; i < n; i++) {
    //     var distlist = [];
    //     var predlist = [];
    //
    //     for (int j = 0; j < n; j++) {
    //       distlist.insert(j, minimum(dist[i][j], dist[i][k] + dist[k][j]));
    //       predlist.insert(j, k);
    //     }
    //
    //     dist.removeAt(i);
    //     dist.insert(i, distlist);
    //     pred.removeAt(i);
    //     pred.insert(i, predlist);
    //   }
    // }

    // print(
    //     "The matrix shows the shortest distance between each of the vertices:");
    //
    // for (var i = 0; i < n; i++) {
    //   print(dist[i]);
    // }
  }
}
