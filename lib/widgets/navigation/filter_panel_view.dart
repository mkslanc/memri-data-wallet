//
//  FilterPanelView.swift
//  Memri
//
//  Created by T Brennan on 31/1/21.
//

import 'package:flutter/material.dart';
import 'package:memri/utilities/extensions/string.dart';
import '../../cvu/constants/cvu_color.dart';
import '../../cvu/controllers/view_context_controller.dart';
import '../../cvu/utilities/binding.dart';
import '../components/optional_date_picker.dart';
import '../empty.dart';

enum _FilterPanelTab { renderer, filterOptions, rendererOptions, sortOptions }

class FilterPanelView extends StatefulWidget {
  final ViewContextController viewContext;

  static var excludedSortFields = ["uid", "deleted", "externalId", "version", "allEdges"];
  static var defaultSortFields = ["dateCreated", "dateModified"];

  FilterPanelView({required this.viewContext});

  @override
  _FilterPanelViewState createState() => _FilterPanelViewState(viewContext);
}

class _FilterPanelViewState extends State<FilterPanelView> {
  final ViewContextController viewContext;
  ValueNotifier<_FilterPanelTab> _currentTab = ValueNotifier(_FilterPanelTab.renderer);

  _FilterPanelTab get currentTab => _currentTab.value;

  set currentTab(_FilterPanelTab newValue) => _currentTab.value = newValue;

  _FilterPanelViewState(this.viewContext);

  String get currentTabTitle {
    switch (currentTab) {
      case _FilterPanelTab.renderer:
        return "Renderer selection";
      case _FilterPanelTab.rendererOptions:
        return "Renderer options";
      case _FilterPanelTab.filterOptions:
        return "Filter options";
      case _FilterPanelTab.sortOptions:
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
        builder: (BuildContext context, _FilterPanelTab value, Widget? child) {
          return Column(
            children: [
              SizedBox(
                height: 40,
                child: _FilterPanelTabBar(this.currentTab, (tab) => this.currentTab = tab),
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
                          preferredSize: Size.fromHeight(56.0),
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
                                  if (currentTab == _FilterPanelTab.sortOptions)
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
                              padding: const EdgeInsets.all(0),
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
      case _FilterPanelTab.renderer:
        return _RendererTab(viewContext);
      case _FilterPanelTab.rendererOptions:
        return _RendererOptionsTab(viewContext);
      case _FilterPanelTab.filterOptions:
        return _FilterOptionsTab(viewContext);
      case _FilterPanelTab.sortOptions:
        return _SortOptionsTab(viewContext);
    }
  }
}

class _RendererTab extends StatefulWidget {
  final ViewContextController viewContext;

  const _RendererTab(this.viewContext);

  @override
  State<_RendererTab> createState() => _RendererTabState();
}

class _RendererTabState extends State<_RendererTab> {
  late List<String> supportedRenderers;

  @override
  initState() {
    super.initState();
    supportedRenderers = widget.viewContext.supportedRenderers.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    if (supportedRenderers.isNotEmpty) {
      var selectedRendererName = widget.viewContext.config.rendererName;
      return Center(
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
                onPressed: () => setState(() =>
                    widget.viewContext.config.rendererName = supportedRenderers[index]),
                child: ListTile(
                    dense: true,
                    minVerticalPadding: 0,
                    title: Text(
                      supportedRenderers[index].toUpperCase(),
                      style: TextStyle(
                          fontWeight: supportedRenderers[index] == selectedRendererName
                              ? FontWeight.bold
                              : null),
                    )),
              ),
              separatorBuilder: (context, index) => Divider(
                height: 0,
              ),
              itemCount: supportedRenderers.length),
        )
      );
    } else {
      return Empty();
    }
  }
}

class _RendererOptionsTab extends StatelessWidget {
  final ViewContextController viewContext;

  const _RendererOptionsTab(this.viewContext);

