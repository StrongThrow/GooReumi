import 'package:embedded/page/detailChart_page/humidityChart_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HumidityChart extends StatefulWidget {
  final List<Map<String, dynamic>> humidityData;
  final String plantVarieties;

  const HumidityChart({Key? key, required this.humidityData, required this.plantVarieties}) : super(key: key);

  @override
  _HumidityChartState createState() => _HumidityChartState();
}

class _HumidityChartState extends State<HumidityChart> {
  List<Color> gradientColors = [
    Colors.tealAccent,
    Colors.blue,
  ];

  bool showAvg = false;
  List<Map<String, dynamic>> humidityLastTenData = [];
  double humidityAverage = 0;

  @override
  void initState() {
    super.initState();
    var startIndex = widget.humidityData.length > 10 ? widget.humidityData.length - 10 : 0;
    humidityLastTenData = widget.humidityData.sublist(startIndex, widget.humidityData.length);
    humidityAverage = humidityLastTenData.map((e) => e['humidity'] as int).reduce((a, b) => a + b) / humidityLastTenData.length;
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
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedHumidityPage(humidityData: widget.humidityData, plantVarieties: widget.plantVarieties,)));
              },
              child: SizedBox(
                height: 30,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('습도: ${humidityAverage.toStringAsFixed(1)}'),
                      Text('더보기')
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  LineChartData mainData() {
    double maxY = humidityLastTenData.map((e) => (e['humidity'] as int).toDouble()).reduce((value, element) => value > element ? value : element);

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
      maxX: humidityLastTenData.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: humidityLastTenData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), (e.value['humidity'] as int).toDouble());
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

              if (dataIndex < 0 || dataIndex >= humidityLastTenData.length) {
                return null;
              }

              final date = humidityLastTenData[dataIndex]['date'];
              return LineTooltipItem(date, const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}