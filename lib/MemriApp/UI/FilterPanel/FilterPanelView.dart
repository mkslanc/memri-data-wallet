//
//  FilterPanelView.swift
//  Memri
//
//  Created by T Brennan on 31/1/21.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/OptionalDatePicker.dart';
import 'package:memri/MemriApp/UI/RendererSettingsViews/GridRendererSettingsView.dart';
import 'package:memri/MemriApp/UI/RendererSettingsViews/TimelineRendererSettingsView.dart';

import '../ViewContextController.dart';
import 'FilterPanelSortItemView.dart';

class FilterPanelView extends StatefulWidget {
  final ViewContextController viewContext;

  static var excludedSortFields = ["uid", "deleted", "externalId", "version", "allEdges"];
  static var defaultSortFields = ["dateCreated", "dateModified"];

  FilterPanelView({required this.viewContext});

  @override
  _FilterPanelViewState createState() => _FilterPanelViewState(viewContext);
}

enum FilterPanelTab { renderer, filterOptions, rendererOptions, sortOptions }

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
      case FilterPanelTab.sortOptions:
        return "Sort options";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.4),
            blurRadius: 10,
          )
        ],
        borderRadius:
            BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ValueListenableBuilder(
        builder: (BuildContext context, FilterPanelTab value, Widget? child) {
          return Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    tabButton(Icons.note, FilterPanelTab.renderer),
                    VerticalDivider(
                      width: 1,
                    ),
                    tabButton(Icons.settings, FilterPanelTab.rendererOptions),
                    VerticalDivider(
                      width: 1,
                    ),
                    tabButton(Icons.restore, FilterPanelTab.filterOptions),
                    VerticalDivider(
                      width: 1,
                    ),
                    tabButton(Icons.swap_vertical_circle, FilterPanelTab.sortOptions),
                    VerticalDivider(
                      width: 1,
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              Expanded(
                  child: MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home: Scaffold(
                        backgroundColor: Color(0xfff3f2f8),
                        appBar: PreferredSize(
                          preferredSize: Size.fromHeight(32.0),
                          child: Column(
                            children: [
                              AppBar(
                                centerTitle: true,
                                primary: false,
                                backgroundColor: Colors.white,
                                excludeHeaderSemantics: true,
                                title: Center(
                                    child: Text(
                                  currentTabTitle,
                                  style: TextStyle(color: Colors.black, fontSize: 17),
                                )),
                                actions: [
                                  if (currentTab == FilterPanelTab.sortOptions)
                                    TextButton(
                                        child: Icon(!viewContext.config.query.sortAscending
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward),
                                        onPressed: () => setState(() =>
                                            viewContext.config.query.sortAscending =
                                                !viewContext.config.query.sortAscending))
                                ],
                              ),
                            ],
                          ),
                        ),
                        body: SingleChildScrollView(
                          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Form(
                                  child: currentTabRenderer,
                                ),
                              )),
                        ),
                      )))
            ],
          );
        },
        valueListenable: _currentTab,
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
      case FilterPanelTab.sortOptions:
        return sortOptionsTab;
    }
  }

  Widget tabButton(IconData icon, FilterPanelTab tab) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: currentTab == tab ? CVUColor.system("systemFill") : Colors.transparent,
        ),
        child: TextButton(
          child: Icon(
            icon,
            color: Colors.black,
          ),
          // icon: ,
          onPressed: () => currentTab = tab,
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(5),
            primary: currentTab == tab ? CVUColor.system("systemFill") : Colors.transparent,
          ), //? Color(.systemFill) : Color(.secondarySystemBackground)
        ),
      ),
    );
  }

  Widget optionalDateRow(String title, Binding<DateTime?> selection, [DateTime? initialSet]) {
    initialSet ??= DateTime.now();
    return OptionalDatePicker(title: title, selection: selection, initialSet: initialSet);
  }

  Widget get rendererTab {
    return FutureBuilder(
        future: viewContext.supportedRenderers,
        builder: (BuildContext context, AsyncSnapshot<Set<String>> snapshot) {
          if (snapshot.hasData) {
            var supportedRenderers = snapshot.data!.toList();
            supportedRenderers.sort();
            return ValueListenableBuilder(
                valueListenable: viewContext.config.rendererName,
                builder: (BuildContext context, String selectedRendererName, Widget? child) =>
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed: () => viewContext.config.rendererName.value =
                                      supportedRenderers[index],
                                  child: ListTile(
                                      dense: true,
                                      minVerticalPadding: 0,
                                      title: Text(
                                        supportedRenderers[index].toUpperCase(),
                                        style: TextStyle(
                                            fontWeight:
                                                supportedRenderers[index] == selectedRendererName
                                                    ? FontWeight.bold
                                                    : null),
                                      )),
                                ),
                            separatorBuilder: (context, index) => Divider(
                                  height: 0,
                                ),
                            itemCount: supportedRenderers.length),
                      ),
                    ));
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
        return TimelineRendererSettingsView(viewContext: viewContext);
      case "chart":
      // return ChartRendererSettingsView(viewContext: viewContext);
      case "grid":
        return GridRendererSettingsView(viewContext: viewContext);
      default:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No configurable settings for this renderer.", style: TextStyle(fontSize: 16)),
            ],
          ),
        );
    }
  }

  Widget get filterOptionsTab {
    var date = DateTime.now();
    List<Widget> filterOptions = [
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
    ];
    return ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) => ListTile(
              dense: true,
              minVerticalPadding: 0,
              title: filterOptions[index],
            ),
        separatorBuilder: (context, index) => Divider(
              height: 0,
            ),
        itemCount: filterOptions.length);
  }

  List<String>? get sortFields {
    var item = viewContext.items.asMap()[0];
    var propertyTypes =
        item == null ? null : viewContext.databaseController.schema.types[item.type]?.propertyTypes;

    if (propertyTypes == null) return null;

    List<String> fields = propertyTypes.entries.map((propertyType) => propertyType.key).toList();
    fields.addAll(FilterPanelView.defaultSortFields);
    fields.sort();
    return fields;
  }

  Widget get sortOptionsTab {
    var fields =
        sortFields?.where((field) => !FilterPanelView.excludedSortFields.contains(field)).toList();
    if (fields == null) return Text("No sort options available.");
    return ListView.separated(
        physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) => ListTile(
              dense: true,
              minVerticalPadding: 0,
              title: FilterPanelSortItemView(
                property: fields[index],
                selection: Binding(
                    () => viewContext.config.query.sortProperty,
                    (sortProperty) =>
                        setState(() => viewContext.config.query.sortProperty = sortProperty)),
              ),
            ),
        separatorBuilder: (context, index) => Divider(
              height: 0,
            ),
        itemCount: fields.length);
  }
}
