import 'package:flutter/material.dart';

import '../CVUUINodeResolver.dart';

class CVUGrid extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUGrid({required this.nodeResolver});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("TODO"));
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
