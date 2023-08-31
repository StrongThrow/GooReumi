#ifndef ESP32_S3_servo_h
#define ESP32_S3_servo_h

void servo_init(unsigned char SERVO_PIN);
void servo_camera(bool sleep_mode, int motor_degree);

#endif
