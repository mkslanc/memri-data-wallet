import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

/// The chart renderer.
/// This renderer displays the data in a chart (eg. line, bar, pie)
class ChartRendererView extends Renderer {
  ChartRendererView({required viewContext}) : super(viewContext: viewContext);

  @override
  _ChartRendererViewState createState() => _ChartRendererViewState();
}

class _ChartRendererViewState extends RendererViewState {
  late String? chartTitle;

  late String? chartSubtitle;

  final Map<int, ItemChartProps> itemChartProps = {};

  late Color backgroundColor;
  late String chartType;

  @override
  initState() {
    super.initState();
    backgroundColor = (() =>
        widget.viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground"))();
    titlesInit();
    chartType = (() =>
        widget.viewContext.rendererDefinitionPropertyResolver
            .string("chartType") ??
        "bar")();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: backgroundColor, child: chartView);
  }

  Widget get missingDataView {
    return Text(
      "You need to define x/y axes in CVU",
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  titlesInit() {
    chartTitle =
        widget.viewContext.rendererDefinitionPropertyResolver.string("title");
    chartSubtitle = widget.viewContext.rendererDefinitionPropertyResolver
        .string("subtitle");
  }

  Color get primaryColor {
    return widget.viewContext.rendererDefinitionPropertyResolver.color() ??
        CVUColor.system("blue");
  }

  double get lineWidth {
    return widget.viewContext.rendererDefinitionPropertyResolver
            .cgFloat("lineWidth") ??
        0;
  }

  bool get yAxisStartAtZero {
    return (widget.viewContext.rendererDefinitionPropertyResolver
        .boolean("yAxisStartAtZero", false))!;
  }

  bool get hideGridlines {
    return (widget.viewContext.rendererDefinitionPropertyResolver
        .boolean("hideGridlines", false))!;
  }

  CVUFont get barLabelFont {
    return widget.viewContext.rendererDefinitionPropertyResolver
        .font("barLabelFont", CVUFont(size: 13));
  }

  bool get showValueLabels {
    return (widget.viewContext.rendererDefinitionPropertyResolver
        .boolean("yAxisStartAtZero", true))!;
  }

  CVUFont get valueLabelFont {
    return widget.viewContext.rendererDefinitionPropertyResolver
        .font("valueLabelFont", CVUFont(size: 14));
  }

  BarChartData makeBarChartModel() {
    var resolver = widget.viewContext.rendererDefinitionPropertyResolver;
    List<BarChartGroupData> data = [];
    var x = 0;
    widget.viewContext.items.forEach((Item item) {
      var y = resolver.replacingItem(item).number("yAxis");
      if (y != null) {
        data.add(BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
                color: primaryColor,
                width: 30,
                borderRadius: BorderRadius.all(Radius.zero), toY: y)
          ],
          showingTooltipIndicators: showValueLabels ? [0] : [],
        ));
        itemChartProps[x] = ItemChartProps(
            xLabel: resolver.replacingItem(item).string("label") ?? "",
            yLabel: resolver.replacingItem(item).string("yAxisLabel") ?? "",
            barLabelFont: barLabelFont,
            valueLabelFont: valueLabelFont);
        x++;
      }
    });
    var hideGridLines = hideGridlines;
    return BarChartData(
      gridData: FlGridData(
          drawVerticalLine: !hideGridLines, drawHorizontalLine: !hideGridLines),
      minY: yAxisStartAtZero ? 0 : null,
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      barGroups: data,
      titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true,
               /* getTitles: (double value) =>
                itemChartProps[value.toInt()]!.xLabel,
                getTextStyles: (double value) => TextStyle(
                  color: Colors.black,
                  fontSize: itemChartProps[value.toInt()]!.barLabelFont.size,
                  fontWeight:
                  itemChartProps[value.toInt()]!.barLabelFont.weight,
                )*/)
              )),
      barTouchData: BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          //tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              itemChartProps[groupIndex]!.yLabel,
              TextStyle(
                color: Colors.black,
                fontSize: itemChartProps[groupIndex]!.valueLabelFont.size,
                fontWeight: itemChartProps[groupIndex]!.valueLabelFont.weight,
              ),
            );
          },
        ),
      ),
    );
  }

  PieChartData makePieChartModel() {
    var resolver = widget.viewContext.rendererDefinitionPropertyResolver;
    List<PieChartSectionData> data = [];
    var x = 0;
    widget.viewContext.items.forEach((Item item) {
      var value = resolver.replacingItem(item).number("yAxis");
      if (value != null) {
        itemChartProps[x] = ItemChartProps(
            xLabel: resolver.replacingItem(item).string("label") ?? "",
            yLabel: resolver.replacingItem(item).string("yAxisLabel") ?? "",
            barLabelFont: barLabelFont,
            valueLabelFont: valueLabelFont);
        data.add(PieChartSectionData(
            color: Colors.primaries[x],
            value: value,
            showTitle: false,
            badgeWidget: Stack(
              children: [
                Center(
                  child: Text(
                    itemChartProps[x]!.yLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: itemChartProps[x]!.valueLabelFont.size,
                      fontWeight: itemChartProps[x]!.valueLabelFont.weight,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        0,
                        itemChartProps[x]!.valueLabelFont.size +
                            itemChartProps[x]!.barLabelFont.size,
                        0,
                        0),
                    child: Text(itemChartProps[x]!.xLabel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: itemChartProps[x]!.barLabelFont.size,
                          fontWeight: itemChartProps[x]!.barLabelFont.weight,
                        )),
                  ),
                ),
              ],
            ),
            radius: 100));
        x++;
      }
    });
    return PieChartData(
        sections: data,
        borderData: FlBorderData(show: false),
        centerSpaceRadius: double.infinity);
  }

  LineChartData makeLineChartModel() {
    var resolver = widget.viewContext.rendererDefinitionPropertyResolver;
    List<FlSpot> spots = [];
    widget.viewContext.items.forEach((Item item) {
      var x = resolver.replacingItem(item).number("xAxis");
      var y = resolver.replacingItem(item).number("yAxis");
      if (x != null && y != null) {
        spots.add(FlSpot(x, y));
        itemChartProps[x.toInt()] = ItemChartProps(
            xLabel: resolver.replacingItem(item).string("label") ?? "",
            yLabel: "",
            barLabelFont: barLabelFont,
            valueLabelFont: valueLabelFont);
      }
    });
    var hideGridLines = hideGridlines;
    var lineChartData = LineChartBarData(
      spots: spots,
      barWidth: lineWidth,
      color: primaryColor,
    );
    return LineChartData(
      gridData: FlGridData(
          drawVerticalLine: !hideGridLines, drawHorizontalLine: !hideGridLines),
      minY: yAxisStartAtZero ? 0 : null,
      clipData: FlClipData.all(),
      borderData: FlBorderData(show: false),
      lineBarsData: [lineChartData],
      showingTooltipIndicators: /*showValueLabels
          ? spots
              .mapIndexed((i, el) => ShowingTooltipIndicators(i, [
                    LineBarSpot(lineChartData, 0, lineChartData.spots[i]),
                  ]))
              .toList()
          : */[],
      lineTouchData: LineTouchData(
        enabled: false,
        touchTooltipData: LineTouchTooltipData(
          //tooltipBgColor: Colors.transparent,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              return LineTooltipItem(
                itemChartProps[lineBarSpot.x.toInt()]!.xLabel,
                TextStyle(
                    color: Colors.black,
                    fontSize: itemChartProps[lineBarSpot.x.toInt()]!
                        .valueLabelFont
                        .size,
                    fontWeight: itemChartProps[lineBarSpot.x.toInt()]!
                        .valueLabelFont
                        .weight),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget chartTitleView() {
    return Column(
      children: [
        Text(
          chartTitle ?? "",
          style: TextStyle(fontSize: 28),
        ),
        Text(
          chartSubtitle ?? "",
          style:
              TextStyle(color: CVUColor.system("secondaryLabel"), fontSize: 17),
        )
      ],
    );
  }

  Widget get chartView {
    switch (chartType) {
      case "bar":
        var model = makeBarChartModel();
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              children: [chartTitleView(), Expanded(child: BarChart(model))]),
        );
      case "line":
        var model = makeLineChartModel();
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              children: [chartTitleView(), Expanded(child: LineChart(model))]),
        );
      case "pie":
        var model = makePieChartModel();
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              children: [chartTitleView(), Expanded(child: PieChart(model))]),
        );
    }
    return Empty();
  }
}

class ItemChartProps {
  String xLabel;
  String yLabel;
  CVUFont barLabelFont;
  CVUFont valueLabelFont;

  ItemChartProps(
      {required this.xLabel,
      required this.yLabel,
      required this.barLabelFont,
      required this.valueLabelFont});
}
