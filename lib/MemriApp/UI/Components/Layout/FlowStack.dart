import 'dart:math';

import 'package:flutter/material.dart';

class FlowStack extends StatelessWidget {
  List<dynamic> data;
  Point spacing;
  MainAxisAlignment alignment;

  List<Widget> Function(dynamic) content;
  double availableWidth = 0;

  FlowStack(
      {required this.data,
      spacing,
      this.alignment = MainAxisAlignment.start,
      required this.content})
      : this.spacing = spacing ?? Point(0, 0);

  /*public var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }

            InnerView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }*/

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InnerView(
            availableWidth: availableWidth,
            data: data,
            spacing: spacing,
            alignment: alignment,
            content: content)
      ],
    );
  }
}

class InnerView extends StatelessWidget {
  final double availableWidth;
  final dynamic data;
  final Point spacing;
  final MainAxisAlignment alignment;
  final List<Widget> Function(dynamic) content;

  Map<dynamic, Point> elementsSize = {};

  InnerView({
    required this.availableWidth,
    required this.data,
    required this.spacing,
    required this.alignment,
    required this.content,
  });

  /*var body: some View {
            VStack(alignment: alignment, spacing: spacing.y) {
                ForEach(computeRows(), id: \.self) { rowElements in
                    HStack(spacing: spacing.x) {
                        ForEach(rowElements, id: \.self) { element in
                            content(element)
                                .fixedSize()
                                .readSize { size in
                                    elementsSize[element] = size
                                }
                        }
                    }
                }
            }
            .frame(maxWidth: availableWidth)
        }*/

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: alignment,
      children: [
        ...computeRows().map((rowElements) => Row(
              children: [
                ...rowElements.map((element) => Wrap(
                      children: content(element),
                    ))
              ], //TODO:
            ))
      ],
    );
  }

  List<List<dynamic>> computeRows() {
    List<List<dynamic>> rows = [];
    var currentRow = 0;
    var remainingWidth = availableWidth;

    for (var element in data) {
      var elementSize = elementsSize[element] ?? Point(availableWidth, 1);

      if (remainingWidth - (elementSize.x + spacing.x) >= 0) {
        rows[currentRow].add(element);
      } else {
        currentRow = currentRow + 1;
        rows.add([element]);
        remainingWidth = availableWidth;
      }

      remainingWidth = remainingWidth - (elementSize.x + spacing.x);
    }

    return rows;
  }
}
