import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/cvu/elements/cvu_text_properties_modifier.dart';
import 'package:memri/widgets/empty.dart';

import '../../../../utilities/execute_actions.dart';

/// A CVU element for displaying text
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUText extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUText({required this.nodeResolver});

  @override
  _CVUTextState createState() => _CVUTextState();
}

class _CVUTextState extends State<CVUText> {
  late TextProperties resolvedTextProperties;

  String? content;
  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    resolvedTextProperties = await CVUTextPropertiesModifier(
            propertyResolver: widget.nodeResolver.propertyResolver)
        .init();
    content = (await widget.nodeResolver.propertyResolver.string("text"))
        ?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (content != null) {
            return Text(
              content!,
              overflow: resolvedTextProperties.lineLimit == 1
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              softWrap: true,
              maxLines: resolvedTextProperties.lineLimit,
              style: resolvedTextProperties.textStyle,
              textAlign: resolvedTextProperties.textAlign,
            );
          }
          return Empty();
          // .fixedSize(horizontal: false, vertical: true) TODO
        });
  }
}

/// A CVU element for displaying text with URLs and phone numbers auto-detected and clickable
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUSmartText extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUSmartText({required this.nodeResolver});

  @override
  _CVUSmartTextState createState() => _CVUSmartTextState();
}

class _CVUSmartTextState extends State<CVUSmartText> {
  late TextProperties resolvedTextProperties;

  String? content;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    resolvedTextProperties = await CVUTextPropertiesModifier(
            propertyResolver: widget.nodeResolver.propertyResolver)
        .init();
    content = (await widget.nodeResolver.propertyResolver.string("text"))
        ?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, AsyncSnapshot snapshot) {
          if (content != null) {
            return Text(
              content!,
              overflow: resolvedTextProperties.lineLimit == 1
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              softWrap: true,
              style: resolvedTextProperties.textStyle,
              textAlign: resolvedTextProperties.textAlign,
              maxLines: resolvedTextProperties.lineLimit,
            );
          }
          return Empty();
        });
  }
}

// A CVU element for displaying text blocks
// - Set the `spans` property for providing text blocks
// - Set the `font` property to change text appearance
// - Set the `color` property to change text color
class CVURichText extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVURichText({required this.nodeResolver});

  @override
  _CVURichTextState createState() => _CVURichTextState();
}

class _CVURichTextState extends State<CVURichText> {
  late TextProperties resolvedTextProperties;
  late Future _init;
  bool _isInited = false;
  List<TextSpan> textBlocks = [];
  late ValueNotifier<bool> _isDisabled;

  @override
  initState() {
    _isDisabled = ValueNotifier(false);
    super.initState();
    _init = init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    resolvedTextProperties = await (CVUTextPropertiesModifier(
            propertyResolver: widget.nodeResolver.propertyResolver)
        .init());
    var spans =
        widget.nodeResolver.propertyResolver.subdefinitionArray("spans");
    await resolveTextSpans(spans);
  }

  resolveTextSpans(List<CVUPropertyResolver> spans) async {
    textBlocks = [for (final span in spans) await buildTextSpan(span)];
  }

  Future<TextSpan> buildTextSpan(CVUPropertyResolver spanResolver) async {
    var font = await spanResolver.font(
        "font",
        CVUFont(
            name: resolvedTextProperties.textStyle.fontFamily,
            size: resolvedTextProperties.textStyle.fontSize ?? 15,
            weight: resolvedTextProperties.textStyle.fontWeight,
            italic: resolvedTextProperties.textStyle.fontStyle ==
                FontStyle.italic));
    var color =
        await spanResolver.color() ?? resolvedTextProperties.textStyle.color;
    var actions = spanResolver.actions("onPress");
    return TextSpan(
        text: await spanResolver.string("text"),
        style: TextStyle(
          fontFamily: font.name,
          fontSize: font.size,
          fontWeight: font.weight,
          fontStyle: font.italic ? FontStyle.italic : FontStyle.normal,
          color: color,
        ),
        recognizer: actions == null
            ? null
            : (TapGestureRecognizer()
              ..onTap = () => executeActionsOnSubmit(widget.nodeResolver, this,
                  isDisabled: _isDisabled, actions: actions)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          _isInited =
              _isInited || snapshot.connectionState == ConnectionState.done;
          if (_isInited) {
            return RichText(
              text: TextSpan(
                  style: resolvedTextProperties.textStyle,
                  children: textBlocks),
              overflow: resolvedTextProperties.lineLimit == 1
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              softWrap: true,
              maxLines: resolvedTextProperties.lineLimit,
              textAlign: resolvedTextProperties.textAlign,
            );
          }
          return Empty();
        });
  }
}
