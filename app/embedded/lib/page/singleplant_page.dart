import 'dart:io';

import 'package:embedded/logic/level.dart';
import 'package:embedded/page/introduction_page.dart';
import 'package:embedded/page/setting_page.dart';
import 'package:embedded/page/webview_page.dart';
import 'package:embedded/widget/achievement_widget.dart';
import 'package:embedded/widget/chart/brightness_chart.dart';
import 'package:embedded/widget/chart/humidity_chart.dart';
import 'package:embedded/widget/chart/temperature_chart.dart';
import 'package:embedded/widget/chart/waterLevel_chart.dart';
import 'package:embedded/widget/chart/moisture_chart.dart';
import 'package:embedded/widget/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SinglePlantPage extends StatefulWidget {
  const SinglePlantPage({super.key});

  @override
  State<SinglePlantPage> createState() => _SinglePlantPageState();
}

class _SinglePlantPageState extends State<SinglePlantPage> {

  late FToast fToast;

  List<Map<String, dynamic>> _brightnessData = [];
  List<Map<String, dynamic>> _humidityData = [];
  List<Map<String, dynamic>> _moistureData = [];
  List<Map<String, dynamic>> _temperatureData = [];
  List<Map<String, dynamic>> _waterLevelData = [];
  List<bool> unlockStatus = List.generate(12, (index) => false);
  int _heartRate = 0;
  int _bestRate = 0;
  int level = 1;
  int face = 0;
  int reaction = 0;
  int consecutiveDays = 1;

  String speech = '';

  Color mainColor = Color(0xFF496054);
  int _currentIndex = 0;
  String plantName = '';
  String plantVarieties = '';
  bool _isDataLoaded = false;
  bool _isSleepMode = false;
  bool _isWaterAuto = false;
  bool isButtonEnabled = true;
  final PageController _pageController = PageController();

  Artboard? _riveArtboard;
  SMIInput<double>? _levelInput;
  SMIInput<double>? _faceInput;

  @override
  void initState() {
    super.initState();
    _loadPlantName();
    _loadLevelData();
    getHeart();
    getBest();
    getSleepMode();
    getWaterMode();
    brightnessFetchDataUsingOnValue();
    humidityFetchDataUsingOnValue();
    moistureFetchDataUsingOnValue();
    temperatureFetchDataUsingOnValue();
    waterLevelFetchDataUsingOnValue();
    getFace();
    loadUnlockStatus();
    rootBundle.load('assets/plant.riv').then(
          (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        var controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
          _levelInput = controller.findInput('Grow');
          _faceInput = controller.findInput('face');
        }
        setState(() {
          _riveArtboard = artboard;
          _levelInput?.value = level.toDouble();
          _faceInput?.value = face.toDouble();
        });
      },
    );

