import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
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
          title = phone.value;
        }
        break;
      case "Person":
        bgColor = Color(0xff3A5EB3);
        var firstName = (await widget.item?.property("firstName"))?.$value;
        if (firstName is PropertyDatabaseValueString) {
          title = firstName.value;
        }
        var lastName = (await widget.item?.property("lastName"))?.$value;
        if (lastName is PropertyDatabaseValueString) {
          title = "$title ${lastName.value}";
        }
        break;
      case "Relationship":
        bgColor = Color(0xff3A5EB3);
        var edgeItem = await widget.item?.edgeItem("relationship");
        if (edgeItem != null) {
          var firstName = (await edgeItem.property("firstName"))?.$value;
          if (firstName is PropertyDatabaseValueString) {
            title = firstName.value;
          }
          var lastName = (await edgeItem.property("lastName"))?.$value;
          if (lastName is PropertyDatabaseValueString) {
            title = "$title ${lastName.value}";
          }
        }

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var foregroundColor = Colors.white;
    var inputItem = widget.item;
    if (inputItem != null) {
      return FutureBuilder(
          future: _resolveItemProperties,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                decoration: BoxDecoration(
                    color: bgColor, borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
                        decoration: BoxDecoration(
                            color: Color(0xffafafaf),
                            borderRadius: BorderRadius.all(Radius.circular(20))),
                        child: Text(
                          widget.item?.type ?? "",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        )),
                    Container(
                        padding: EdgeInsets.fromLTRB(5, 3, 9, 3),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600, color: foregroundColor)))
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