  @override
  Widget build(BuildContext context) {
    switch (viewContext.config.rendererName.toLowerCase()) {
      case "timeline":
        return TimelineRendererSettingsView();
      case "chart":
      // return ChartRendererSettingsView(viewContext: viewContext);
      // case "grid":
      //   return GridRendererSettingsView(viewContext: viewContext);
      default:
    }
    return Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("No configurable settings for this renderer.", style: TextStyle(fontSize: 16)),
            ],
          ),
        );
  }
}

class _FilterOptionsTab extends StatelessWidget {
  final ViewContextController viewContext;

  const _FilterOptionsTab(this.viewContext);

  Widget optionalDateRow(String title, Binding<DateTime?> selection, [DateTime? initialSet]) {
    initialSet ??= DateTime.now();
    return OptionalDatePicker(title: title, selection: selection, initialSet: initialSet);
  }

  @override
  Widget build(BuildContext context) {
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

}

class _SortOptionsTab extends StatelessWidget {
  final ViewContextController viewContext;

  const _SortOptionsTab(this.viewContext);

  List<String>? get sortFields {
    var item = viewContext.items.asMap()[0];
    var propertyTypes = null;
    // item == null ? null : viewContext.databaseController.schema.types[item.type]?.propertyTypes;

    if (propertyTypes == null) return null;

    List<String> fields = propertyTypes.entries.map((propertyType) => propertyType.key).toList();
    fields.addAll(FilterPanelView.defaultSortFields);
    fields.sort();
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    var fields = sortFields?.where((field) => !FilterPanelView.excludedSortFields.contains(field)).toList();
    if (fields == null) return Text("No sort options available.");
    return ListView.separated(
      physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) => ListTile(
        dense: true,
        minVerticalPadding: 0,
        title: _FilterPanelSortItemView(
          property: fields[index],
          selection: Binding(
            () => viewContext.config.query.sortProperty,
            (sortProperty) => viewContext.config.query.sortProperty = sortProperty),
        ),
      ),
      separatorBuilder: (context, index) => Divider(
        height: 0,
      ),
      itemCount: fields.length
    );
  }
}

class _FilterPanelTabBar extends StatelessWidget {
  final _FilterPanelTab currentTab;
  final void Function(_FilterPanelTab) onCurrentTabChange;

  const _FilterPanelTabBar(this.currentTab, this.onCurrentTabChange);

  Widget tabButton(IconData icon, _FilterPanelTab tab) {
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
          onPressed: () => onCurrentTabChange(tab),
          style: TextButton.styleFrom(
            padding: EdgeInsets.all(5),
            // primary: currentTab == tab ? CVUColor.system("systemFill") : Colors.transparent,
          ), //? Color(.systemFill) : Color(.secondarySystemBackground)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var tabList = [
      tabButton(Icons.note, _FilterPanelTab.renderer),
      tabButton(Icons.settings, _FilterPanelTab.rendererOptions),
      // tabButton(Icons.restore, _FilterPanelTab.filterOptions),
      // tabButton(Icons.swap_vertical_circle, _FilterPanelTab.sortOptions),
    ];

    return Row(
      children: tabList.expand((tab) sync* {
        yield VerticalDivider(width: 1);
        yield tab;
      }).skip(1).toList()
    );
  }
}

class TimelineRendererSettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _FilterPanelSortItemView extends StatelessWidget {
  final String property;
  final Binding<String?> selection;

  _FilterPanelSortItemView({required this.property, required this.selection});

  @override
  Widget build(BuildContext context) {
    var isSelected = selection.get() == property;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 40),
      child: Row(
        children: [
          Text(
            property.camelCaseToWords(),
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null),
          ),
          Spacer(),
          isSelected
              ? TextButton(child: Icon(Icons.close_rounded), onPressed: () => selection.set(null))
              : TextButton(onPressed: () => selection.set(property), child: Text("Set"))
        ],
      ),
    );
  }
}
