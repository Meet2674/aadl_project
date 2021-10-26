import 'dart:io';
import 'dart:math' as math;
import 'package:flash_chat/models/GridStateManagement.dart';
import 'package:flutter/cupertino.dart';

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

// Class to define an edge
class Edge {
  Node source;
  Node destination;
  int weight;
  // Constructor
  Edge(Node source, Node destination, int weight) {
    this.source = source;
    this.destination = destination;
    this.weight = weight;
  }
}

// Class to define a graph
class BFord {
  int numVertices;
  int numEdges;
  var edges;
  Node start;
  Node stop;
  GridStateManager gridStateManager;
  var nodeList;
  var parents = {};

  void justWait({int numberOfmilliSeconds}) async {
    await Future.delayed(Duration(microseconds: numberOfmilliSeconds));
  }

  // Constructor
  BFord(this.gridStateManager) {
    numVertices = 0;
    numEdges = 0;
    edges = [];
    nodeList = [];
  }

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
        this.numVertices += 1;
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
        nodeList.add(Node(i, j));
        // print('${Node(i, j)} : ${graph[Node(i, j)]}');
      }
    }
    return graph;
  }

  // Method to add an edge to the graph
  void add_edge(Node src, Node dest, int wt) {
    Edge edge = Edge(src, dest, wt);
    this.edges.add(edge);
  }

  void fillEdges(Map adjencyList) {
    adjencyList.keys.forEach((node) {
      adjencyList[node].forEach((child) {
        this.add_edge(node, child, 1);
      });
    });
    this.numEdges = edges.length;
  }

  /* Method to find shortest distances of all vertices from a source vertex
     using Bellman Ford algorithm */
  void bellmanFordShortestDistances() async {
    // Using maximum int value as infinity
    const int int64MaxValue = 9223372036854775807;
    var src = start;
    var distances = {};

    // Initializing the distances array

    nodeList.forEach((i) {
      distances[i] = int64MaxValue;
    });
    distances[src] = 0;
    bool changed;
    // Finding shortest distances
    for (int i = 0; i < this.numVertices - 1; i++) {
      changed = false;
      for (int j = 0; j < this.numEdges; j++) {
        Node srce = this.edges[j].source;
        Node desti = this.edges[j].destination;
        gridStateManager.drawPathTiles(srce.x, srce.y, 6);
        gridStateManager.drawPathTiles(desti.x, desti.y, 6);
        await justWait(numberOfmilliSeconds: 1000);
        int wt = this.edges[j].weight;
        if (distances[srce] != int64MaxValue &&
            distances[desti] > distances[srce] + wt) {
          distances[desti] = distances[srce] + wt;
          changed = true;
          parents[desti] = srce;
        }
        gridStateManager.drawPathTiles(srce.x, srce.y, 5);
        gridStateManager.drawPathTiles(desti.x, desti.y, 5);
        await justWait(numberOfmilliSeconds: 500);
      }
      if (!changed) {
        print("Early breaking");
        break;
      }
    }
    print('Algo Completed');
    getPath();
  }

  void getPath() async {
    var curr = parents[stop];
    while (curr != start) {
      gridStateManager.drawPathTiles(curr.x, curr.y, 4);
      await justWait(numberOfmilliSeconds: 100000);
      curr = parents[curr];
    }
  }
}
