import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUIElementFamily.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUINode.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Expression.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Enum.dart';

enum UIElementProperties {
  resizable,
  show,
  alignment,
  align,
  textAlign,
  spacing,
  title,
  text,
  image,
  nopadding,
  press,
  bold,
  italic,
  underline,
  strikethrough,
  list,
  viewName,
  view,
  arguments,
  location,
  address,
  systemName,
  cornerRadius,
  hint,
  value,
  datasource,
  defaultValue,
  empty,
  style,
  frame,
  color,
  font,
  padding,
  background,
  rowbackground,
  cornerborder,
  border,
  margin,
  shadow,
  offset,
  blur,
  opacity,
  zindex,
  minWidth,
  maxWidth,
  minHeight,
  maxHeight,
  actionButton,
  onPress
}

enum CVUErrorType { error, warning }

class CVUErrorAnnotation {
  CVUErrorType type;
  int row;
  int column;
  String message;

  CVUErrorAnnotation(
      {required this.type, required this.row, required this.column, required this.message});
}

class CVUValidator {
  List<CVUErrorAnnotation> warnings = [];
  List<CVUErrorAnnotation> errors = [];

  DatabaseController databaseController;
  CVULookupController lookupController;

  CVUValidator(
      {DatabaseController? databaseController, required CVULookupController this.lookupController})
      : this.databaseController = databaseController ?? AppController.shared.databaseController;

  valueToTruncatedString(value) {
    var str = value.toString();
    if (str.length < 20) {
      return str;
    }
    return str.substring(0, 17) + "...";
  }

  validateRequiredProperties(CVUUINode node) {
    var requiredPropertyList = <String>[];

    switch (node.type) {
      case CVUUIElementFamily.Text:
        requiredPropertyList = ["text"];
        break;
      case CVUUIElementFamily.Textfield:
        requiredPropertyList = ["value"];
        break;
      default:
        return;
    }

    var properties = node.properties.keys;

    requiredPropertyList.forEach((requiredProperty) {
      if (!properties.contains(requiredProperty)) {
        errors.add(CVUErrorAnnotation(
            type: CVUErrorType.error,
            row: node.tokenLocation!.ln,
            column: node.tokenLocation!.ch,
            message:
                'Property $requiredProperty required for node ${node.type.inString} in ${valueToTruncatedString(node.toCVUString(0, "", false))}'));
      }
    });
  }

  validateProperty(String key, CVUValue value) {
    if (value is CVUExpressionNode) {
      return true;
    }

    var prop = EnumExtension.rawValue<UIElementProperties>(UIElementProperties.values, key);
    switch (prop) {
      case UIElementProperties.resizable:
      case UIElementProperties.title:
      case UIElementProperties.text:
      case UIElementProperties.viewName:
      case UIElementProperties.systemName:
      case UIElementProperties.hint:
      case UIElementProperties.empty:
      case UIElementProperties.style:
      case UIElementProperties.defaultValue:
        return value is String;
      case UIElementProperties.show:
      case UIElementProperties.nopadding:
      case UIElementProperties.bold:
      case UIElementProperties.italic:
      case UIElementProperties.underline:
      case UIElementProperties.strikethrough:
        return value is bool;
      case UIElementProperties.spacing:
      case UIElementProperties.cornerRadius:
      case UIElementProperties.minWidth:
      case UIElementProperties.maxWidth:
      case UIElementProperties.minHeight:
      case UIElementProperties.maxHeight:
      case UIElementProperties.blur:
      case UIElementProperties.opacity:
      case UIElementProperties.zindex:
        return value is num;
      case UIElementProperties.actionButton:
      case UIElementProperties.onPress:
        return validateAction(key, value);
      default:
        return false;
    }
  }

  // Check that there are no fields that are not known UIElement properties (warn)
  // Check that they have the right type (error)
  // Error if (required fields are missing (e.g. text for Text, image for Image)
  validateUIElement(CVUUINode element) async {
    validateRequiredProperties(element);
    await validateProperties(element.properties);
    await validateUIElements(element.children);
  }

  validateUIElements(List<CVUUINode> elements) async {
    await Future.forEach<CVUUINode>(elements, (uiNode) async {
      await validateUIElement(uiNode);
    });
  }

  String? validateActionName(String key, CVUValue cvuValue) {
    if (cvuValue is CVUValueConstant && cvuValue.value is CVUConstantArgument) {
      return (cvuValue.value as CVUConstantArgument).value;
    } else {
      errors.add(CVUErrorAnnotation(
          type: CVUErrorType.error,
          row: cvuValue.tokenLocation!.ln,
          column: cvuValue.tokenLocation!.ch,
          message:
              'Invalid action ${valueToTruncatedString(cvuValue.toCVUString(0, "", false))} for ${key}'));
      return null;
    }
  }

  validateActionType(String key, CVUValue cvuValue) {
    var actionName = validateActionName(key, cvuValue);
    if (actionName == null) {
      return;
    }
    var type = cvuAction(actionName);
    if (type == null) {
      errors.add(CVUErrorAnnotation(
          type: CVUErrorType.error,
          row: cvuValue.tokenLocation!.ln,
          column: cvuValue.tokenLocation!.ch,
          message: 'Invalid action ${valueToTruncatedString(actionName)} for ${key}'));
    }
    return type;
  }

  // Check that there are no fields that are not known Action properties (warn)
  // Check that they have the right type (error)
  bool validateAction(String key, CVUValue cvuValue) {
    if (cvuValue is CVUValueArray) {
      var isValid = true;
      var array = cvuValue.value;
      for (var i = 0; i < array.length; i++) {
        if (i > 0 && array[i] is CVUValueSubdefinition) {
          continue;
        }
        var action = array[i];
        var type = validateActionType(key, action);
        if (type != null) {
          var def = array.asMap()[i + 1];
          if (def is CVUValueSubdefinition) {
            // var keys = def.value.properties.keys;
            // for (var key in keys) {
            //TODO validate action keys
            // }
          }
        } else {
          isValid = false;
        }
      }
      return isValid;
    } else {
      var type = validateActionType(key, cvuValue);
      return type != null;
    }
  }

  validateProperties(Map<String, CVUValue> properties) async {
    await Future.forEach<MapEntry<String, CVUValue>>(properties.entries, (entry) async {
      var value = entry.value;
      var key = entry.key;
      if (value is CVUValueSubdefinition) {
        await validateDefinition(value.value);
      } else {
        validateProperty(key, value);
      }
    });
  }

  validateDefinitions(List<CVUParsedDefinition> definitions) async {
    await Future.forEach<CVUParsedDefinition>(definitions, (subDefinition) async {
      await validateDefinition(subDefinition.parsed);
    });
  }

  validateDefinition(CVUDefinitionContent definition) async {
    await validateProperties(definition.properties);
    await validateDefinitions(definition.definitions);
    await validateUIElements(definition.children);
  }

  Future<bool> validate(List<CVUParsedDefinition> definitions) async {
    warnings = [];
    errors = [];

    await validateDefinitions(definitions);

    return errors.isEmpty;
  }
}
