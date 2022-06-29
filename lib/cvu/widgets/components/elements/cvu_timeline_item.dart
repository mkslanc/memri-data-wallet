import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/utilities/extensions/icon_data.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

/// A CVU element for displaying a timeline-style item tag
/// - Set the `title`, `subtitle`, and `icon` properties
class CVUTimelineItem extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUTimelineItem({required this.nodeResolver});

  @override
  _CVUTimelineItemState createState() => _CVUTimelineItemState();
}

class _CVUTimelineItemState extends State<CVUTimelineItem> {
  late final IconData icon;

  late final String title;

  late final String? subtitle;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  Future init() async {
    icon = MemriIcon.getByName(
        await widget.nodeResolver.propertyResolver.string("icon") ??
            "arrow_right");
    title = await widget.nodeResolver.propertyResolver.string("title") ?? "-";
    subtitle = await widget.nodeResolver.propertyResolver.string("text");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? TimelineItemView(
                  icon: icon,
                  title: title,
                  subtitle: subtitle,
                  backgroundColor: Colors.grey)
              : Empty(),
    );
  }
}

class TimelineItemView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final double cornerRadius;

  final Color backgroundColor;
  final Color foregroundColor = Colors.white;

  TimelineItemView(
      {IconData? icon,
      this.title = "Hello world",
      this.subtitle,
      this.cornerRadius = 5,
      backgroundColor})
      : this.icon = icon ?? Icons.send,
        this.backgroundColor =
            backgroundColor ?? CVUColor.system("systemGreen");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
          color: backgroundColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                child: Icon(icon, color: foregroundColor),
              ),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: foregroundColor),
                  maxLines: 1)
            ],
          ),
          Text(
            subtitle ?? "",
            style: TextStyle(fontSize: 12, color: foregroundColor),
            maxLines: 2,
          )
        ],
      ),
    );
  }
}
