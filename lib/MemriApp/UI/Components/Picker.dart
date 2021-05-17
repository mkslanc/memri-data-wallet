import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

class Picker<T> extends StatefulWidget {
  final String label;
  final FutureBinding<T> selection;
  final Map<T, String> group;

  Picker(this.label, {required this.selection, required this.group});

  @override
  _PickerState<T> createState() => _PickerState<T>();
}

class _PickerState<T> extends State<Picker<T>> {
  @override
  void initState() {
    super.initState();
    init();
  }

  T? _selectedValue;

  init() async {
    widget.selection.get().then((value) => setState(() => _selectedValue = value));
  }

  @override
  Widget build(BuildContext context) {
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
                      body: FutureBuilder<T>(
                        future: widget.selection.get(),
                        builder: (futureContext, snapshot) => snapshot.hasData
                            ? Column(
                                children: widget.group
                                    .map(
                                      (tag, element) => MapEntry(
                                          tag,
                                          ListTile(
                                            title: Text(element),
                                            trailing: Radio<T>(
                                              value: tag,
                                              groupValue: snapshot.data,
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
                              )
                            : SizedBox.shrink(),
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
                    : Text(""),
                Icon(
                  Icons.chevron_right,
                  color: Colors.black38,
                )
              ],
            ))
      ],
    );
  }
}
