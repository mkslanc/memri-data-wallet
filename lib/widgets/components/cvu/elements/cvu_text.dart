import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/cvu/elements/cvu_text_properties_modifier.dart';
import 'package:memri/widgets/empty.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

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
    resolvedTextProperties =
        await CVUTextPropertiesModifier(propertyResolver: widget.nodeResolver.propertyResolver)
            .init();
    content = (await widget.nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
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
    resolvedTextProperties =
        await CVUTextPropertiesModifier(propertyResolver: widget.nodeResolver.propertyResolver)
            .init();
    content = (await widget.nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
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
  List<TextSpan> textBlocks = [];
  bool _isDisabled = false;

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
    resolvedTextProperties =
        await (CVUTextPropertiesModifier(propertyResolver: widget.nodeResolver.propertyResolver)
            .init());
    var spans = widget.nodeResolver.propertyResolver.subdefinitionArray("spans");
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
            italic: resolvedTextProperties.textStyle.fontStyle == FontStyle.italic));
    var color = await spanResolver.color() ?? resolvedTextProperties.textStyle.color;
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
        recognizer:
            actions == null ? null : (TapGestureRecognizer()..onTap = () => onPress(actions)));
  }

  //TODO: separate those methods for buttons and text spans
  onPress(List<CVUAction> actions) async {
    if (_isDisabled) return;
    _isDisabled = true;
    try {
      for (var action in actions) {
        if (action is CVUActionOpenPopup) {
          var settings = await action.setPopupSettings(
              widget.nodeResolver.pageController, widget.nodeResolver.context);
          if (settings != null) {
            openPopup(settings);
          }
        } else {
          await action.execute(widget.nodeResolver.pageController, widget.nodeResolver.context);
        }
      }
    } catch (e) {
      if (e is String) {
        openErrorPopup(e);
      } else {
        _isDisabled = false;
        throw e;
      }
    }
    _isDisabled = false;
  }

  openPopup(Map<String, dynamic> settings) {
    List<CVUAction>? actions = settings['actions'];
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text(settings['title']),
          content: Text(settings['text']),
          actions: actions?.compactMap(
            (action) {
              var title = action.vars["title"]?.value?.value;
              if (title != null) {
                return PointerInterceptor(
                    child: TextButton(
                  onPressed: () async {
                    await action.execute(
                        widget.nodeResolver.pageController, widget.nodeResolver.context);
                    Navigator.pop(context, action.vars["title"]!.value.value);
                  },
                  child: Text(action.vars["title"]!.value.value),
                ));
              } else {
                return null;
              }
            },
          ).toList()),
    );
  }

  openErrorPopup(String text) {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(title: Text("Error"), content: Text(text), actions: [
              PointerInterceptor(
                  child: TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text("Ok"),
              ))
            ]));
  }

  // end copy past

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RichText(
              text: TextSpan(style: resolvedTextProperties.textStyle, children: textBlocks),
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
