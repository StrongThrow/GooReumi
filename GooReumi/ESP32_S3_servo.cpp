#include <Arduino.h>
#include <ESP32Servo.h>

Servo servoMotor;

unsigned long servo_before = 0; 
unsigned char servo_degree = 140;


void servo_init(unsigned char SERVO_PIN){
  servoMotor.attach(SERVO_PIN);
}

void servo_camera(bool sleep_mode, int motor_degree){

  unsigned long servo_now = millis(); // 1ms 1씩 증가

  if(servo_now - servo_before > 50){ //0.05초마다 작동

    servo_before = servo_now;

    if((servo_degree > 10) && (sleep_mode == true)){ // 슬립 모드로 진입할 때 카메라 각도 설정
      servo_degree -= 5; // 0.05초마다 5도씩 감소시켜 전환
    }

    if((servo_degree > 140 + motor_degree) && (sleep_mode == false)){ // 노멀 모드일 때 서보 모터의 각도 설정
      servo_degree -= 5; // 0.05초마다 5도씩 증가시켜 전환
    }

    if((servo_degree < 140 + motor_degree) && (sleep_mode == false)){ // 노멀 모드일 때 서보 모터의 각도 설정
      servo_degree += 5; // 0.05초마다 5도씩 증가시켜 전환
    }

    servoMotor.write(servo_degree);
  }
}

  




      
