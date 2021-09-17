import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/UI/Renderers/GeneralEditorRenderer.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

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

  Color bgColor = Color(0xffffffff);

  late final Future _resolveItemProperties;

  @override
  initState() {
    super.initState();
    _resolveItemProperties = resolveItemProperties();
  }

  Future<void> resolveItemProperties() async {
    switch (widget.item?.type) {
      case "PhoneNumber":
        bgColor = Color(0xffeccf23);
        var phone = (await widget.item?.property("phoneNumber"))?.$value;
        if (phone is PropertyDatabaseValueString) {
          value = phone.value;
        }
        title = "Phone";
        break;
      case "Address":
        bgColor = Color(0xffeccf23);
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
        bgColor = Color(0xffeccf23);
        var url = (await widget.item?.property("url"))?.$value;
        if (url is PropertyDatabaseValueString) {
          value = url.value;
        }
        title = "Web";
        break;
      case "Person":
        bgColor = Color(0xff3A5EB3);
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
        bgColor = Color(0xff3A5EB3);
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
              return IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GeneralEditorHeader(content: title.toUpperCase()),
                    Text(value),
                    Divider(height: 1)
                  ],
                ),
              );
            }
            return Empty();
          });
    }
    return Empty();
  }
}
