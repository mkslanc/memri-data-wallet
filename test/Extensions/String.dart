import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

void main() {
  test('testCamelCaseToWords', () {
    expect("dateModified".camelCaseToWords(), equals("Date modified"));
    expect("picturesOfPerson".camelCaseToWords(), equals("Pictures of person"));
    expect("word".camelCaseToWords(), equals("Word"));
  });
}
