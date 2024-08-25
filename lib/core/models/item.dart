import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class Item {
  String type;
  Map<String, dynamic> properties;
  Map<String, EdgeList> edges;

  Item({
    required String this.type,
    Map<String, dynamic>? properties,
    Map<String, EdgeList>? edges,
  })  : properties = properties ?? {},
        edges = edges ?? {};

  List<Edge>? getEdges(String edgeName) {
    var edgeList = this.edges[edgeName];
    if (edgeList == null) {
      return null;
    } else {
      List<Edge> edges = [];
      edgeList.targets.forEach((target) {
        edges.add(Edge(
          source: this,
          target: target,
          name: edgeList.name,
        ));
      });
      return edges;
    }
  }

  List<Edge>? getAllEdges() {
    List<Edge> allEdges = [];
    this.edges.forEach((edgeName, edgeList) {
      edgeList.targets.forEach((target) {
        allEdges.add(Edge(
          source: this,
          target: target,
          name: edgeName,
        ));
      });
    });
    return allEdges.isEmpty ? null : allEdges;
  }

  List<Item>? getEdgeTargets(String edgeName) {
    return this.edges[edgeName]?.targets;
  }

  dynamic get(String propertyName) {
    return this.properties[propertyName] ?? null;
  }

  void setIdIfNotExists() {
    if (this.get("id") == null) {
      this.properties["id"] = Uuid().v4();
    }
  }

  get id => get("id");

  factory Item.fromJson(Map<String, dynamic> itemMap) {
    String? type;
    Map<String, dynamic> properties = {};
    Map<String, EdgeList> edges = {};
    itemMap.forEach((key, value) {
      if (key == "type") {
        type = value;
      } else if (value is List) {
        List<Item> targets = [];
        value.forEach((edgeMap) {
          targets.add(Item.fromJson(edgeMap));
        });
        edges[key] = EdgeList(name: key, targets: targets);
      } else {
        properties[key] = value;
      }
    });
    if (type == null) {
      throw Exception("Attempted to create item without an item type.");
    }
    return Item(
      type: type!,
      properties: properties,
      edges: edges,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    result.addAll(this.properties);
    result["type"] = this.type;
    return result;
  }
}

class EdgeList {
  // EdgeList is a separate list to support future edge functionalities
  String name;
  List<Item> targets;

  EdgeList({
    required this.name,
    required List<Item>? targets,
  }) : targets = targets ?? [];

  Item? first() {
    return this.targets.firstOrNull;
  }
}

class Edge {
  Item source;
  Item target;
  String name;

  Edge({
    required this.source,
    required this.target,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      "_source": this.source.get("id"),
      "_target": this.target.get("id"),
      "_name": this.name,
    };
  }
}
