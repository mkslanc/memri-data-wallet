import 'package:flutter/material.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/html_view/html_view.dart';
import 'package:memri/widgets/empty.dart';

/// A CVU element for displaying HTML content
/// - Set the `content` property to a HTML string
/// - If no width/height is set the view will take up as much space as possible
class CVUHTMLView extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUHTMLView({required this.nodeResolver});

  @override
  _CVUHTMLViewState createState() => _CVUHTMLViewState();
}

class _CVUHTMLViewState extends State<CVUHTMLView> {
  late String? _content;
  late String? src;
  late bool reload;

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    src = widget.nodeResolver.propertyResolver.string("src");
    _content = widget.nodeResolver.propertyResolver.string("content");
    reload = (widget.nodeResolver.propertyResolver.boolean("reload", false))!;
  }

  @override
  Widget build(BuildContext context) {
    if (_content != null || src != null) {
      return HtmlView(
        html: _content,
        src: src,
        reload: reload,
      );
    }
    return Empty();
  }
}
