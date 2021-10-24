import 'dart:math' as math;
import 'dart:collection';
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

class BFS {
  Node start;
  Node stop;
  GridStateManager gridStateManager;
  BFS(this.gridStateManager);
  Map parent = {};
  Map isVisted = {};

  Map parse(gridState) {
    Map graph = {};
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
        isVisted[Node(i, j)] = false;
        // print('${Node(i, j)} : ${graph[Node(i, j)]}');
      }
    }
    return graph;
  }

  void justWait({int numberOfmilliSeconds}) async {
    await Future.delayed(Duration(milliseconds: numberOfmilliSeconds));
  }

  void runBFS(Map graph) async {
    Queue q = new Queue();
    q.add(start);
    while (q.isNotEmpty) {
      var curr = q.first;
      q.removeFirst();
      isVisted[curr] = true;
      if (curr == stop) {
        findPath();
        return;
      }
      gridStateManager.drawPathTiles(curr.x, curr.y, 6);
      await justWait(numberOfmilliSeconds: 25);
      gridStateManager.drawPathTiles(curr.x, curr.y, 5);
      await justWait(numberOfmilliSeconds: 50);
      graph[curr].forEach((child) {
        if (!isVisted[child]) {
          isVisted[child] = true;
          q.add(child);
          parent[child] = curr;
        }
      });
    }
    print('Path not found');
  }

  void findPath() async {
    var pathTile = stop;
    while (pathTile != start) {
      pathTile = parent[pathTile];
      gridStateManager.drawPathTiles(pathTile.x, pathTile.y, 4);
      await justWait(numberOfmilliSeconds: 50);
    }
  }
}