    fToast = FToast();
    fToast.init(context);
    setState(() {
      _isDataLoaded = true;
    });
  }

  _loadPlantName() async {
    plantName = (await _getPlantNameFromLocal())!;
    plantVarieties = (await getSavedPlantVarieties())!;
    print(plantVarieties);
    setState(() {});
  }

  _loadLevelData() async {
    LoginStreakManager.updateLoginStreak();
    int currentLevel = await LoginStreakManager.getCurrentLevel();
    int days = await LoginStreakManager.getConsecutiveDays();
    bool wasReset = await LoginStreakManager.wasLevelReset();
    level = currentLevel;
    consecutiveDays = days;
    unlockStatus[0] == false ? isChallengeUnlocked(1) : null;
    unlockStatus[7] == false ? isChallengeUnlocked(8) : null;
    unlockStatus[5] == false ? isChallengeUnlocked(6) : null;
    unlockStatus[6] == false && wasReset == true ? isChallengeUnlocked(7) : null;
    setState(() {});
  }

  void getFace() {
      FirebaseDatabase.instance.ref("Machine_Learning/Hand_gesture").onValue.listen((event) {
        final data = event.snapshot.value as int;
        if(data == 5 && _currentIndex == 0) {
          _faceInput?.value = 3;
          _showToast("안녕하세요 🖐");
          //인사할 떄
        } else if (data == 6 && _currentIndex == 0) {
          _faceInput?.value = 6;
          _showToast("고마워요! 👍");
          //따봉
        } else if (data == 7 && _currentIndex == 0) {
          _faceInput?.value = 5;
          _showToast("🧡");
          //손하트
        } else {
          _faceInput?.value = 0;
        }
        setState(() {});
      });
  }

  _showToast(String text) {
    Widget toast = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.greenAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(text),
        ),
      ],
    );

    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 5),
        gravity: ToastGravity.CENTER,
    );
  }

  double toastWidth(BuildContext context, Widget toast) {
    final box = toast as RenderBox;
    return box.size.width;
  }

  Future<String?> _getPlantNameFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('plant_name');
  }

  Future<String?> getSavedPlantVarieties() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedPlant');
  }

  void loadUnlockStatus() async {
    unlockStatus = await fetchUnlockStatus();
    setState(() {});
  }

  Future<List<bool>> fetchUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedStatus = prefs.getString('unlockStatus') ?? '';
    if (storedStatus.isEmpty) {
      return List.generate(12, (index) => false);  //기본값. 모두 잠금
    }
    return storedStatus.split(',').map((e) => e == 'true').toList();
  }

  Future<void> storeUnlockStatus(List<bool> unlockStatus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unlockStatus', unlockStatus.join(','));
  }

  bool? isChallengeUnlocked(int challengeNumber) {
    switch (challengeNumber) {
      case 1:
        return consecutiveDays >= 1 ? unlockStatus[0] = true : null;
      case 2:
        return _heartRate >= 1 ? unlockStatus[1] = true : null;
      case 3:
        return _bestRate >= 1 ? unlockStatus[2] = true : null;
      case 4:
        return unlockStatus[3] = true;
      case 5:
        return unlockStatus[4] = true;
      case 6:
        return consecutiveDays >= 7 ? unlockStatus[5] = true : null;
      case 7:
        return unlockStatus[6] = true;
      case 8:
        return level == 4 ? unlockStatus[7] = true : null;
      case 9:
        return consecutiveDays >= 31 ? unlockStatus[8] = true : null;
      case 10:
        return _heartRate >= 1000 ? unlockStatus[9] = true : null;
      case 11:
        return _bestRate >= 1000 ? unlockStatus[10] = true : null;
    }
    unlockStatus[11] == false
        ? unlockStatus.sublist(0, 11) == List.generate(11, (index) => true) ? unlockStatus[11] = true : null
        : null;
    storeUnlockStatus(unlockStatus);
    return null;
  }

  void getHeart() {
    FirebaseDatabase.instance.ref("Machine_Learning/Heart").onValue.listen((event) {
      final data = event.snapshot.value as int;
      _heartRate = data;
      unlockStatus[1] == false ? isChallengeUnlocked(2) : null;
      unlockStatus[9] == false ? isChallengeUnlocked(10) : null;
      setState(() {});
    });
  }

  void getBest() {
    FirebaseDatabase.instance.ref("Machine_Learning/Best").onValue.listen((event) {
      final data = event.snapshot.value as int;
      _bestRate = data;
      unlockStatus[2] == false ? isChallengeUnlocked(3) : null;
      unlockStatus[10] == false ? isChallengeUnlocked(11) : null;
      setState(() {});
    });
  }

  void getButtonInformation() {
    FirebaseDatabase.instance.ref("Smart_Plnater_settings/button").onValue.listen((event) {
      final data = event.snapshot.value as bool;
      if (data == false) {
        FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
          "app_setting_changed": true,
        });
      }
    });
  }

  void getSleepMode() {
    FirebaseDatabase.instance.ref("Smart_Plnater_settings/Sleep_Mode").onValue.listen((event) {
      final data = event.snapshot.value as bool;
      setState(() {
        _isSleepMode = data;
      });
    });
  }

  void getWaterMode() {
    FirebaseDatabase.instance.ref("Smart_Plnater_settings/Water_Mode").onValue.listen((event) {
      final data = event.snapshot.value as bool;
      setState(() {
        _isWaterAuto = data;
      });
    });
  }

  void brightnessFetchDataUsingOnValue() {
    DatabaseReference brightnessRef = FirebaseDatabase.instance.ref('Smart_Planter_Sensors/Brightness');
    brightnessRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> fetchedData = [];
      data?.forEach((date, value) {
        value.forEach((id, brightnessValue) {
          fetchedData.add({
            'date': date,
            'brightness': brightnessValue
          });
        });
      });
      setState(() {
        _brightnessData = fetchedData;
        _brightnessData.sort((a, b) {
          DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
          DateTime dateA = format.parse(a['date']);
          DateTime dateB = format.parse(b['date']);
          return dateA.compareTo(dateB);
        });
      });
    });
  }

  void humidityFetchDataUsingOnValue() {
    DatabaseReference humidityRef = FirebaseDatabase.instance.ref('Smart_Planter_Sensors/Humidity');
    humidityRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> fetchedData = [];
      data?.forEach((date, value) {
        value.forEach((id, humidityValue) {
          fetchedData.add({
            'date': date,
            'humidity': humidityValue
          });
        });
      });
      setState(() {
        _humidityData = fetchedData;
        _humidityData.sort((a, b) {
          DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
          DateTime dateA = format.parse(a['date']);
          DateTime dateB = format.parse(b['date']);
          return dateA.compareTo(dateB);
        });
      });
    });
  }

  void moistureFetchDataUsingOnValue() {
    DatabaseReference moistureRef = FirebaseDatabase.instance.ref('Smart_Planter_Sensors/Soil_moisture');
    moistureRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> fetchedData = [];
      data?.forEach((date, value) {
        value.forEach((id, moistureValue) {
          fetchedData.add({
            'date': date,
            'moisture': moistureValue
          });
        });
      });
      setState(() {
        _moistureData = fetchedData;
        _moistureData.sort((a, b) {
          DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
          DateTime dateA = format.parse(a['date']);
          DateTime dateB = format.parse(b['date']);
          return dateA.compareTo(dateB);
        });
      });
    });
  }

  void temperatureFetchDataUsingOnValue() {
    DatabaseReference temperatureRef = FirebaseDatabase.instance.ref('Smart_Planter_Sensors/Temperature');
    temperatureRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> fetchedData = [];
      data?.forEach((date, value) {
        value.forEach((id, temperatureValue) {
          fetchedData.add({
            'date': date,
            'temperature': temperatureValue
          });
        });
      });
      setState(() {
        _temperatureData = fetchedData;
        _temperatureData.sort((a, b) {
          DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
          DateTime dateA = format.parse(a['date']);
          DateTime dateB = format.parse(b['date']);
          return dateA.compareTo(dateB);
        });
      });
    });
  }

  void waterLevelFetchDataUsingOnValue() {
    DatabaseReference waterLevelRef = FirebaseDatabase.instance.ref('Smart_Planter_Sensors/Water_level');
    waterLevelRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> fetchedData = [];
      data?.forEach((date, value) {
        value.forEach((id, waterLevelValue) {
          fetchedData.add({
            'date': date,
            'waterLevel': waterLevelValue
          });
        });
      });
      setState(() {
        _waterLevelData = fetchedData;
        _waterLevelData.sort((a, b) {
          DateFormat format = DateFormat("EEEE, MMMM d yyyy HH:mm:ss");
          DateTime dateA = format.parse(a['date']);
          DateTime dateB = format.parse(b['date']);
          return dateA.compareTo(dateB);
        });
      });
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onButtonPressed() async {

    if(unlockStatus[3] == false){
      isChallengeUnlocked(4);
    }

    setState(() {
      isButtonEnabled = false;
    });

    // 버튼 데이터 업데이트
    FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
      "button": true,
      "app_setting_changed": true,
    });

    sleep(Duration(milliseconds: 5000));

    setState(() {
      isButtonEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> _pages = [
      Center(
        child: Column(
          children: [
            Container(
                margin: EdgeInsets.all(10),
                height: 150,
                width: MediaQuery.of(context).size.width,
                color: mainColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text('$plantName', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo', fontSize: 25, fontWeight: FontWeight.bold),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text("Level : $level",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SpoqaHanSansNeo',
                            ),),
                          Text("❤ : $_heartRate",
                            style: TextStyle(
                              color: Colors.pinkAccent,
                              fontFamily: 'SpoqaHanSansNeo',
                            ),),
                          Text("👍 : $_bestRate",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontFamily: 'SpoqaHanSansNeo',
                            ),)
                        ],
                      ),
                    ],
                  ),
                )
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
                          color: Colors.white
                      )
                  ),
                  _riveArtboard == null ? SizedBox() :
                  Rive(
                    artboard: _riveArtboard!,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                height: 100,
                color: mainColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text('$plantName 건강차트', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo', fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      width: double.maxFinite,
                      height: 130,
                      child: BrightnessChart(brightnessData: _brightnessData, plantVarieties: plantVarieties,),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      width: double.maxFinite,
                      height: 130,
                      child: HumidityChart(humidityData: _humidityData, plantVarieties: plantVarieties,),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      width: double.maxFinite,
                      height: 130,
                      child: MoistureChart(moistureData: _moistureData, plantVarieties: plantVarieties,),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      width: double.maxFinite,
                      height: 130,
                      child: TemperatureChart(temperatureData: _temperatureData, plantVarieties: plantVarieties,),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      width: double.maxFinite,
                      height: 130,
                      child: WaterLevelChart(waterLevelData: _waterLevelData, plantVarieties: plantVarieties,),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
      Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: 100,
              color: mainColor,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text('$plantName 설정', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo', fontSize: 20, fontWeight: FontWeight.bold)),
                  )
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('외출 모드 설정', style: TextStyle(color: Colors.black87, fontFamily: 'SpoqaHanSansNeo')),
                                Switch(
                                  value: _isSleepMode,
                                  activeColor: Colors.tealAccent,
                                  onChanged: (bool? value) {
                                    if(_isSleepMode == false) {
                                      FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
                                        "Sleep_Mode": true,
                                        "app_setting_changed": true,
                                      });
                                      setState(() {
                                        _isSleepMode = true;
                                      });
                                    } else {
                                      FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
                                        "Sleep_Mode": false,
                                        "app_setting_changed": true,
                                      });
                                      setState(() {
                                        _isSleepMode = false;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('물 주기 자동 모드', style: TextStyle(color: Colors.black87, fontFamily: 'SpoqaHanSansNeo')),
                                Switch(
                                  value: _isWaterAuto,
                                  activeColor: Colors.tealAccent,
                                  onChanged: (bool? value) {
                                    if(_isWaterAuto == false) {
                                      FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
                                        "Water_Mode": true,
                                        "app_setting_changed": true,
                                      });
                                      setState(() {
                                        _isWaterAuto = true;
                                      });
                                    } else {
                                      FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
                                        "Water_Mode": false,
                                        "app_setting_changed": true,
                                      });
                                      setState(() {
                                        _isWaterAuto = false;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                        Divider(thickness: 1, height: 1),

                        SizedBox(
                          width: double.maxFinite,
                          height: 80,
                          child: ElevatedButton(
                            child: Text('${plantName} 원격 확인하기', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo')),
                            style: ElevatedButton.styleFrom(
                              primary: mainColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            onPressed: () {
                              if(unlockStatus[4] == false) {
                                isChallengeUnlocked(5);
                                setState(() {});
                              }
                              Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewPage()));
                            },
                          ),
                        ),

                        Divider(thickness: 1, height: 1),

                        _isWaterAuto ? Container(
                            width: double.maxFinite,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87, width: 1),
                            ),
                            child: Center(child: Text('자동모드 활성화 중')))
                            : SizedBox(
                          width: double.maxFinite,
                          height: 80,
                          child: ElevatedButton(
                            child: Text('수동 1회 물주기', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo')),
                            style: ElevatedButton.styleFrom(
                              primary: isButtonEnabled ? mainColor : Colors.grey,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            onPressed: isButtonEnabled ? _onButtonPressed : null,
                          ),
                        ),

                        Divider(thickness: 1, height: 1),

                        SizedBox(
                          width: double.maxFinite,
                          height: 80,
                          child: OutlinedButton(
                            child: Text('${plantName} 설정 다시하기', style: TextStyle(color: Colors.black87, fontFamily: 'SpoqaHanSansNeo')),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black87, width: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => IntroductionPage()));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Text('도전과제', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo', fontSize: 20, fontWeight: FontWeight.bold)),
                  )
              ),
            ),
            Divider(color: Colors.white,),
            CircleGrid(unlockStatus: unlockStatus, isHighLevel: false),
            Divider(color: Colors.white,),
            CircleGrid(unlockStatus: unlockStatus, isHighLevel: true),
          ],
        )
      ),
    ];

    if (!_isDataLoaded) {
      return SplashScreen(); // 로딩화면
    }
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0.0,
          backgroundColor: mainColor,
        ),
        backgroundColor: mainColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0.0,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.home, color: Colors.black87),
                label: '홈'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart, color: Colors.black87),
                label: '차트'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_run, color: Colors.black87),
                label: '액션'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.playlist_add_check_outlined, color: Colors.black87),
                label: '도전과제'
            ),
          ],
        )
    );
  }
}