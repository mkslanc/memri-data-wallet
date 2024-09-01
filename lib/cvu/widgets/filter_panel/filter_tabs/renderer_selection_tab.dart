import 'package:flutter/material.dart';

import '../../../../widgets/empty.dart';
import '../../../controllers/view_context_controller.dart';

class RendererTab extends StatefulWidget {
  final ViewContextController viewContext;

  const RendererTab(this.viewContext);

  @override
  State<RendererTab> createState() => _RendererTabState();
}

class _RendererTabState extends State<RendererTab> {
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