#include <Arduino.h>
#include "ESP32_S3_camera.h"
#include "ESP32_S3_wifi.h"
#include "ESP32_S3_firebase_read_write.h"
#include "ESP32_S3_servo.h"
#include "DHT.h"
#include "ESP32_S3_oled.h"
#include "ESP32_S3_led_motor.h"

//-----set dht11
#define DHTTYPE DHT11

//-----set camera 
#define websocket_server_host "*****" // put your camera strimming server ip
#define websocket_server_port ***** // put your camera strimming server port
#define jpeg_quality 50 //10~63 high <-> low camera quality


//-----set firebase

//firebase read path
#define Button_path "/Smart_Plnater_settings/button"// 버튼 경로
#define Sleep_mode_path "/Smart_Plnater_settings/Sleep_Mode"// 슬립 모드 경로
#define Water_mode_path "/Smart_Plnater_settings/Water_Mode"// 물 주기 모드 경로
#define Motor_degree_path "/Smart_Plnater_settings/motor_degree" // 슬립 모드가 아닌 상황에서 사용자가 설정하는 각도
#define Face_detect_path "/Machine_Learning/Face_detect" //얼굴 인식 확인 경로 boolen값으로 손이나 얼굴이 감지되면 true, 감지되지 않으면 false
#define Hand_detect_path "/Machine_Learning/Hand_detect" // 손 인식 확인 경로 int형으로 0 : 감지 되지 않음, 1~5 : 손가락 1개 감지 ~ 손가락 5개 감지, 6 : 엄지 척(따봉) 7 : 손하트
#define Hand_gesture_path "/Machine_Learning/Hand_gesture"// 손 모양을 인식하는 경로
#define Human_detect_path "/Machine_Learning/Human_detect"// 사람이 인식되어지는지 확인하는 경로, led 점등 제어
#define Human_not_detect_path "/Machine_Learning/Human_not_detect"// 사람이 15초동안 감지가 되지 않음을 확인하는 경로
#define Water_amount_path "/Smart_Plnater_settings/water_amount"// 습도 측정하여 물을 주는 상황에서 물의 양을 가져오는 경로
#define Soilmoisture_want_path "/Smart_Plnater_settings/soilmoisture_want"// 습도 측정하여 물을 주는 상황에서 사용자가 원하는 습도를 가져오는 경로
#define Water_frequency_path "/Smart_Plnater_settings/water_frequency"// 주기적으로 물을 주는 상황에서 주기를 가져오는 경로(몇 일)
#define app_setting_changed_path "/Smart_Plnater_settings/app_setting_changed" //파이어베이스의 정보가 바뀌었는지 check

//firebase write path
#define Brightness_path "/Smart_Planter_Sensors/Brightness/"//현재 밝기를 업로드하는 경로
#define Humidity_path "/Smart_Planter_Sensors/Humidity/"//현재 습도를 업로드하는 경로
#define Soil_moisture_path "/Smart_Planter_Sensors/Soil_moisture/"//현재 토양 습도를 업로드하는 경로
#define Temperature_path "/Smart_Planter_Sensors/Temperature/"//현재 온도를 업로드하는 경로
#define  Water_level_path "/Smart_Planter_Sensors/Water_level/"//현재 물탱크의 물의 양을 업로드하는 경로



// 파이어베이스 API 키
#define API_KEY "*****"

// 파이어베이스 URL
#define DATABASE_URL "*****" 



//----- GPIO PIN 설정 
#define BRIGHTNESS_PIN 1
#define WATERLEVEL_PIN 2
#define SOILMOISTURE_PIN 14
#define SERVO_PIN 38
#define LED_PIN 40
#define MOTOR_PIN 39
#define DHTPIN 19
#define SDA_PIN 47
#define SCL_PIN 21


DHT dht(DHTPIN, DHTTYPE);

TaskHandle_t Task1;
TaskHandle_t Task2; //듀얼 코어 설정


//-----firebase에 정보를 보낼 때 사용되는 시간 변수
unsigned long firebase_send_time_now = 0;
unsigned long firebase_send_time_before = 0;

//-----firebase에 정보를 받을 때 사용되는 시간 변수
unsigned long firebase_read_time_now = 0;
unsigned long firebase_read_time_before = 0;

