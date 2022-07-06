import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/services/cvu_action.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_ui_element_family.dart';
import 'package:memri/cvu/models/cvu_ui_node.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/models/cvu_value_expression.dart';
import 'package:memri/utilities/extensions/enum.dart';

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
  onPress,
  speed,
  size
}

enum CVUErrorType { error, warning }

class CVUErrorAnnotation {
  CVUErrorType type;
  int row;
  int column;
  String message;

  CVUErrorAnnotation(
      {required this.type,
      required this.row,
      required this.column,
      required this.message});
}

class CVUValidator {
  List<CVUErrorAnnotation> warnings = [];
  List<CVUErrorAnnotation> errors = [];

  CVULookupController lookupController;

  CVUValidator({required CVULookupController this.lookupController});

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

    var prop = EnumExtension.rawValue<UIElementProperties>(
        UIElementProperties.values, key);
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
      case UIElementProperties.speed:
      case UIElementProperties.size:
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
  validateUIElement(CVUUINode element) {
    validateRequiredProperties(element);
    validateProperties(element.properties);
    validateUIElements(element.children);
  }

  validateUIElements(List<CVUUINode> elements) {
    elements.forEach((uiNode) {
      validateUIElement(uiNode);
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
          message:
              'Invalid action ${valueToTruncatedString(actionName)} for ${key}'));
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

  validateProperties(Map<String, CVUValue> properties) {
    properties.entries.forEach((entry) {
      var value = entry.value;
      var key = entry.key;
      if (value is CVUValueSubdefinition) {
        validateDefinition(value.value);
      } else {
        validateProperty(key, value);
      }
    });
  }

  validateDefinitions(List<CVUParsedDefinition> definitions) {
    definitions.forEach((subDefinition) {
      validateDefinition(subDefinition.parsed);
    });
  }

  validateDefinition(CVUDefinitionContent definition) {
    validateProperties(definition.properties);
    validateDefinitions(definition.definitions);
    validateUIElements(definition.children);
  }

  bool validate(List<CVUParsedDefinition> definitions) {
    warnings = [];
    errors = [];

    validateDefinitions(definitions);

    return errors.isEmpty;
  }
}
