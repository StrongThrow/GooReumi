#include <Arduino.h>
#include "ESP32_S3_firebase_read_write.h"
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "time.h"


//Provide the token generation process info.
#include "addons/TokenHelper.h"
//Provide the RTDB payload printing info and other helper functions.
#include "addons/RTDBHelper.h"

// Insert your network credentials
#define WIFI_SSID "*****"

#define WIFI_PASSWORD "******"

const char BRIGHTNESS_PIN = 1;
const char SOILMOISTURE_PIN = 14;
const char WATERLEVEL_PIN = 2;


const char* ntpServer = "pool.ntp.org";
uint8_t timeZone = 9;
uint8_t summerTime = 0; // 3600



//Define Firebase Data object
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
int count = 0;
bool signupOK = false;


void set_wifi(){
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  }

void set_firebase(String API_KEY, String DATABASE_URL){
    /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

int write_firebase_int(String path, unsigned char PIN){

  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {//시간 정보를 받아오지 못하였을 때
    Serial.println("Failed to obtain time");
    return -1;
  }

  char timeStringBuff[50]; // 버퍼 크기 조절 가능

  strftime(timeStringBuff, sizeof(timeStringBuff), "%A, %B %d %Y %H:%M:%S", &timeinfo);
  String formattedTime = timeStringBuff;
  
  String firebase_path = path + formattedTime;

  int analogvalue_raw;
  int value;
  analogvalue_raw = analogRead(PIN);
  if(PIN == BRIGHTNESS_PIN){// 조도 센서일 때 
    value = 100 - (analogvalue_raw / 40); // 0~100 사이의 값으로 가공
  }
  if(PIN == SOILMOISTURE_PIN){// 토양 습도 센서일 때
    int value_buffer = analogvalue_raw / 40; // 0~100 사이의 값으로 가공 
    if(value_buffer >= 100){ // 100 이상의 값을 가지지 않도록 함
      value_buffer = 100;
    }
    value = (100 - (value_buffer)) * 2;
    if(value >= 100){
      value = 100;
    }
  }
  if(PIN == WATERLEVEL_PIN){ // 물 수위 센서일 때 
    value = analogvalue_raw / 40;
  }
  Firebase.RTDB.pushInt(&fbdo, firebase_path, value); // 시간 정보를 항목 명으로 하여 파이어베이스에 전송 

  return value;
}

void write_firebase_bool(String path, bool value){ // bool값을 넣는 함수 
  Firebase.RTDB.setBool(&fbdo, path, value);
}

void write_firebase_float(String path, float value){//dht-11에서만 이용 

  struct tm timeinfo;//시간 정보 받아오기
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return;
  }

  char timeStringBuff[50]; // 버퍼 크기 조절 가능

  strftime(timeStringBuff, sizeof(timeStringBuff), "%A, %B %d %Y %H:%M:%S", &timeinfo);
  String formattedTime = timeStringBuff;
  
  String firebase_path = path + formattedTime;//경로 + 시간 정보 이어붙이기

  // Write an Float number on the database path test/float
  Firebase.RTDB.pushFloat(&fbdo, firebase_path, value);

  
}

int read_firebase_value(String path){ // 파이어베이스 값을 읽어옴, int형
  int intValue;
  Firebase.RTDB.getInt(&fbdo, path);
  intValue = fbdo.intData();
  return intValue;
}

bool read_firebase_bool(String path){ // 파이어베이스 값을 읽어옴, bool형 
  bool boolValue;
  Firebase.RTDB.getInt(&fbdo, path);
  boolValue = fbdo.intData();
  return boolValue;  
}

void ntpTime_init(){ // ntp 설정 
  configTime(3600 * timeZone, 3600 * summerTime, ntpServer);
}