//-----화분을 제어할 때 사용되는 변수들
bool button = false; // 수동으로 물을 줄 시 버튼의 입력값
bool planter_infomation_flag = false; // 파이어베이스 정보 변경 시 true
bool planter_sleep_mode_flag = false; // 슬립 모드 시 true
bool planter_water_mode_flag = false; // 습도 측정 자동 모드시 true, 수동 모드 시 false
int water_amount; // 자동 모드에서 물을 몇 초동안 줄 것인지
int soilmoisture_want; // 자동 모드에서 사용자가 원하는 토양 습도
int motor_degree = 0; //사용자가 입력하는 카메라 각도 설정
unsigned long water_frequency; // 물을 몇일 간격으로 줄지

//-----머신 러닝 관련 변수들 
bool Human_detect_flag = false; // 사람이 감지되어지는지
bool Human_not_detect_15sec_flag = false; //사람이 15초동안 감지되어지지 않는지 확인
int Hand_gesture = 0; //0 : 감지 되지 않음, 1~5 : 손가락 1개 감지 ~ 손가락 5개 감지, 6 : 엄지 척(따봉) 7 : 손하트

//-----센서 값 정보들
int brightness; // 밝기
int waterlevel; //물 수위
int soilmoisture; // 토양 습도
float temperature; // 온도
float humidity; // 습도

//-----디스플레이 관련 변수
unsigned long lcd_now = 0;
unsigned long lcd_before_smile = 0;
unsigned long lcd_before_sleep = 0;
char oled_display_mode = 0;
const char sleep_oled = 3;
const char fix_oled = 2;
const char face_oled = 1;
const char clear_oled = 0;

//-------------------------------------------파이어베이스 정보 송신-------------------------------------
void send_firebase(unsigned int sending_delay_ms){// sending_delay_ms 마다 파이어베이스에 정보를 보냄
  firebase_send_time_now = millis();

  if(firebase_send_time_now - firebase_send_time_before >= sending_delay_ms){ 
    firebase_send_time_before = firebase_send_time_now;
    
    humidity = dht.readHumidity(); // dht-11에서 습도를 읽어옴
    Serial.print("hum : ");
    Serial.println(humidity); 
    write_firebase_float(Humidity_path, humidity); // 습도 정보 전송
    temperature = dht.readTemperature(); // dht-11에서 온도를 읽어옴
    Serial.print("temp : ");
    Serial.println(temperature);
    write_firebase_float(Temperature_path, temperature); // 온도 정보 전송
    brightness = write_firebase_int(Brightness_path,BRIGHTNESS_PIN); // 밝기 측정 및 전송
    soilmoisture = write_firebase_int(Soil_moisture_path,SOILMOISTURE_PIN); // 토양 습도 측정 및 전송
    waterlevel = write_firebase_int(Water_level_path,WATERLEVEL_PIN); // 수위 측정 및 전송
    
  }
}

//-----------------------------------------------------------------------------------------------------

