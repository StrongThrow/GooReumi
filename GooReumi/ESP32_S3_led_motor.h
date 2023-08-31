#ifndef ESP32_S3_led_motor_h
#define ESP32_S3_led_motor_h

void control_led(bool Human_detect_flag, char LED_PIN);
void control_water_motor_auto(bool planter_water_mode_flag, int water_amount, int soilmoisture, char MOTOR_PIN, int motor_work_time_half, unsigned long water_frequency);
bool control_water_motor_manual(bool planter_water_mode_flag, bool button, char MOTOR_PIN);

#endif
