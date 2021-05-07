import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import '../CVUUINodeResolver.dart';
import 'CVUForEach.dart';

class CVUGrid extends StatelessWidget with StackWidget {
  final CVUUINodeResolver nodeResolver;
  late final List<ItemRecord> items;

  CVUGrid({required this.nodeResolver});

  init() async {
    items = await nodeResolver.propertyResolver.items("items");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (items.isNotEmpty) {
              return initWidget();
            }
          }
          return Text("");
        });
  }

  @override
  Widget getWidget(List<Widget> children) {
    return GridView.count(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
        crossAxisCount: 5,
        scrollDirection: Axis.vertical,
        children: children,
        semanticChildCount: items.length);
  }

/*var axis: GridAxis {
        switch nodeResolver.propertyResolver.string("axis") {
        case "vertical":
            return .vertical
        default:
            return .horizontal
        }
    }

    var minColumnHeight: CGFloat {
        nodeResolver.propertyResolver.cgFloat("minColumnHeight") ?? 50
    }

    var maxColumnHeight: CGFloat {
        let min = minColumnHeight
        return nodeResolver.propertyResolver.cgFloat("maxColumnHeight").map { max(min, $0) } ?? min * 1.9
    }

    var body: some View {
        let items: [ItemRecord] = nodeResolver.propertyResolver.items("items")
        if (items.count > 0) {
            let axis = self.axis
            let spacing = nodeResolver.propertyResolver.spacing ?? .zero
            ScrollView(axis.scrollAxis) {
                switch axis {
                case .vertical:
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: minColumnHeight, maximum: maxColumnHeight), spacing: spacing.x)], spacing: spacing.y, content: {
                        nodeResolver.childrenInForEach()
                    })
                case .horizontal:
                    LazyHGrid(rows: [GridItem(.adaptive(minimum: minColumnHeight, maximum: maxColumnHeight), spacing: spacing.y)], spacing: spacing.x, content: {
                        nodeResolver.childrenInForEach()
                    })
                }

            }
        } else {
            HStack(alignment: .top) {
                Spacer()
                Text(nodeResolver.propertyResolver.string("emptyResultText") ?? "No results")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .opacity(0.7)
                Spacer()
            }
            .padding(.all, 30)
            .padding(.top, 0)
        }
    }

    enum GridAxis {
        case vertical
        case horizontal

        var scrollAxis: Axis.Set {
            switch self {
            case .vertical:
                return .vertical
            case .horizontal:
                return .horizontal
            }
        }
    }*/
}
