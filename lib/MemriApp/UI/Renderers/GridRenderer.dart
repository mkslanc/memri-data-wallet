import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Renderers/GridRendererSimple.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'GridRendererFlow.dart';
import 'Renderer.dart';

/// The grid renderer
/// This presents the data in a grid (aka collection view)
class GridRendererView extends Renderer {
  GridRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  GridRendererViewState createState() => GridRendererViewState();
}

class GridRendererViewState extends RendererViewState {
  late EdgeInsets insets;

  late Future _init;
  late String layout;

  @override
  initState() {
    super.initState();
    _init = init();

    pageController.isInEditMode.addListener(updateState);
    viewContext.addListener(updateState);
  }

  dispose() {
    super.dispose();
    pageController.isInEditMode.removeListener(updateState);
    viewContext.removeListener(updateState);
  }

  late Axis scrollDirection;
  late Color backgroundColor;

  updateState() async {
    await init();
    setState(() {});
  }

  init() async {
    super.init();
    layout =
        await widget.viewContext.rendererDefinitionPropertyResolver.string("layout") ?? "simple";
    singleChoice =
        await viewContext.viewDefinitionPropertyResolver.boolean("singleChoice") ?? false;
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(5, pageController.showTopBar ? 5 : 80, 5, 5);

    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? layout == "flow"
              ? GridRendererFlowView(pageController: pageController, viewContext: viewContext)
              : GridRendererSimpleView(pageController: pageController, viewContext: viewContext)
          : Empty(),
    );
  }
}
