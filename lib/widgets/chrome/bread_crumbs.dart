import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/models/view_context.dart';
import 'package:memri/widgets/empty.dart';

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
  bool showBreadCrumbs = true;
  late Future<List<String>> _titleList;

  @override
  void initState() {
    super.initState();
    pageController = widget.pageController;
    pageController.addListener(updateState);
    _titleList = initTitleList();
  }

  updateState() {
    _titleList = initTitleList();
  }

  dispose() {
    super.dispose();
    pageController.removeListener(updateState);
  }

  Future<List<String>> initTitleList() async {
    if (!pageController.isPageActive) {
      return [];
    }
    navigationStack = pageController.navigationStack.state;
    var titleList =
        await Future.wait(navigationStack.map((ViewContextHolder viewContextHolder) async {
      var viewContextController = pageController.makeContext(viewContextHolder);

      return (await viewContextController.viewDefinitionPropertyResolver.string("title") ??
              (viewContextController.focusedItem != null
                  ? await viewContextController.itemPropertyResolver?.string("title")
                  : null)) ??
          "Untitled";
    }));

    showBreadCrumbs = await pageController.topMostContext?.viewDefinitionPropertyResolver
            .boolean("showBreadCrumbs") ??
        true;

    return titleList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _titleList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          titleList = snapshot.data!;
        }
        return showBreadCrumbs
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: titleList
                    .mapIndexed((index, title) {
                      var isLast = index == titleList.length - 1;
                      return TextButton(
                        onPressed: () {
                          if (!isLast) {
                            pageController.sceneController.removePageControllers();
                            pageController.navigateTo(index);
                          }
                        },
                        child: Text(
                          title,
                          style: isLast && index > 0
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
            : Empty();
      },
    );
  }
}
