#ifndef ESP32_S3_oled_h
#define ESP32_S3_oled_h

void display_sleeping(unsigned int oled_delay_ms);
void display_smiling(unsigned int oled_delay_ms);
void display_time();
void I2C_init(unsigned char SDA_PIN, unsigned char SCL_PIN);
void display_dht11(float temp, float humi);
void display_sensors(int brighness, int waterlevel, int soilmoisture);
void clear_display();
void display_hello(unsigned int oled_delay_ms);
void display_heart();
void display_thumbup();
void display_boring(unsigned int oled_delay_ms);

#endif
