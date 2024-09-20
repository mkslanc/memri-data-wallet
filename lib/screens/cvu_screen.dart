import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/widgets/scene_content_view.dart';
import 'package:memri/cvu/widgets/bottom_bar_view.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../widgets/scaffold/cvu_scaffold.dart';
import 'error_connectivity_screen.dart';

class CVUScreen extends StatefulWidget {
  final ViewContextController viewContextController;

  const CVUScreen({Key? key, required this.viewContextController}) : super(key: key);

  @override
  State<CVUScreen> createState() => _CVUScreenState();
}

class _CVUScreenState extends State<CVUScreen> {
  late Future _init;

  initState() {
    super.initState();
    _init = init();
      Provider.of<UIStateProvider>(context, listen: false).currentViewContext = widget.viewContextController;
  }

  init() async {
    try {
      await Provider.of<AppProvider>(context, listen: false).initCVUDefinitions();
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CVUScaffold(
            viewContextController: widget.viewContextController,
              child: SceneContentView(
                viewContext: widget.viewContextController,
              ),
            bottomBar: BottomBarView(
              viewContext: widget.viewContextController,
            ),
            );
          } else if (snapshot.hasError) {
            return ErrorConnectivityScreen(
              errorMessage: snapshot.error.toString(),
              onRetry: () {
                Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => CVUScreen(viewContextController: widget.viewContextController,),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
      },
    );
  }
}
