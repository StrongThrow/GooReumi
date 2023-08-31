import 'dart:convert';

import 'package:embedded/page/singleplant_page.dart';
import 'package:embedded/page/webview_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {

  Color mainColor = Color(0xFF496054);

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> plants = [];
  List<Map<String, dynamic>> filteredPlants = [];
  String _plantName = '';
  String _waterAmount = '15';
  String _waterFrequency = '300';
  String _wantMoisture = '50';
  List<int> availableAngles = [0, 5, 10, 15, 20];
  int? selectedAngle;

  bool betaSetting = false;

  Map<String, dynamic>? _selectedPlant = null;

  @override
  void initState() {
    super.initState();
    _loadPlantData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: mainColor,
        appBar: AppBar(
          backgroundColor: mainColor,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: IntroductionScreen(
          globalBackgroundColor: mainColor,
          pages: [
            PageViewModel(
              titleWidget: Text('초기 설정!', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('스마트 플랜트의 초기 설정을 시작합니다.', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            PageViewModel(
              titleWidget: Text('품종 설정', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterPlants,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: '품종 검색...',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: double.maxFinite,
                    child: ListView.builder(
                      itemCount: filteredPlants.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(filteredPlants[index]['name'], style: TextStyle(color: Colors.white)),
                          onTap: () {
                            setState(() {
                              _selectedPlant = filteredPlants[index];
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            PageViewModel(
              titleWidget: Text('식물 옵션', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              bodyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '이름 짓기',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),
                            ),
                            onSaved: (value) => _plantName = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이름을 지어주세요';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                                labelText: '희망 토양습도 설정하기',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),
                            ),
                            onSaved: (value) => _wantMoisture = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '희망 토양습도를 설정해주세요';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(labelText: '모터 작동시간 설정하기',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),),
                            onSaved: (value) => _waterAmount = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '모터 작동시간을 설정해주세요';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(labelText: '물 주는 주기 설정하기',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),),
                            onSaved: (value) => _waterFrequency = value ?? '',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '물을 주는 주기를 설정해주세요';
                              }
                              return null;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("카메라 각도 설정", style: TextStyle(color: Colors.white)),
                              DropdownButton<int>(
                                value: selectedAngle,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    selectedAngle = newValue!;
                                  });
                                },
                                items: availableAngles.map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text("$value°"),
                                  );
                                }).toList(),
                              ),
                              OutlinedButton(
                                onPressed: selectedAngle == null
                                    ? null
                                    : () {
                                  FirebaseDatabase.instance
                                      .ref("Smart_Plnater_settings")
                                      .update({
                                    "motor_degree": selectedAngle,
                                    "app_setting_changed": true,
                                  });
                                },
                                child: Text("변경", style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: double.maxFinite,
                            height: 80,
                            child: OutlinedButton(
                              child: Text('카메라 각도 확인', style: TextStyle(color: Colors.white, fontFamily: 'SpoqaHanSansNeo')),
                              style: OutlinedButton.styleFrom(
                                primary: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewPage()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
          done: Text('시작', style: TextStyle(color: Colors.white)),
          onDone: () async {
            if(_selectedPlant == null){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('식물을 선택해주세요')));
            } else {
              _selectPlant(_selectedPlant!);
              _submitForm();
            }
          },
          scrollPhysics: const ClampingScrollPhysics(),
          showDoneButton: true,
          showNextButton: true,
          showSkipButton: false,
          next: Icon(Icons.arrow_forward, color: Colors.white),
        )
    );
  }

  void _filterPlants(String query) {
    setState(() {
      filteredPlants = plants
          .where((plant) => plant['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectPlant(Map<String, dynamic> plant) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPlant', plant['name']);
  }

  void _loadPlantData() async {
    String data = await rootBundle.loadString('assets/info.json');
    final List<dynamic> jsonResult = json.decode(data)['plants'];
    setState(() {
      plants = List<Map<String, dynamic>>.from(jsonResult);
      filteredPlants = plants;
    });
  }

  void _submitForm() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _savePlantNameToLocal(_plantName);
      await prefs.setBool('first_time', false);
      _selectPlant(_selectedPlant!);
      _saveDataToFirebase();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SinglePlantPage()));
    }
  }

  Future<void> _savePlantNameToLocal(String plantName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('plant_name', plantName);
  }

  void _saveDataToFirebase() {
    FirebaseDatabase.instance.ref("Smart_Plnater_settings").update({
      "water_amount": int.parse(_waterAmount),
      "water_frequency": int.parse(_waterFrequency),
      "soilmoisture_want": int.parse(_wantMoisture),
      "app_setting_changed": true,
    });
  }
}
