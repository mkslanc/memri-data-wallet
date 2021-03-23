import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('testDecodeSchemaProperty', () {
    var propertyString = '{ "item_type": "Review", "property": "title", "value_type": "string" }';
    var decodedJson = jsonDecode(propertyString);
    SchemaProperty property = SchemaProperty.fromJson(decodedJson);
    expect(property.itemType, "Review");
    expect(property.property, "title");
    expect(property.valueType, "string");
  });

  test('testEncodeSchemaProperty', () {
    var propertyString = '{ "item_type": "Review", "property": "title", "value_type": "string" }';
    var decodedJson = jsonDecode(propertyString);
    SchemaProperty property = SchemaProperty.fromJson(decodedJson);
    var encoded = jsonEncode(property);
    expect(encoded, '{"item_type":"Review","property":"title","value_type":"string"}');
  });

  test('testDecodeSchemaEdge', () {
    var edgeString = '{ "source_type": "Photo", "edge": "file", "target_type": "File" }';
    var decodedJson = jsonDecode(edgeString);
    SchemaEdge edge = SchemaEdge.fromJson(decodedJson);
    expect(edge.sourceType, "Photo");
    expect(edge.edge, "file");
    expect(edge.targetType, "File");
    expect(edge.allowsMultiple, false);
  });

  test('testDecodeSchemaEdgeArray', () {
    var edgeString = '{ "source_type": "Email", "edge": "attachment", "target_type": "File[]" }';
    var decodedJson = jsonDecode(edgeString);
    SchemaEdge edge = SchemaEdge.fromJson(decodedJson);
    expect(edge.sourceType, "Email");
    expect(edge.edge, "attachment");
    expect(edge.targetType, "File");
    expect(edge.allowsMultiple, true);
  });

  test('testEncodeSchemaEdge', () {
    var edgeString = '{ "source_type": "Photo", "edge": "file", "target_type": "File" }';
    var decodedJson = jsonDecode(edgeString);
    SchemaEdge edge = SchemaEdge.fromJson(decodedJson);
    var encoded = jsonEncode(edge);
    expect(encoded, '{"source_type":"Photo","edge":"file","target_type":"File"}');
  });

  test('testEncodeSchemaEdgeArray', () {
    var edgeString = '{ "source_type": "Email", "edge": "attachment", "target_type": "File[]" }';
    var decodedJson = jsonDecode(edgeString);
    SchemaEdge edge = SchemaEdge.fromJson(decodedJson);
    var encoded = jsonEncode(edge);
    expect(encoded, '{"source_type":"Email","edge":"attachment","target_type":"File[]"}');
  });

  test('testLoadSchemaFromJSON', () async {
    await Schema.loadFromFile(isRunningTests: true);
  });
}
