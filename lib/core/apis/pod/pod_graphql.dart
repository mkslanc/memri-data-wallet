import 'dart:convert';

import '../../../constants/app_logger.dart';
import "pod_requests.dart";
import "pod_connection_details.dart";
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

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

  EdgeList? getEdges(String edgeName) {
    return this.edges[edgeName] ?? null;
  }

  dynamic get(String propertyName) {
    return this.properties[propertyName] ?? null;
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

Future<http.Response?> execute_graphql(
    PodConnectionDetails connection, String query) async {
  var request = PodStandardRequest.queryGraphQL(query);
  var response = await request.execute(connection);
  if (response.statusCode != 200) {
    var error_msg = "ERROR: ${response.statusCode} ${response.reasonPhrase}";
    AppLogger.err(error_msg);
    return null;
  }
  return response;
}

List<Item> parseGQLResponse(http.Response? response) {
  // TODO error handling. Returns an empty list on bad response for now.
  if (response == null) {
    return [];
  }
  List<Item> result = [];
  Map<String, dynamic> body = jsonDecode(response.body);
  List<dynamic> data = body['data'] ?? [];

  data.forEach((itemMap) => result.add(Item.fromJson(itemMap)));

  return result;
}

// Dataset

Future<List<Item>> getDataset(
    PodConnectionDetails connection, String datasetName) async {
  var query = '''
    query {
      Dataset (filter: {name: {eq: "$datasetName"}}) {
          type
          id
          name
          entry (limit: 5000, offset: 0) {
              id
              data {
                  content
              }
              annotation {
                  labelValue
              }
          }
      }
  }''';
  var response = await execute_graphql(connection, query);
  return parseGQLResponse(response);
}

// Example usage
// TODO remove
// void testGetDataset(PodConnectionDetails connection) async {
//   var items = await getDataset(connection, "example-dataset");
//   if (items.isEmpty) {
//     print("No results");
//   }
//   items.forEach((item) {
//     print("${item.type}, ${item.properties}");
//   });

//   if (items.length > 0) {
//     var content = items[0]
//         .getEdges("entry")
//         ?.first()
//         ?.getEdges("data")
//         ?.first()
//         ?.get("content");
//     print(content);
//   }
// }
