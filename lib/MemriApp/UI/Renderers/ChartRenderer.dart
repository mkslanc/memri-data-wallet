import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';

/// The chart renderer.
/// This renderer displays the data in a chart (eg. line, bar, pie)
class ChartRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;
  late final String? chartTitle;
  late final String? chartSubtitle;
  final Map<int, ItemChartProps> itemChartProps = {};

  ChartRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: backgroundColor,
        builder: (BuildContext context, AsyncSnapshot<Color> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Expanded(child: ColoredBox(color: snapshot.data!, child: chartView));
            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }

  Widget get missingDataView {
    return Text(
      "You need to define x/y axes in CVU",
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Future<Color> get backgroundColor async {
    return await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
  }

  titlesInit() async {
    chartTitle = await viewContext.rendererDefinitionPropertyResolver.string("title");
    chartSubtitle = await viewContext.rendererDefinitionPropertyResolver.string("subtitle");
  }

  Future<Color> get primaryColor async {
    return await viewContext.rendererDefinitionPropertyResolver.color() ?? CVUColor.system("blue");
  }

  Future<double> get lineWidth async {
    return await viewContext.rendererDefinitionPropertyResolver.cgFloat("lineWidth") ?? 0;
  }

  Future<bool> get yAxisStartAtZero async {
    return (await viewContext.rendererDefinitionPropertyResolver
        .boolean("yAxisStartAtZero", false))!;
  }

  Future<bool> get hideGridlines async {
    return (await viewContext.rendererDefinitionPropertyResolver.boolean("hideGridlines", false))!;
  }

  Future<CVUFont> get barLabelFont async {
    return await viewContext.rendererDefinitionPropertyResolver
        .font("barLabelFont", CVUFont(size: 13));
  }

  Future<bool> get showValueLabels async {
    return (await viewContext.rendererDefinitionPropertyResolver
        .boolean("yAxisStartAtZero", true))!;
  }

  Future<CVUFont> get valueLabelFont async {
    return await viewContext.rendererDefinitionPropertyResolver
        .font("valueLabelFont", CVUFont(size: 14));
  }

  Future<BarChartData> makeBarChartModel() async {
    var resolver = viewContext.rendererDefinitionPropertyResolver;
    List<BarChartGroupData> data = [];
    var x = 0;
    await Future.forEach(viewContext.items, (ItemRecord item) async {
      var y = await resolver.replacingItem(item).number("yAxis");
      if (y != null) {
        data.add(BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
                colors: [await primaryColor],
                y: y,
                width: 30,
                borderRadius: BorderRadius.all(Radius.zero))
          ],
          showingTooltipIndicators: await showValueLabels ? [0] : [],
        ));
        itemChartProps[x] = ItemChartProps(
            xLabel: await resolver.replacingItem(item).string("label") ?? "",
            yLabel: await resolver.replacingItem(item).string("yAxisLabel") ?? "",
            barLabelFont: await barLabelFont,
            valueLabelFont: await valueLabelFont);
        x++;
      }
    });
    var hideGridLines = await hideGridlines;
    return BarChartData(
      gridData: FlGridData(drawVerticalLine: !hideGridLines, drawHorizontalLine: !hideGridLines),
      minY: await yAxisStartAtZero ? 0 : null,
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      barGroups: data,
      titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (double value) => itemChartProps[value.toInt()]!.xLabel,
              getTextStyles: (double value) => TextStyle(
                    color: Colors.black,
                    fontSize: itemChartProps[value.toInt()]!.barLabelFont.size,
                    fontWeight: itemChartProps[value.toInt()]!.barLabelFont.weight,
                  ))),
      barTouchData: BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
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

  Future<PieChartData> makePieChartModel() async {
    var resolver = viewContext.rendererDefinitionPropertyResolver;
    List<PieChartSectionData> data = [];
    var x = 0;
    await Future.forEach(viewContext.items, (ItemRecord item) async {
      var value = await resolver.replacingItem(item).number("yAxis");
      if (value != null) {
        itemChartProps[x] = ItemChartProps(
            xLabel: await resolver.replacingItem(item).string("label") ?? "",
            yLabel: await resolver.replacingItem(item).string("yAxisLabel") ?? "",
            barLabelFont: await barLabelFont,
            valueLabelFont: await valueLabelFont);
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
        sections: data, borderData: FlBorderData(show: false), centerSpaceRadius: double.infinity);
  }

  Future<LineChartData> makeLineChartModel() async {
    var resolver = viewContext.rendererDefinitionPropertyResolver;
    List<FlSpot> spots = [];
    await Future.forEach(viewContext.items, (ItemRecord item) async {
      var x = await resolver.replacingItem(item).number("xAxis");
      var y = await resolver.replacingItem(item).number("yAxis");
      if (x != null && y != null) {
        spots.add(FlSpot(x, y));
        itemChartProps[x.toInt()] = ItemChartProps(
            xLabel: await resolver.replacingItem(item).string("label") ?? "",
            yLabel: "",
            barLabelFont: await barLabelFont,
            valueLabelFont: await valueLabelFont);
      }
    });
    var hideGridLines = await hideGridlines;
    var lineChartData = LineChartBarData(
      spots: spots,
      barWidth: await lineWidth,
      colors: [await primaryColor],
    );
    return LineChartData(
      gridData: FlGridData(drawVerticalLine: !hideGridLines, drawHorizontalLine: !hideGridLines),
      minY: await yAxisStartAtZero ? 0 : null,
      clipData: FlClipData.all(),
      borderData: FlBorderData(show: false),
      lineBarsData: [lineChartData],
      showingTooltipIndicators: await showValueLabels
          ? spots
              .mapIndexed((i, el) => ShowingTooltipIndicators(i, [
                    LineBarSpot(lineChartData, 0, lineChartData.spots[i]),
                  ]))
              .toList()
          : null,
      lineTouchData: LineTouchData(
        enabled: false,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              return LineTooltipItem(
                itemChartProps[lineBarSpot.x.toInt()]!.xLabel,
                TextStyle(
                    color: Colors.black,
                    fontSize: itemChartProps[lineBarSpot.x.toInt()]!.valueLabelFont.size,
                    fontWeight: itemChartProps[lineBarSpot.x.toInt()]!.valueLabelFont.weight),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  Widget chartTitleView() {
    return FutureBuilder(
        future: titlesInit(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Text(
                  chartTitle ?? "",
                  style: TextStyle(fontSize: 28),
                ),
                Text(
                  chartSubtitle ?? "",
                  style: TextStyle(color: CVUColor.system("secondaryLabel"), fontSize: 17),
                )
              ],
            );
          }
          return Empty();
        });
  }

  Future<String> get chartType async {
    return await viewContext.rendererDefinitionPropertyResolver.string("chartType") ?? "bar";
  }

  Widget get chartView {
    return FutureBuilder(
        future: chartType,
        builder: (BuildContext builder, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var _chartType = snapshot.data;
              switch (_chartType) {
                case "bar":
                  return FutureBuilder(
                      future: makeBarChartModel(),
                      builder: (BuildContext builder, AsyncSnapshot<BarChartData> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            var model = snapshot.data;
                            if (model == null) {
                              return missingDataView;
                            }
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  children: [chartTitleView(), Expanded(child: BarChart(model))]),
                            );
                          }
                        }
                        return Empty();
                      });
                case "line":
                  return FutureBuilder(
                      future: makeLineChartModel(),
                      builder: (BuildContext builder, AsyncSnapshot<LineChartData> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            var model = snapshot.data;
                            if (model == null) {
                              return missingDataView;
                            }
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  children: [chartTitleView(), Expanded(child: LineChart(model))]),
                            );
                          }
                        }
                        return Empty();
                      });
                case "pie":
                  return FutureBuilder(
                      future: makePieChartModel(),
                      builder: (BuildContext builder, AsyncSnapshot<PieChartData> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            var model = snapshot.data;
                            if (model == null) {
                              return missingDataView;
                            }
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                  children: [chartTitleView(), Expanded(child: PieChart(model))]),
                            );
                          }
                        }
                        return Empty();
                      });
              }
            }
          }
          return Empty();
        });
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