//-------------------------------------------파이어베이스 정보 수신--------------------------------------
void read_firebase(unsigned int reading_delay_ms){
  firebase_read_time_now = millis();
  
  if(firebase_read_time_now - firebase_read_time_before >= reading_delay_ms){// reading_delay_ms 시간 마다 파이어베이스에서 정보를 읽음 
    firebase_read_time_before = firebase_read_time_now;
    
    planter_infomation_flag = read_firebase_bool(app_setting_changed_path); // 파이어베이스에서 정보가 바뀌는지 check 정보가 바뀌면 앱 측에서 true로 변경 

//--------------------화분세팅 관련 firebase 정보 읽기-------------------------------------------------

    if(planter_infomation_flag == true){//앱에서 화분으로 정보를 전송 하였으면
      planter_sleep_mode_flag = read_firebase_bool(Sleep_mode_path); // 슬립 모드 read

      motor_degree = read_firebase_value(Motor_degree_path); //모터의 각도 확인


      planter_water_mode_flag = read_firebase_bool(Water_mode_path);//화분 물 주는 모드 check, 주기적으로 물을 줄지, 원하는 토양 습도가 유지되도록 물을 줄지에 대한 정보

      if(planter_water_mode_flag == true){//토양 습도 센서를 통해 주기적으로 물을 주며 일정 토양 습도를 맞춰주는 상황에서 모터를 돌리는 시간을 읽어옴
        int water_amount_sec;
        water_amount_sec = read_firebase_value(Water_amount_path);
        water_amount = water_amount_sec * 1000 / 2; // 받아온 정보를 ms로 변환(함수에서 x 2 로 전환되기 때문에 나누기 2)

        soilmoisture_want = read_firebase_value(Soilmoisture_want_path); // 

        int water_frequency_day; 
        water_frequency_day = read_firebase_value(Water_frequency_path);//실제 일 단위로 입력받지만, 시연을 위해 초 단위로 변환 
        water_frequency = water_frequency_day*1000;//ms로 변환

      }else{//물 주기가 수동 모드일 때
        button = read_firebase_bool(Button_path); // 버튼의 on off를 읽어옴
        write_firebase_bool(Button_path, false); // 정보 수신이 끝났으면, false로 변경
      }
    
      write_firebase_bool(app_setting_changed_path, false); // 정보 수신이 끝났으면, false로 변경

    }

//--------------------머신러닝 관련 firebase 정보 읽기-------------------------------------------------
    if(planter_sleep_mode_flag == false){//슬립 모드가 아닐 때만 사람이 감지되는지 확인
      Human_detect_flag = read_firebase_bool(Human_detect_path); // 사람이 감지되어 지는지 확인

      if(Human_detect_flag == true){//사람이 감지되면
        Hand_gesture = read_firebase_value(Hand_gesture_path); // 손 동작 확인
        Human_not_detect_15sec_flag = false; // 사람이 15초동안 인식되어지지 않음
      }else{//사람이 감지되지 않으면 
        Human_not_detect_15sec_flag = read_firebase_value(Human_not_detect_path); // 사람이 15초동안 감지되어지지 않는지 확인
        Hand_gesture = 0; // 손가락 인식 갯수 초기화
      }
    }
//-----------------------------------------------------------------------------------------------------
  }
}

//-----------------------------------------------------------------------------------------------------

void display_ssd1306(){// 화분의 oled 디스플레이 설정 

//-------------------디스플레이 모드가 클리어 모드일 시--------------------------------
  if(oled_display_mode == clear_oled){//디스플레이 모드가 클리어일 시 디스플레이 클리어
    
    if((Hand_gesture >= 2) && (Hand_gesture < 5)){ // 손가락이 2~4개 감지되면
      oled_display_mode = fix_oled; // 고정 모드로 전환 
    }else{ // 손가락이 2개 이상 감지되어지지 않았을 때
  //----------------------------------------------------------------------------------
      if(Human_detect_flag == true){//사람이 감지되면
        oled_display_mode = face_oled; // 디스플레이 모드를 얼굴 출력 모드로 전환
      }else{ // 사람이 감지되지 않으면 
    //--------------------------------------------------------------------------------
        if(Human_not_detect_15sec_flag == true){ // 사람이 15초동안 감지되어지지 않으면 
          display_boring(500);
        }else{ // 사람이 감지되어진지 15초가 지나지 않았으면 
          clear_display();
        }
      }
    }
    if(planter_sleep_mode_flag == true){//슬립 모드로 화분이 전환 시
      oled_display_mode = sleep_oled;//슬립 모드로 전환
    }
  }
//------------------------------------------------------------------------------------

//-------------------디스플레이 모드가 얼굴 출력 모드일 시-------------------------------
  if(oled_display_mode == face_oled){//디스플레이 모드가 얼굴 출력 모드일 때 얼굴 출력 

    if((Hand_gesture >= 2) && (Hand_gesture < 5)){ // 손가락이 2개~4개가 감지되면
      oled_display_mode = fix_oled; // 고정 모드로 전환 
    }
    if(Human_detect_flag == false){//사람이 감지되지 않으면
      oled_display_mode = clear_oled; // 디스플레이 모드를 클리어로 변경
    }

    if(Human_detect_flag == true){//사람이 감지될때
    
      if(Hand_gesture < 2){//손가락 인식이 되지 않으면
        display_smiling(500); // 웃는 표정 출력
      }
      if(Hand_gesture == 5){ // 5개의 손가락이 감지되면 
        display_hello(500); // 안녕 애니매이션 출력
      }
      if(Hand_gesture == 6){ // 엄지척이 감지되면
        display_thumbup(); // 하트 사진 출력
      }
      if(Hand_gesture == 7){ // 손 하트가 감지되면
        display_heart(); // 하트 사진 출력
      }
    }

    if(planter_sleep_mode_flag == true){//슬립 모드로 화분이 전환 시
      oled_display_mode = sleep_oled;//슬립 모드로 전환
    }
}
//-------------------------------------------------------------------------------------

//-------------------디스플레이 모드가 고정 모드일 시-------------------------------------
  if(oled_display_mode == fix_oled){//디스플레이 모드가 고정 모드일 때 정보들 출력 

    if(Hand_gesture == 1){ // 1개의 손가락이 감지되면
      oled_display_mode = clear_oled; // 클리어 모드로 전환
    }
    if(Hand_gesture == 2){ // 2개의 손가락이 감지되면 
      display_time(); // 시간 출력 
    }
    if(Hand_gesture == 3){ // 3개의 손가락이 감지되면 
      display_dht11(temperature, humidity); // 온습도 출력
    }
    if(Hand_gesture == 4){ // 4개의 손가락이 감지되면 
      display_sensors(brightness, waterlevel, soilmoisture); // 각종 센서값 출력 
    }
    if(planter_sleep_mode_flag == true){//슬립 모드로 화분이 전환 시
      oled_display_mode = sleep_oled;//슬립 모드로 전환
    }
  }
//-------------------------------------------------------------------------------------

//-------------------디스플레이 모드가 슬립 모드일 시-------------------------------------
  if(oled_display_mode == sleep_oled){//디스플레이 모드가 슬립 모드일 때
    display_sleeping(500); // 자는 애니매이션 재생
    if(planter_sleep_mode_flag == false){//노멀 모드로 화분이 전환 시
      oled_display_mode = clear_oled;//슬립 모드로 전환
    }
  }
//--------------------------------------------------------------------------------------

}


