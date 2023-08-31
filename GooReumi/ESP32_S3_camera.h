#ifndef ESP32_S3_camera_h
#define ESP32_S3_camera_h

void set_camera(unsigned char jpeg_quality, const char* websocket_server_host, const uint16_t websocket_server_port);
void send_camera_data();
void reset_wifi(unsigned char wifi_reset_flag);

#endif
