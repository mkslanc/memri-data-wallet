//
//  FilterPanelView.swift
//  Memri
//
//  Created by T Brennan on 31/1/21.
//

import 'package:flutter/material.dart';
import 'package:memri/utilities/extensions/collection.dart';
import '../../../cvu/constants/cvu_color.dart';
import '../../../cvu/controllers/view_context_controller.dart';
import 'filter_tabs/filter_options_tab.dart';
import 'filter_tabs/renderer_options_tab.dart';
import 'filter_tabs/renderer_selection_tab.dart';
import 'filter_tabs/sort_options_tab.dart';

enum _FilterPanelTab { renderer, filterOptions, rendererOptions, sortOptions }

class FilterPanelView extends StatefulWidget {
  final ViewContextController viewContext;

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
        return RendererTab(viewContext);
      case _FilterPanelTab.rendererOptions:
        return RendererOptionsTab(viewContext);
      case _FilterPanelTab.filterOptions:
        return FilterOptionsTab(viewContext);
      case _FilterPanelTab.sortOptions:
        return SortOptionsTab(viewContext);
    }
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
            padding: EdgeInsets.all(10),
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
      tabButton(Icons.restore, _FilterPanelTab.filterOptions),
      tabButton(Icons.swap_vertical_circle, _FilterPanelTab.sortOptions),
    ];

    return Row(children: tabList.addSeparator<Widget>(() => VerticalDivider(width: 1)));
  }
}
