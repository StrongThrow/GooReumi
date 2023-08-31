import 'package:embedded/page/detailChart_page/moistureChart_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MoistureChart extends StatefulWidget {
  final List<Map<String, dynamic>> moistureData;
  final String plantVarieties;

  const MoistureChart({Key? key, required this.moistureData, required this.plantVarieties}) : super(key: key);

  @override
  _MoistureChartState createState() => _MoistureChartState();
}

class _MoistureChartState extends State<MoistureChart> {
  List<Color> gradientColors = [
    Colors.tealAccent,
    Colors.blue,
  ];

  bool showAvg = false;
  List<Map<String, dynamic>> moistureLastTenData = [];
  double moistureAverage = 0;

  @override
  void initState() {
    super.initState();
    var startIndex = widget.moistureData.length > 10 ? widget.moistureData.length - 10 : 0;
    moistureLastTenData = widget.moistureData.sublist(startIndex, widget.moistureData.length);
    moistureAverage = moistureLastTenData.map((e) => e['moisture'] as int).reduce((a, b) => a + b) / moistureLastTenData.length;
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedMoisturePage(moistureData: widget.moistureData, plantVarieties: widget.plantVarieties,)));
              },
              child: SizedBox(
                height: 30,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('토양습도: ${moistureAverage.toStringAsFixed(1)}'),
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
    double maxY = moistureLastTenData.map((e) => (e['moisture'] as int).toDouble()).reduce((value, element) => value > element ? value : element);

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
      maxX: moistureLastTenData.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: moistureLastTenData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), (e.value['moisture'] as int).toDouble());
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

              if (dataIndex < 0 || dataIndex >= moistureLastTenData.length) {
                return null;
              }

              final date = moistureLastTenData[dataIndex]['date'];
              return LineTooltipItem(date, const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}