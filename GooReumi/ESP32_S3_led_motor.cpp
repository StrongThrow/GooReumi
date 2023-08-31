#include <Arduino.h>
#include "ESP32_S3_led_motor.h"

unsigned long motor_time_before = 0;

void control_led(bool Human_detect_flag, char LED_PIN){ // 카메라에 사람이 인식되었을 때 led점등
  if(Human_detect_flag == true){
    digitalWrite(LED_PIN, 10);
  }else{
    digitalWrite(LED_PIN, 0);
  }
}

void control_water_motor_auto(bool planter_water_mode_flag, int water_amount, int soilmoisture, char MOTOR_PIN, int motor_work_time_half, unsigned long water_frequency){ //구르미의 물 자동 주기 모드

  unsigned long motor_time_now = millis();
  unsigned long delay_time = water_frequency - motor_work_time_half;
  unsigned long reset_time = water_frequency + motor_work_time_half;
  
  if(planter_water_mode_flag == true){ // 주기별로 토양 습도 체크를 통한 물 주기 모드일 때

    if(motor_time_now - motor_time_before >= delay_time){ //motor_work_time 마다 작동
      if(water_amount >= soilmoisture){ // 사용자가 원하는 토양 습도가 현재 습도보다 낮을 때 
        digitalWrite(MOTOR_PIN, HIGH); // 워터 펌프 작동 
      }else{ // 사용자가 원하는 토양 습도가 현재 습도보다 높을 때 
        digitalWrite(MOTOR_PIN, LOW); // 워터 펌프 작동x
      }
    }

    if(motor_time_now - motor_time_before < delay_time){ //사용자가 설정한 주기 동안 워터 펌프 off
      digitalWrite(MOTOR_PIN, LOW);
    }
  }

  if(motor_time_now - motor_time_before >= reset_time){
      motor_time_before = motor_time_now;
  }
}
bool control_water_motor_manual(bool planter_water_mode_flag, bool button, char MOTOR_PIN){ // 구르미의 물 주기 수동 모드

  if(planter_water_mode_flag == false){// 물 주기가 수동 모드일 때
    if(button == false){//버튼을 누르지 않았을 때
      digitalWrite(MOTOR_PIN, LOW);
      return false;
    }else{
      digitalWrite(MOTOR_PIN, HIGH);
      delay(800); // 0.8초동안 물 공급 
      return false; // 워터 펌프 off
    }
  }else{
    return false;
  }
}