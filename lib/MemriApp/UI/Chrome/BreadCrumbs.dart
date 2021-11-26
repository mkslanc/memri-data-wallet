import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContext.dart';
import '../ViewContextController.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;

class BreadCrumbs extends StatefulWidget {
  final ViewContextController viewContext;
  final memri.PageController pageController;

  BreadCrumbs({required this.viewContext, required this.pageController});

  @override
  _BreadCrumbsState createState() => _BreadCrumbsState();
}

class _BreadCrumbsState extends State<BreadCrumbs> {
  late List<ViewContextHolder> navigationStack;
  late final memri.PageController pageController;
  var titleList = <String>[];
  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    pageController = widget.pageController;
    pageController.addListener(updateState);
    _init = init();
  }

  updateState() {
    _init = init();
  }

  Future<void> init() async {
    navigationStack = pageController.navigationStack.state;
    titleList = [];
    titleList = await Future.wait(navigationStack.map((ViewContextHolder viewContextHolder) async {
      var viewContextController = pageController.makeContext(viewContextHolder);
      return (await viewContextController.viewDefinitionPropertyResolver.string("title") ??
              (viewContextController.focusedItem != null
                  ? await viewContextController.itemPropertyResolver?.string("title")
                  : null)) ??
          "Untitled";
    }));
  }

  @override
  void dispose() {
    super.dispose();
    pageController.removeListener(updateState);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => titleList.length > 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: titleList
                  .mapIndexed((index, title) {
                    var isLast = index == titleList.length - 1;
                    return TextButton(
                      onPressed: () => isLast ? null : pageController.navigateTo(index),
                      child: Text(
                        title,
                        style: isLast
                            ? CVUFont.tabList.copyWith(color: Color(0xFF999999))
                            : CVUFont.tabList,
                      ),
                    );
                  })
                  .expand((item) => [
                        SvgPicture.asset(
                          "assets/images/brcmb_line.svg",
                        ),
                        item
                      ])
                  .skip(1)
                  .toList())
          : Empty(),
    );
  }
}
