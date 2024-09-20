import 'package:flutter/material.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:provider/provider.dart';

import '../../../cvu/controllers/view_context_controller.dart';
import '../../../utilities/helpers/app_helper.dart';



/// This view is displayed when the user presses the search button
/// It moves itself to be above the keyboard automatically
class SearchTopBar extends StatefulWidget {
  final ViewContextController viewContext;

  SearchTopBar({required this.viewContext});

  @override
  _SearchTopBarState createState() => _SearchTopBarState();
}

class _SearchTopBarState extends State<SearchTopBar> {
  // Create a FocusNode
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Dispose of the FocusNode when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: Row(
            children: [
              SizedBox(
                child: IconButton(
                    style:
                        TextButton.styleFrom(foregroundColor: app.colors.brandPurple),
                    icon: Icon(Icons.close),
                    onPressed: () {
                      widget.viewContext.searchString = null;
                      Provider.of<UIStateProvider>(context, listen: false).toggleSearchBar();
                    }),
              ),
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode, // Assign the FocusNode
                  onChanged: (value) =>
                      setState(() => widget.viewContext.searchString = value),
                  initialValue: widget.viewContext.searchString,
                  decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "Search",
                      hintStyle: TextStyle(color: app.colors.textLight),
                      contentPadding: EdgeInsets.all(5)),
                ),
              ),
              SizedBox(
                  child: Icon(
                    Icons.search,
                    color: app.colors.brandPurple,
                    size: 24,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
