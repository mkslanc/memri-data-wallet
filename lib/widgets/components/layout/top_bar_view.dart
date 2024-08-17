import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../cvu/constants/cvu_color.dart';
import '../../../cvu/controllers/view_context_controller.dart';
import '../../../cvu/models/cvu_value.dart';
import '../../../cvu/models/cvu_value_constant.dart';
import '../../../cvu/services/cvu_action.dart';
import '../../../providers/app_provider.dart';
import '../buttons/action_button.dart';


/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  //final void Function() onSearchPressed;

  TopBarView(/*{required this.onSearchPressed}*/);

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
  late ViewContextController? viewContext;

  @override
  Widget build(BuildContext context) {

    viewContext = Provider.of<AppProvider>(context, listen: false).currentViewContext;
    var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton");
    var editActionButtonArray = viewContext?.viewDefinitionPropertyResolver.stringArray("editActionButton");
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(children: [
            Row(
              children: [
                /*SizedBox(
                  width: 80,
                  child: Row(
                    children: [
                      if (!Navigator.canPop(context))
                        TextButton(
                          style: TextButton.styleFrom(padding: EdgeInsets.all(27)),
                          onPressed: () => {},//TODO: widget.sceneController.navigationIsVisible.value = true,
                          child: Icon(
                            Icons.dehaze,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                )*/
              ],
            ),
            Expanded(
              child: SizedBox(
                height: 78,
                child: TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                  onPressed: (){},//TODO: widget.onSearchPressed,
                  child: Row(
                    children: [
                      Text(
                        "Search in App",
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: CVUColor.predefined["brandTextGrey"]),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 100),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (editActionButtonArray != null && editActionButtonArray.isNotEmpty)
                      ActionButton(
                        action: cvuAction(editActionButtonArray.first)!.call(vars: {
                          "icon": CVUValueConstant(CVUConstantString("pencil"))
                        }),
                        viewContext: viewContext!.getCVUContext(),
                      ),
                    if (actions != null)
                      ...actions.map((action) =>
                          ActionButton(action: action, viewContext: viewContext!.getCVUContext()))
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              ),
            ),
          ]),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}
