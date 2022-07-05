import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/services/pod_service.dart';

import '../core/models/item.dart';

class ProjectProvider with ChangeNotifier {
  // ignore: unused_field
  final PodService _podService;
  String errorMessage = "";
  bool whatsappSelected = false;
  List<Item> projects = [];

  Item? currentProject = null;
  Item? currentDataset = null;

  ProjectProvider(this._podService);

  handleSelectDataSource() {
    whatsappSelected = !whatsappSelected;
    notifyListeners();
  }

  handleCreateProject(BuildContext context, String projectName) {
    if (projectName.length == 0) {
      errorMessage = "Enter a dataset name";
      notifyListeners();
    } else if (!whatsappSelected) {
      errorMessage = "Select a datasource first";
      notifyListeners();
    } else {
      createProject(name: projectName);
      RouteNavigator.navigateTo(
          context: context, route: Routes.projectsSetupData);
    }
  }

  handleCreateDataset(
      BuildContext context, List<String> properties, List<bool> selected) {
    // TODO handle selected properties
    createDataset();
    RouteNavigator.navigateTo(
        context: context, route: Routes.projectsSetupLabelEditor);
  }

  void createProject({required String name}) async {
    var project = Item(type: "Project");
    project.properties["name"] = name;
    _podService.createItem(item: project);
    currentProject = project;
    debugPrint("[DEBUG] created project: ${project.toJson()}");
  }

  void createDataset() async {
    var dataset = Item(type: "Dataset");
    String projectName = currentProject!.get("name");
    dataset.properties["name"] = "$projectName Dataset 1.0";
    var datasetEdge =
        Edge(source: currentProject!, target: dataset, name: "dataset");
    _podService.bulkAction(createItems: [dataset], createEdges: [datasetEdge]);
    currentProject!.edges["dataset"] =
        EdgeList(name: "dataset", targets: [dataset]);

    debugPrint(
        "[DEBUG] created dataset: ${currentProject!.getEdgeTargets("dataset")![0].get("name")}");
  }
}
