import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DetailedTemperaturePage extends StatefulWidget {
  final List<Map<String, dynamic>> temperatureData;
  final String plantVarieties;

  const DetailedTemperaturePage({Key? key, required this.temperatureData, required this.plantVarieties}) : super(key: key);

  @override
  _DetailedTemperaturePageState createState() => _DetailedTemperaturePageState();
}

class _DetailedTemperaturePageState extends State<DetailedTemperaturePage> {
  Color mainColor = Color(0xFF496054);

  int initialIndex = 0;
  int selectedHours = 1;
  Map<String, dynamic>? temperature;

  List<Map<String, dynamic>> getFilteredData() {
    if (widget.temperatureData.isEmpty) {
      return [];
    }

    DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
    final lastRecordDate = format.parse(widget.temperatureData.last['date']);
    final cutoffDate = lastRecordDate.subtract(Duration(hours: selectedHours));

    return widget.temperatureData.where((data) {
      try {
        final dataDate = format.parse(data['date']);
        return dataDate.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  double calculateAverageTemperature(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return 0.0;
    }
    return data.map((e) => e['temperature']).reduce((a, b) => a + b) / data.length;
  }

  Future<Map<String, dynamic>?> fetchTemperatureForPlant(String plantName) async {
    // json 파일 로드
    String jsonString = await rootBundle.loadString('assets/info.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> plantsData = jsonData['plants'];

    // 식물 품종 찾기
    for (Map<String, dynamic> plant in plantsData) {
      if (plant["name"] == plantName) {
        return plant["temperature"];
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchTemperatureForPlant(widget.plantVarieties).then((data) {
      setState(() {
        temperature = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = getFilteredData();
    double averageTemperature = calculateAverageTemperature(filteredData);

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text('온도 리포트', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: mainColor,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SfLinearGauge(
              minimum: 0,
              maximum: 40,  //온도 범위
              markerPointers: [
                LinearShapePointer(
                  value: averageTemperature,
                  height: 20,
                  width: 20,
                  shapeType: LinearShapePointerType.invertedTriangle,
                  color: Colors.white,
                ),
              ],
              axisTrackStyle: LinearAxisTrackStyle(
                color: Colors.grey[300],
                edgeStyle: LinearEdgeStyle.bothCurve,
              ),
              ranges: <LinearGaugeRange>[
                LinearGaugeRange(
                  rangeShapeType: LinearRangeShapeType.flat,
                  startValue: temperature?['min'].toDouble(),
                  endValue: temperature?['max'].toDouble(),
                  color: Colors.tealAccent,
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('평균 온도: ${averageTemperature.toStringAsFixed(1)}', style: TextStyle(color: Colors.white)),
                Text('권장 온도 : ${temperature?['min']} ~ ${temperature?['max']}', style: TextStyle(color: Colors.white)),
              ],
            ),
            SizedBox(height: 20,),
            ToggleSwitch(
              initialLabelIndex: initialIndex,
              totalSwitches: 3,
              activeBgColor: [Colors.white],
              activeFgColor: Colors.black,
              inactiveBgColor: Colors.grey[300],
              inactiveFgColor: Colors.black,
              labels: ['1시간', '2시간', '6시간'],
              onToggle: (index) {
                if(index == 0){
                  setState(() {
                    selectedHours = 1;
                    initialIndex = 0;
                  });
                }
                else if(index == 1){
                  setState(() {
                    selectedHours = 2;
                    initialIndex = 1;
                  });
                }
                else {
                  setState(() {
                    selectedHours = 6;
                    initialIndex = 2;
                  });
                }
              },
            ),
            SizedBox(height: 20,),
            Expanded(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: DetailedTemperatureChart(temperatureData: filteredData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedTemperatureChart extends StatefulWidget {
  final List<Map<String, dynamic>> temperatureData;

  const DetailedTemperatureChart({Key? key, required this.temperatureData}) : super(key: key);

  @override
  _DetailedTemperatureChartState createState() => _DetailedTemperatureChartState();
}

class _DetailedTemperatureChartState extends State<DetailedTemperatureChart> {

  List<Color> gradientColors = [
    Colors.tealAccent,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        LineChart(
          mainData(),
        ),
      ],
    );
  }

  LineChartData mainData() {
    double maxY = widget.temperatureData.map((e) => (e['temperature']).toDouble()).reduce((value, element) => value > element ? value : element);

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
      maxX: widget.temperatureData.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.temperatureData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), (e.value['temperature']).toDouble());
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

              if (dataIndex < 0 || dataIndex >= widget.temperatureData.length) {
                return null;
              }

              final date = widget.temperatureData[dataIndex]['date'];
              return LineTooltipItem(date, const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}