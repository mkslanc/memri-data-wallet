import 'package:flutter/material.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/general_editor_renderer.dart';

// ignore: must_be_immutable
class MemriButton extends StatefulWidget {
  final ItemRecord? item;
  final DatabaseController db;

  MemriButton({required this.item, required this.db});

  @override
  _MemriButtonState createState() => _MemriButtonState();
}

class _MemriButtonState extends State<MemriButton> {
  String title = "";
  String value = "";

  Color? bgColor;
  Color foregroundColor = Color(0xff737373);

  late final Future _resolveItemProperties;

  @override
  initState() {
    super.initState();
    _resolveItemProperties = resolveItemProperties();
  }

  Future<void> resolveItemProperties() async {
    switch (widget.item?.type) {
      case "PhoneNumber":
        var phone = (await widget.item?.property("phoneNumber"))?.$value;
        if (phone is PropertyDatabaseValueString) {
          value = phone.value;
        }
        title = "Phone";
        break;
      case "Address":
        var address = [];
        var street = (await widget.item?.property("street"))?.$value;
        if (street is PropertyDatabaseValueString) {
          address.add(street.value);
        }
        var city = (await widget.item?.property("city"))?.$value;
        if (city is PropertyDatabaseValueString) {
          address.add(city.value);
        }
        var state = (await widget.item?.property("state"))?.$value;
        if (state is PropertyDatabaseValueString) {
          address.add(state.value);
        }
        var country = await widget.item?.edgeItem("country");
        if (country != null) {
          var countryName = (await country.property("name"))?.$value;
          if (countryName is PropertyDatabaseValueString) {
            address.add(countryName.value);
          }
        }
        value = address.isNotEmpty ? address.join(", ") : "";
        title = "Address";
        break;
      case "Website":
        var url = (await widget.item?.property("url"))?.$value;
        if (url is PropertyDatabaseValueString) {
          value = url.value;
        }
        title = "Web";
        break;
      case "Person":
        var firstName = (await widget.item?.property("firstName"))?.$value;
        if (firstName is PropertyDatabaseValueString) {
          value = firstName.value;
        }
        var lastName = (await widget.item?.property("lastName"))?.$value;
        if (lastName is PropertyDatabaseValueString) {
          value = "$value ${lastName.value}";
        }
        title = "Person";
        break;
      case "Relationship":
        var edgeItem = await widget.item?.edgeItem("relationship");
        if (edgeItem != null) {
          var firstName = (await edgeItem.property("firstName"))?.$value;
          if (firstName is PropertyDatabaseValueString) {
            value = firstName.value;
          }
          var lastName = (await edgeItem.property("lastName"))?.$value;
          if (lastName is PropertyDatabaseValueString) {
            value = "$value ${lastName.value}";
          }
        }
        title = "Person";
        break;
      case "Account":
        //TODO: we definitely need to solve this chaos with property naming
        var accountName = (await widget.item?.property("handle"))?.$value;
        if (accountName is PropertyDatabaseValueString) {
          value = accountName.value;
        } else {
          accountName = (await widget.item?.property("externalId"))?.$value;
          if (accountName is PropertyDatabaseValueString) {
            value = accountName.value;
          }
        }
        var serviceName = (await widget.item?.property("service"))?.$value;
        if (serviceName is PropertyDatabaseValueString) {
          title = serviceName.value;
        } else {
          serviceName = (await widget.item?.property("itemType"))?.$value;
          if (serviceName is PropertyDatabaseValueString) {
            title = serviceName.value;
          } else {
            title = "Account";
          }
        }
        break;
      case "CategoricalPrediction":
        var name = (await widget.item?.property("name"))?.$value;
        if (name is PropertyDatabaseValueString) {
          value = name.value;
        }
        switch (value) {
          case "positive":
            bgColor = Colors.green;
            break;
          case "negative":
            bgColor = Colors.red;
            break;
          default:
            bgColor = Colors.grey;
            break;
        }
        foregroundColor = Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    var inputItem = widget.item;
    if (inputItem != null) {
      return FutureBuilder(
          future: _resolveItemProperties,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  decoration: BoxDecoration(color: bgColor),
                  child: IntrinsicHeight(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (title.isNotEmpty) GeneralEditorHeader(content: title.toUpperCase()),
                    Text(
                      value,
                      style: TextStyle(fontSize: 13, color: foregroundColor),
                    ),
                    Divider(height: 1)
                  ])));
            }
            return Empty();
          });
    }
    return Empty();
  }
}
