import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DetailedBrightnessPage extends StatefulWidget {
  final List<Map<String, dynamic>> brightnessData;
  final String plantVarieties;

  const DetailedBrightnessPage({Key? key, required this.brightnessData, required this.plantVarieties}) : super(key: key);

  @override
  _DetailedBrightnessPageState createState() => _DetailedBrightnessPageState();
}

class _DetailedBrightnessPageState extends State<DetailedBrightnessPage> {

  Color mainColor = Color(0xFF496054);

  int initialIndex = 0;
  int selectedHours = 1;
  Map<String, dynamic>? illuminance;

  List<Map<String, dynamic>> getFilteredData() {
    if (widget.brightnessData.isEmpty) {
      return [];
    }

    DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
    final lastRecordDate = format.parse(widget.brightnessData.last['date']);
    final cutoffDate = lastRecordDate.subtract(Duration(hours: selectedHours));

    return widget.brightnessData.where((data) {
      try {
        final dataDate = format.parse(data['date']);
        return dataDate.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  double calculateAverageBrightness(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return 0.0;
    }
    return data.map((e) => e['brightness'] as int).reduce((a, b) => a + b) / data.length;
  }

  Future<Map<String, dynamic>?> fetchBrightnessForPlant(String plantName) async {
    // json 파일 로드
    String jsonString = await rootBundle.loadString('assets/info.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> plantsData = jsonData['plants'];

    // 식물 품종 찾기
    for (Map<String, dynamic> plant in plantsData) {
      if (plant["name"] == plantName) {
        plant["brightness"];
        brightnessToIlluminance(plant["brightness"]);
        return brightnessToIlluminance(plant["brightness"]);
      }
    }
    return null;
  }

  Map<String, int> brightnessToIlluminance(Map<String, dynamic> brightness) {
    // 밝기 레벨에 따른 범위
    const Map<int, List<int>> illuminanceMapping = {
      1: [1, 60],
      2: [60, 80],
      3: [80, 100]
    };

    int minBrightness = brightness['min'];
    int maxBrightness = brightness['max'];

    // 밝기 레벨에 따른 조도 범위
    int minIlluminance = illuminanceMapping[minBrightness]![0];
    int maxIlluminance = illuminanceMapping[maxBrightness]![1];

    return {
      'min': minIlluminance,
      'max': maxIlluminance,
    };
  }

  @override
  void initState() {
    super.initState();
    fetchBrightnessForPlant(widget.plantVarieties).then((data) {
      setState(() {
        illuminance = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredData = getFilteredData();
    double averageBrightness = calculateAverageBrightness(filteredData);

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        title: Text('조도 리포트', style: TextStyle(fontWeight: FontWeight.bold),),
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
              maximum: 100,  // 조도 범위
              markerPointers: [
                LinearShapePointer(
                  value: averageBrightness,
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
                  startValue: illuminance?['min'].toDouble(),
                  endValue: illuminance?['max'].toDouble(),
                  color: Colors.tealAccent,
                ),
              ],
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('평균 조도: ${averageBrightness.toStringAsFixed(1)}', style: TextStyle(color: Colors.white)),
                Text('권장 조도 : ${illuminance?['min']} ~ ${illuminance?['max']}', style: TextStyle(color: Colors.white)),
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: DetailedBrightnessChart(brightnessData: filteredData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailedBrightnessChart extends StatefulWidget {
  final List<Map<String, dynamic>> brightnessData;

  const DetailedBrightnessChart({Key? key, required this.brightnessData}) : super(key: key);

  @override
  _DetailedBrightnessChartState createState() => _DetailedBrightnessChartState();
}

class _DetailedBrightnessChartState extends State<DetailedBrightnessChart> {

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
    double maxY = widget.brightnessData.map((e) => (e['brightness'] as int).toDouble()).reduce((value, element) => value > element ? value : element);

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
      maxX: widget.brightnessData.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.brightnessData.asMap().entries.map((e) {
            return FlSpot(e.key.toDouble(), (e.value['brightness'] as int).toDouble());
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

              if (dataIndex < 0 || dataIndex >= widget.brightnessData.length) {
                return null;
              }

              final date = widget.brightnessData[dataIndex]['date'];
              return LineTooltipItem(date, const TextStyle(color: Colors.white));
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }
}