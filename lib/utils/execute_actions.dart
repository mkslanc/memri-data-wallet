import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../constants/cvu/cvu_font.dart';
import '../core/cvu/cvu_action.dart';
import '../widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/utils/extensions/collection.dart';

executeActionsOnSubmit(CVUUINodeResolver nodeResolver, State state,
    {ValueNotifier<bool>? isDisabled, List<CVUAction>? actions, String? actionsKey}) async {
  //TODO clear up this part, if it's not thrown away on refactor
  openPopup(Map<String, dynamic> settings) {
    List<Map<String, dynamic>>? actions = settings['actions'];
    return showDialog<String>(
      context: state.context,
      builder: (BuildContext context) => AlertDialog(
          title: Text(settings['title']),
          content: Text(settings['text']),
          actions: actions?.compactMap(
            (action) {
              var title = action["title"]?.value?.value;
              if (title != null) {
                return PointerInterceptor(
                    child: TextButton(
                  onPressed: () async {
                    for (var cvuAction in action["actions"]) {
                      await cvuAction.execute(nodeResolver.pageController, nodeResolver.context);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(title),
                ));
              } else {
                return null;
              }
            },
          ).toList()),
    );
  }

  openErrorPopup(String text) {
    ScaffoldMessenger.of(state.context).showSnackBar(SnackBar(
      content: Text(
        text,
        style: CVUFont.bodyBold.copyWith(color: Color(0xFFE9500F)),
      ),
      backgroundColor: Color(0x33E9500F),
      elevation: 0,
      duration: Duration(seconds: 2),
    ));
    return;
  }

  executeActions(actions) async {
    nodeResolver.context.clearCache();
    try {
      for (var action in actions) {
        if (action is CVUActionOpenPopup) {
          var settings =
              await action.setPopupSettings(nodeResolver.pageController, nodeResolver.context);
          if (settings != null) {
            openPopup(settings);
          }
        } else {
          await action.execute(nodeResolver.pageController, nodeResolver.context);
        }
      }
    } catch (e) {
      if (e is String) {
        openErrorPopup(e);
      } else {
        isDisabled?.value = false;
        throw e;
      }
    }
    isDisabled?.value = false;
  }

  if (isDisabled != null && isDisabled.value) return;

  if (actions == null && actionsKey != null) {
    actions = nodeResolver.propertyResolver.actions(actionsKey);
    if (actions == null) {
      return;
    }
  }
  isDisabled?.value = true;

  var isBlocked = nodeResolver.pageController.appController.storage["isBlocked"];
  if (isBlocked is ValueNotifier && isBlocked.value == true) {
    executeActionsWhenUnblocked() async {
      if (isBlocked.value == false) {
        isBlocked.removeListener(executeActionsWhenUnblocked);
        await executeActions(actions);
      }
    }

    isBlocked.addListener(executeActionsWhenUnblocked);
  } else {
    await executeActions(actions);
  }
}
