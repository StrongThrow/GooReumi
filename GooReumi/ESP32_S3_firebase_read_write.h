#ifndef ESP32_S3_firebase_read_write_h
#define ESP32_S3_firebase_read_write_h

void set_wifi();
void set_firebase(String API_KEY, String DATABASE_URL);
int write_firebase_int(String path, unsigned char PIN);
void write_firebase_float(String path, float value);
int read_firebase_value(String path);
void ntpTime_init();
bool read_firebase_bool(String path);
void write_firebase_bool(String path, bool value);

#endif
