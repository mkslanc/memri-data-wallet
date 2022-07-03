import 'package:collection/collection.dart';

class Item {
  String type;
  String? id;
  Map<String, dynamic>? properties;

  Map<String, EdgeList>? edges;

  Item({
    required String this.type,
    String? id,
    Map<String, dynamic>? properties,
    Map<String, EdgeList>? edges,
  })  : properties = properties ?? {},
        edges = edges ?? {},
        id = id ?? null;

  EdgeList? getEdges(String edgeName) {
    return this.edges![edgeName] ?? null;
  }

  dynamic get(String propertyName) {
    return this.properties![propertyName] ?? null;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> obj = properties ?? {};
    obj["type"] = type;
    if (id != null) {
      obj["id"] = id;
    }
    return obj;
  }

  static Item fromJson(Map<String, dynamic> itemMap) {
    String type = "Item";
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
    return Item(
      type: type,
      properties: properties,
      edges: edges,
    );
  }
}

class EdgeList {
  // EdgeList is a separate list to support future edge functionalities
  String name;
  List<Item> targets;

  EdgeList({
    required this.name,
    List<Item>? targets,
  }) : targets = targets ?? [];

  Item? first() {
    return this.targets.firstOrNull;
  }
}
