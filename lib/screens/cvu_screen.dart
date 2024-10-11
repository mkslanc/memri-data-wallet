import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/widgets/scene_content_view.dart';
import 'package:memri/cvu/widgets/bottom_bar_view.dart';

import '../widgets/scaffold/cvu_scaffold.dart';

class CVUScreen extends StatefulWidget {
  final ViewContextController viewContextController;

  const CVUScreen({Key? key, required this.viewContextController}) : super(key: key);

  @override
  State<CVUScreen> createState() => _CVUScreenState();
}

class _CVUScreenState extends State<CVUScreen> {
  @override
  Widget build(BuildContext context) {
    return CVUScaffold(
      viewContextController: widget.viewContextController,
      child: SceneContentView(
        viewContext: widget.viewContextController,
      ),
      bottomBar: BottomBarView(
        viewContext: widget.viewContextController,
      ),
    );
  }
}
