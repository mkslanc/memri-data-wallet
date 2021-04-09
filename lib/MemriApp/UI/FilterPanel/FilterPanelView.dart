//
//  FilterPanelView.swift
//  Memri
//
//  Created by T Brennan on 31/1/21.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

import '../ViewContextController.dart';

class FilterPanelView extends StatefulWidget {
  final ViewContextController viewContext;

  FilterPanelView({required this.viewContext});

  @override
  _FilterPanelViewState createState() => _FilterPanelViewState(viewContext);
}

enum FilterPanelTab { renderer, filterOptions, rendererOptions }

class _FilterPanelViewState extends State<FilterPanelView> {
  final ViewContextController viewContext;
  ValueNotifier<FilterPanelTab> _currentTab = ValueNotifier(FilterPanelTab.rendererOptions);

  FilterPanelTab get currentTab => _currentTab.value;

  set currentTab(FilterPanelTab newValue) => _currentTab.value = newValue;

  _FilterPanelViewState(this.viewContext);

  String get currentTabTitle {
    switch (currentTab) {
      case FilterPanelTab.renderer:
        return "Renderer selection";
      case FilterPanelTab.rendererOptions:
        return "Renderer options";
      case FilterPanelTab.filterOptions:
        return "Filter options";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      child: ColoredBox(
        color: Color(0xffffffff),
        child: ValueListenableBuilder(
          builder: (BuildContext context, FilterPanelTab value, Widget? child) {
            return Column(
              children: [
                Row(
                  children: [
                    tabButton(Icons.note, FilterPanelTab.renderer),
                    Divider(),
                    tabButton(Icons.settings, FilterPanelTab.rendererOptions),
                    Divider(),
                    tabButton(Icons.restore, FilterPanelTab.filterOptions),
                    Divider()
                  ],
                ),
                Divider(),
                Expanded(
                    child: MaterialApp(
                        debugShowCheckedModeBanner: false,
                        home: Scaffold(
                          appBar: AppBar(
                            title: Center(
                              child: Text(currentTabTitle),
                            ),
                          ),
                          body: Form(
                            child: currentTabRenderer,
                          ),
                        )))
              ],
            );
          },
          valueListenable: _currentTab,
        ),
      ),
    );
  }

  Widget get currentTabRenderer {
    switch (currentTab) {
      case FilterPanelTab.renderer:
        return rendererTab;
      case FilterPanelTab.filterOptions:
        return filterOptionsTab;
      case FilterPanelTab.rendererOptions:
        return rendererOptionsTab;
    }
  }

  Widget tabButton(IconData icon, FilterPanelTab tab) {
    return Expanded(
      child: ElevatedButton(
        child: Icon(
          icon,
          color: Colors.black,
        ),
        // icon: ,
        onPressed: () => currentTab = tab,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(5),
          primary: currentTab == tab ? Colors.grey : Colors.white,
        ), //? Color(.systemFill) : Color(.secondarySystemBackground)
      ),
    );
  }

  Widget optionalDateRow(String title, Binding<DateTime?> selection, [DateTime? initialSet]) {
    initialSet ??= DateTime.now();
    return Text(initialSet.toString());
    // OptionalDatePicker(title: title, selection: selection, initialSet: initialSet)
  }

  Widget get rendererTab {
    return FutureBuilder(
        future: viewContext.supportedRenderers,
        builder: (BuildContext context, AsyncSnapshot<Set<String>> snapshot) {
          if (snapshot.hasData) {
            var supportedRenderers = snapshot.data!.toList();
            supportedRenderers.sort();
            return Center(
              child: Column(
                  children: supportedRenderers
                      .map((rendererName) => TextButton(
                          onPressed: () => viewContext.config.rendererName.value = rendererName,
                          child: Text(
                            rendererName.toUpperCase(),
                            style: TextStyle(
                                fontWeight: rendererName == viewContext.config.rendererName.value
                                    ? FontWeight.bold
                                    : null),
                          )))
                      .toList()),
            );
          } else {
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            );
          }
        });
  }

  Widget get rendererOptionsTab {
    switch (viewContext.config.rendererName.value.toLowerCase()) {
      case "timeline":
      // return TimelineRendererSettingsView(viewContext: viewContext);
      case "chart":
      // return ChartRendererSettingsView(viewContext: viewContext);
      case "grid":
      // return GridRendererSettingsView(viewContext: viewContext);
      default:
        return Text("No configurable settings for this renderer.");
    }
  }

  Widget get filterOptionsTab {
    var date = DateTime.now();
    return Column(
      children: [
        optionalDateRow(
            "Modified after",
            Binding(() => viewContext.config.query.dateModifiedAfter,
                (newValue) => viewContext.config.query.dateModifiedAfter = newValue),
            date.subtract(Duration(days: 7))),
        optionalDateRow(
            "Modified before",
            Binding(() => viewContext.config.query.dateModifiedBefore,
                (newValue) => viewContext.config.query.dateModifiedBefore = newValue)),
        optionalDateRow(
            "Created after",
            Binding(() => viewContext.config.query.dateModifiedAfter,
                (newValue) => viewContext.config.query.dateModifiedAfter = newValue),
            date.subtract(Duration(days: 7))),
        optionalDateRow(
            "Created before",
            Binding(() => viewContext.config.query.dateCreatedBefore,
                (newValue) => viewContext.config.query.dateCreatedBefore = newValue)),
      ],
    );
  }
}
