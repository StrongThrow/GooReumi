#include <Arduino.h>
#include <Adafruit_SSD1306.h>
#include <splash.h>
#include <SPI.h>
#include <Adafruit_GFX.h>
#include <Wire.h>
#include "image_index.h"
#include <time.h>
#include "ESP32_S3_oled.h"

#define OLED_RESET -1
#define SCREEN_WIDTH 128 // OLED 디스플레이 가로 픽셀 
#define SCREEN_HEIGHT 64 // OLED 디스플레이 세로 픽셀
#define SCREEN_ADDRESS 0x3C /// OLED 디스플레이 I2C 주소
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

unsigned long oled_before_sleep = 0;
unsigned long oled_before_smile = 0;
unsigned long oled_before_hello = 0;
unsigned long oled_before_boring = 0;
unsigned char sleep_count = 0;
unsigned char smile_count = 0;
unsigned char hello_count = 0;
unsigned char boring_count = 0;

void display_sleeping(unsigned int oled_delay_ms){ // 구르미가 슬립 모드일 때의 oled애니메이션
  unsigned long oled_now = millis();

  if(oled_now - oled_before_sleep >= oled_delay_ms){
    sleep_count++;
    oled_before_sleep = oled_now;
  }

  if(sleep_count == 0){
    display.clearDisplay();
    display.drawBitmap(0,0,sleeping0,128,64,WHITE);
    display.display();
  }
  if(sleep_count == 1){
    display.clearDisplay();
    display.drawBitmap(0,0,sleeping1,128,64,WHITE);
    display.display();
  }
  if(sleep_count == 2){
    display.clearDisplay();
    display.drawBitmap(0,0,sleeping2,128,64,WHITE);
    display.display();
  }
  if(sleep_count == 3){
    display.clearDisplay();
    display.drawBitmap(0,0,sleeping3,128,64,WHITE);
    display.display();
  }
  if(sleep_count == 4){
    sleep_count = 0;
  }
}

void clear_display(){ // 디스플레이 클리어
  display.clearDisplay();
  display.display();
}

void display_hello(unsigned int oled_delay_ms){ //사용자가 인사하였을 때 oled 애니메이션 

  unsigned long oled_now_2 = millis();

  if(oled_now_2 - oled_before_hello >= oled_delay_ms){
    hello_count++;
    oled_before_hello = oled_now_2;
  }

  if(hello_count == 0){
    display.clearDisplay();
    display.drawBitmap(0,0,hello_0,128,64,WHITE);
    display.display();
  }
  if(hello_count == 1){
    display.clearDisplay();
    display.drawBitmap(0,0,hello_1,128,64,WHITE);
    display.display();
  }
  if(hello_count == 2){
    hello_count = 0;
  }
}

void display_thumbup(){
  display.clearDisplay();
  display.drawBitmap(0,0,thumbup,128,64,WHITE);
  display.display();
}

void display_heart(){
  display.clearDisplay();
  display.drawBitmap(0,0,heart,128,64,WHITE);
  display.display();
}

void display_boring(unsigned int oled_delay_ms){

  unsigned long oled_now_3 = millis();

  if(oled_now_3 - oled_before_boring >= oled_delay_ms){
    boring_count++;
    oled_before_boring = oled_now_3;
  }

  if(boring_count == 0){
    display.clearDisplay();
    display.drawBitmap(0,0,boring_0,128,64,WHITE);
    display.display();
  }
  if(boring_count == 1){
    display.clearDisplay();
    display.drawBitmap(0,0,boring_1,128,64,WHITE);
    display.display();
  }
  if(boring_count == 2){
    boring_count = 0;
  }
}

void display_smiling(unsigned int oled_delay_ms){

  unsigned long oled_now_1 = millis();

  if(oled_now_1 - oled_before_smile >= oled_delay_ms){
    smile_count++;
    oled_before_smile = oled_now_1;
  }

  if(smile_count == 0){
    display.clearDisplay();
    display.drawBitmap(0,0,smiling0,128,64,WHITE);
    display.display();
  }
  if(smile_count == 1){
    display.clearDisplay();
    display.drawBitmap(0,0,smiling1,128,64,WHITE);
    display.display();
  }
  if(smile_count == 2){
    smile_count = 0;
  }
}

void display_time(){
  struct tm timeinfo;
  if(!getLocalTime(&timeinfo)){
    Serial.println("Failed to obtain time");
    return;
  }
  
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);

  // 첫 번째 줄: TIME
  display.setTextSize(1);
  int textWidth = strlen("Gooreumi") * 6; // 글자 크기 * 글자 개수
  int x = (SCREEN_WIDTH - textWidth) / 2; // 가운데 정렬
  display.setCursor(x, 0);
  display.println("Gooreumi");

  // 두 번째 줄: 날짜
  char dateStr[20];
  strftime(dateStr, sizeof(dateStr), "%Y/%m/%d", &timeinfo);
  display.setTextSize(1);
  int dateWidth = strlen(dateStr) * 6;
  display.setCursor((SCREEN_WIDTH - dateWidth) / 2, 20);
  display.println(dateStr);

  // 세 번째 줄: 시간
  char timeStr[20];
  strftime(timeStr, sizeof(timeStr), "%H:%M", &timeinfo); // 초 제외
  display.setTextSize(1);
  int timeWidth = strlen(timeStr) * 6;
  display.setCursor((SCREEN_WIDTH - timeWidth) / 2, 40);
  display.println(timeStr);
  display.display();
}

void display_dht11(float temp, float humi){
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 10);
  display.println("T:"+(String)temp+"C ");
  display.println("H:"+(String)humi+"% ");
  display.display();
}

void display_sensors(int brightness, int waterlevel, int soilmoisture){
  display.clearDisplay();
  display.setTextSize(2);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0, 10);
  display.println("B:"+(String)brightness);
  display.println("W:"+(String)waterlevel);
  display.println("S:"+(String)soilmoisture);
  display.display();
}



void I2C_init(unsigned char SDA_PIN, unsigned char SCL_PIN){
  Wire.begin(SDA_PIN ,SCL_PIN);
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
  }
  display.clearDisplay();
}

