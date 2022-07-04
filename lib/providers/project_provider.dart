import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/services/pod_service.dart';

class ProjectProvider with ChangeNotifier {
  // ignore: unused_field
  final PodService _podService;
  String errorMessage = "";
  bool whatsappSelected = false;

  ProjectProvider(this._podService);

  handleSelectDataSource() {
    whatsappSelected = !whatsappSelected;
    notifyListeners();
  }

  handleNext(BuildContext context) {
    if (whatsappSelected) {
      RouteNavigator.navigateTo(
          context: context, route: Routes.projectsSetupData);
    } else {
      errorMessage = "Select a datasource first";
      notifyListeners();
    }
  }
}