void setup() {
  Serial.begin(115200);//pc와의 시리얼 통신
  //initSPIFFS();
  //setSPIFFS_wifi();
  set_wifi(); // 와이파이 연결
  pinMode(LED_PIN, OUTPUT); // led연결 핀 output 설정
  pinMode(MOTOR_PIN, OUTPUT); // 모터 드라이버 핀 output설정
  set_camera(jpeg_quality, websocket_server_host, websocket_server_port); // 카메라 설정 및 GCP서버 연결
  servo_init(SERVO_PIN); // 서보 모터 설정
  ntpTime_init();// 시간 서버 연결 
  dht.begin(); // dht-11작동
  I2C_init(SDA_PIN, SCL_PIN); // oled 디스플레이 설정
  set_firebase(API_KEY, DATABASE_URL); // 파이어베이스 연결
 
  //create a task that will be executed in the Task1code() function, with priority 1 and executed on core 0
  xTaskCreatePinnedToCore(
                    Task1code,   /* Task function. */
                    "Task1",     /* name of task. */
                    20000,       /* Stack size of task */
                    NULL,        /* parameter of the task */
                    1,           /* priority of the task */
                    &Task1,      /* Task handle to keep track of created task */
                    0);          /* pin task to core 0 */                  
  delay(500); 

  //create a task that will be executed in the Task2code() function, with priority 1 and executed on core 1
  xTaskCreatePinnedToCore(
                    Task2code,   /* Task function. */
                    "Task2",     /* name of task. */
                    20000,       /* Stack size of task */
                    NULL,        /* parameter of the task */
                    1,           /* priority of the task */
                    &Task2,      /* Task handle to keep track of created task */
                    1);          /* pin task to core 1 */
    delay(500); 
  
}

void Task1code(void * pvParameters){//코어 0 -
  Serial.print("Task1 running on core ");
  Serial.println(xPortGetCoreID());

  for(;;){
    send_camera_data(); // 카메라 데이터 GCP서버로 전송
  } 
}


void Task2code(void * pvParameters){//코어 1
  Serial.print("Task2 running on core ");
  Serial.println(xPortGetCoreID());

  for(;;){
    read_firebase(2100); //ms마다 파이어베이스의 정보 읽음
    send_firebase(40000);//ms마다 파이어베이스로 정보 전송
    servo_camera(planter_sleep_mode_flag, motor_degree); // 슬립 모드에 따른 카메라 서보 모터 제어
    control_led(Human_detect_flag, LED_PIN); // led 점등 제어 
    control_water_motor_auto(planter_water_mode_flag, soilmoisture_want, soilmoisture, MOTOR_PIN, water_amount, water_frequency);
    button = control_water_motor_manual(planter_water_mode_flag, button, MOTOR_PIN);
    display_ssd1306(); // ssd1306 oled 제어
  }
}


void loop() {
 ;
}
