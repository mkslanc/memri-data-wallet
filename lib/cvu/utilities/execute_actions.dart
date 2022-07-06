import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/cvu/services/cvu_action.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';

executeActionsOnSubmit(CVUUINodeResolver nodeResolver, State state,
    {ValueNotifier<bool>? isDisabled,
    List<CVUAction>? actions,
    String? actionsKey}) async {
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
        await action.execute(nodeResolver.context);
      }
    } catch (e) {
      if (e is String) {
        openErrorPopup(e);
      } else {
        AppController.shared.showError(SystemError.generalError);
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

  var isBlocked = AppController.shared.storage["isBlocked"];
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
