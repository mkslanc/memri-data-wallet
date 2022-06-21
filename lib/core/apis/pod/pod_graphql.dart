import 'dart:convert';

import "pod_requests.dart";
import "pod_connection_details.dart";
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

Future<http.Response> execute_graphql(PodConnectionDetails connection, String query) async {
  var request = PodStandardRequest.queryGraphQL(query);
  return await request.execute(connection);
}

// Inbox

class Item {
  String type;
  Map<String, dynamic> properties;
  Map<String, EdgeList> edges;

  Item({
    required this.type,
    this.properties = const {},
    this.edges = const {},
  });

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
  String  name;
  List<Item> targets;

  EdgeList({
    required this.name,
    this.targets = const []
  });

  Item? first() {
    return this.targets.firstOrNull;
  }
}

List<Item> parseGQLResponse(String bodyStr) {
  List<Item> result = [];
  Map<String, dynamic> body = jsonDecode(bodyStr);
  List<dynamic> data = body['data'];
  
  data.forEach((itemMap) =>
    result.add(Item.fromJson(itemMap))
  );

  return result;
}

// Dataset
Future<List<Item>> getDataset(PodConnectionDetails connection, String datasetName) async {
  var query = '''
    query {
      Dataset (filter: {name: {eq: "$datasetName"}}) {
          type
          id
          name
          entry {
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
  return parseGQLResponse(response.body);
}

void testGetDataset(PodConnectionDetails connection) async {
  // TODO add example-dataset from here instead of pymemri
  var items = await getDataset(connection, "example-dataset");
  items.forEach((item) {print("${item.type}, ${item.properties}");});

  if (items.length > 0) {
    var content = items[0].getEdges("entry")!.first()!.getEdges("data")!.first()!.get("content");
    print(content);
  }
}


// Future<http.Response> getMessageChannels(PodConnectionDetails connection, String service) async {
//     var query = '''
//   query {
//     MessageChannel (filter: {eq: {service: "$service"}}) {
//       id
//       service
//       name
//       topic
//       photo {
//         id
//         file {
//           fileName
//           sha256
//         }
//         thumbnail {
//           fileName
//           sha256
//         }
//       }
//     }
//   }''';
//   return execute_graphql(connection, query);
// }





// Future<http.Response> getChannelMessages(
//     PodConnectionDetails connection,
//     String channelId,
//     int limit,
//     int offset,
//   ) async {
//     var query = '''
//   query {
//     MessageChannel (filter: {eq: {id: "$channelId"}}) {
//       id
//       ~messageChannel (limit: $limit offset: $offset order_asc: dateReceived) {
//         dateReceived
//         content
//         sender {

//         }
//       }
//     }
//   }''';
//   return execute_graphql(connection, query);
// }

// // Projects

// Future<http.Response> FindAllProjects(PodConnectionDetails connection) async {
//   var query = '''
//   query {
//     Project {
//       id
//       name
//       gitlabUrl
//     }
//   }''';
//   return execute_graphql(connection, query);
// }


// Future<http.Response> getProjectDatasets(PodConnectionDetails connection, String projectId) async {
//   var query = '''
//   query {
//     Project (filter: {eq: {id: "$projectId"}}) {
//       id
//       name
//       gitlabUrl
//       dataset {
//         id
//         name
//         queryStr
//       }
//     }
//   }''';
//   return execute_graphql(connection, query);
// }
