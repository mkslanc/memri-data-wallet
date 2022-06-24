import 'dart:convert';
import 'package:memri/controllers/pod_api.dart';
import 'package:memri/core/apis/pod/item.dart';
import "pod_connection_details.dart";
import 'package:http/http.dart' as http;




// Dataset



// Inbox

// Future<List<Item>> getMessageChannels(PodConnectionDetails connection) async {
//   var query = '''
//     query {
//       MessageChannel (limit: 1000) {
//         id
//         name
//         photo {
//           id
//           file {
//             sha256
//           }
//         }
//         ~messageChannel (limit: 1, order_desc: dateReceived) {
//           dateReceived
//         }
//       }
//     }
//   ''';

//   var response = await execute_graphql(connection, query);
//   return parseGQLResponse(response);
// }

// Future<List<Item>> getChannelMessages(
//     {required PodConnectionDetails connection,
//     required String chatID,
//     int limit = 100,
//     int offset = 0}) async {
//   var query = '''
//     query {
//       MessageChannel (filter: {id: {eq: "$chatID"}}) {
//         id
//         ~messageChannel (limit: $limit, offset: $offset) {
//           dateReceived
//           content
//         }
//       }
//     }
//   ''';

//   var response = await execute_graphql(connection, query);
//   return parseGQLResponse(response);
// }


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
