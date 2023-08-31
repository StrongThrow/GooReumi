import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WaterLevelChart extends StatefulWidget {
  final List<Map<String, dynamic>> waterLevelData;
  final String plantVarieties;

  const WaterLevelChart({Key? key, required this.waterLevelData, required this.plantVarieties}) : super(key: key);

  @override
  _WaterLevelChartState createState() => _WaterLevelChartState();
}

class _WaterLevelChartState extends State<WaterLevelChart> {
  List<Color> gradientColors = [
    Colors.tealAccent,
    Colors.blue,
  ];

  bool showAvg = false;
  List<Map<String, dynamic>> waterLevelLastTenData = [];
  double waterLevelAverage = 0;

  @override
  void initState() {
    super.initState();
    var startIndex = widget.waterLevelData.length > 10 ? widget.waterLevelData.length - 10 : 0;
    waterLevelLastTenData = widget.waterLevelData.sublist(startIndex, widget.waterLevelData.length);
    waterLevelAverage = widget.waterLevelData.last['waterLevel'].toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              width: double.maxFinite,
              height: 100,
              child: LineChart(
                mainData(),
              ),
            ),
            SizedBox(
              height: 30,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('수조 물 높이: ${waterLevelAverage.toStringAsFixed(1)}'),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  LineChartData mainData() {
    double maxY = waterLevelLastTenData.map((e) => (e['waterLevel'] as int).toDouble()).reduce((value, element) => value > element ? value : element);

    return LineChartData(
      gridData: FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: waterLevelLastTenData.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: waterLevelLastTenData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), (e.value['waterLevel'] as int).toDouble());
          }).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              final dataIndex = flSpot.x.toInt();

              if (dataIndex < 0 || dataIndex >= waterLevelLastTenData.length) {
                return null;
              }

              final date = waterLevelLastTenData[dataIndex]['date'];
              return LineTooltipItem(date, const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}