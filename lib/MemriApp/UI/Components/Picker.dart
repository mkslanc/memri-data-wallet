import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

class Picker<T> extends StatefulWidget {
  final String label;
  final FutureBinding<T> selection;
  final Map<T, String> group;

  Picker(this.label, {required this.selection, required this.group});

  @override
  _PickerState<T> createState() => _PickerState<T>();
}

class _PickerState<T> extends State<Picker<T>> {
  late final Future _init;

  @override
  void initState() {
    super.initState();
    _init = init();
  }

  T? _selectedValue;

  init() async {
    _selectedValue = await widget.selection.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          home: Scaffold(
                            appBar: PreferredSize(
                                preferredSize: Size.fromHeight(32.0),
                                child: AppBar(
                                  leading: TextButton(
                                    style: TextButton.styleFrom(primary: Colors.black),
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 24,
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  centerTitle: true,
                                  primary: false,
                                  backgroundColor: Colors.white,
                                  excludeHeaderSemantics: true,
                                  title: Center(
                                      child: Text(
                                    widget.label,
                                    style: TextStyle(color: Colors.black, fontSize: 17),
                                  )),
                                )),
                            body: Column(
                              children: widget.group
                                  .map(
                                    (tag, element) => MapEntry(
                                        tag,
                                        ListTile(
                                          title: Text(element),
                                          trailing: Radio<T>(
                                            value: tag,
                                            groupValue: _selectedValue,
                                            onChanged: (T? newValue) {
                                              setState(() {
                                                _selectedValue = newValue;
                                                widget.selection.set(newValue!);
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                        )),
                                  )
                                  .values
                                  .toList(),
                            ),
                          ),
                        );
                      })),
                  child: Row(
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(color: Colors.black),
                      ),
                      Spacer(),
                      _selectedValue != null
                          ? Text(
                              widget.group[_selectedValue]!,
                              style: TextStyle(color: Colors.black38),
                            )
                          : Empty(),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.black38,
                      )
                    ],
                  ))
            ],
          );
        });
  }
}
