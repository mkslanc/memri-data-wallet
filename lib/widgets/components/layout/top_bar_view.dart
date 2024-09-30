import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/providers/ui_state_provider.dart';

import '../../../cvu/constants/cvu_color.dart';

/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  TopBarView();

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
  @override
  Widget build(BuildContext context) {
    var viewContext = GetIt.I<UIStateProvider>().currentViewContext;
    // var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton");
    // var editActionButtonArray =
    //     viewContext?.viewDefinitionPropertyResolver.stringArray("editActionButton");
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(children: [
            Expanded(
              child: SizedBox(
                height: 78,
                child: TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.all(10)),
                    onPressed: () => viewContext?.toggleSearchBar(),
                    child: Text(
                      "Search in App",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: CVUColor.predefined["brandTextGrey"]),
                      textAlign: TextAlign.center,
                    )),
              ),
            ),
            /* Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 100),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    */ /*if (editActionButtonArray != null && editActionButtonArray.isNotEmpty)
                      ActionButton(
                        action: cvuAction(editActionButtonArray.first)!.call(vars: {
                          "icon": CVUValueConstant(CVUConstantString("pencil"))
                        }),
                        viewContext: viewContext!.getCVUContext(),
                        color: Provider.of<AppProvider>(context, listen: false).isInEditMode ? Colors.blue : Colors.black,
                      ),
                    if (actions != null)
                      ...actions.map((action) =>
                          ActionButton(action: action, viewContext: viewContext!.getCVUContext()))*/ /*
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ),
            ),*/
          ]),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}
