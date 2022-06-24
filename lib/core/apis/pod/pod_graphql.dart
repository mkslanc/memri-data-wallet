import 'dart:convert';
import 'package:memri/controllers/pod_api.dart';
import 'package:memri/core/apis/pod/item.dart';
import "pod_connection_details.dart";
import 'package:http/http.dart' as http;





// Dataset



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
