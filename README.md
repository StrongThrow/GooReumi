# 🌱 GooReumi: ESP32-S3 기반 스마트 IoT 화분 시스템

ESP32-S3, Firebase, Python 서버, Flutter 앱을 통합하여 제작한 **스마트 화분 시스템**입니다.  
센서 데이터를 기반으로 자동 급수 및 실시간 모니터링 기능을 제공하며,  
카메라 및 웹캠 제스처 인식을 통해 사용자와 상호작용하는 **IoT 제품**입니다.

---

## 🎥 시연 영상

[🔗 유튜브 시연 영상 보러가기](https://youtu.be/SMD-Z0I87Jk)

---

## 🧠 시스템 개요

```
[사용자 손동작] → [Python 서버 (MediaPipe)] → WebSocket
                                ↓
                        [ESP32-S3 MCU]
        ├─ 센서 수집 (토양 수분, 조도, 수위)
        ├─ OLED 실시간 표시
        ├─ 물 펌프 제어 (수동/자동)
        ├─ CAM 스트리밍 (app_httpd)
        └─ Firebase 연동
                                ↓
                   [Flutter 앱: Firebase 모니터링]
```

---

## 📦 주요 기능

- ✅ **토양 수분, 조도, 수위 센서 측정**
- ✅ **Firebase와 실시간 데이터 송수신**
- ✅ **물 펌프 수동/자동 제어 기능**
- ✅ **OLED에 상태 실시간 출력**
- ✅ **ESP32-S3 CAM 스트리밍 + 웹서버**
- ✅ **MediaPipe 제스처 인식으로 손동작 명령 수신**
- ✅ **Flutter 기반 반응형 앱 UI (iOS, Android, Web)**

---

## 📁 디렉토리 구조

```
📁 GooReumi/
 ├── ESP32_S3_camera.{cpp,h}
 ├── ESP32_S3_firebase_read_write.{cpp,h}
 ├── ESP32_S3_led_motor.{cpp,h}
 ├── ESP32_S3_oled.{cpp,h}
 ├── ESP32_S3_servo.{cpp,h}
 ├── GooReumi.ino                 ← main
 ├── app_httpd.cpp                ← 영상 스트리밍 서버
 ├── camera_index.h, pins.h       ← CAM 핀 및 스트리밍 페이지
 └── image_index.h
📁 server/
 ├── hand_gesture_*.py            ← 제스처 학습/추론/처리
 ├── ESP32_websocket.py           ← ESP32와 통신
 ├── streaming_server.py, index.html
📁 app/embedded/
 ├── Flutter 앱 소스코드 전체 (Android/iOS/Web 대응)
```

---

## 🛠 사용 기술

| 분류     | 기술 |
|----------|------|
| MCU      | ESP32-S3, Arduino Framework |
| 센서     | 토양수분, 조도, 수위 |
| 액츄에이터 | 서보모터, 펌프 (PWM 제어) |
| 통신     | Wi-Fi, WebSocket, Firebase |
| 시각화   | OLED, Flutter 앱 |
| 서버     | Python, MediaPipe, Flask, OpenCV |
| 영상     | ESP32 CAM + app_httpd |
| 앱       | Flutter (Android/iOS/Web), Firebase Realtime DB |
| 디자인   | Fusion 360 기반 3D 모델링 |

---

## 🏆 수상

- **2024 ICT 융합 프로젝트 공모전 장려상 수상**
- 
![상장](https://github.com/user-attachments/assets/20961ce1-dfa6-4a7e-aeb2-d9bb763fa953)

---

## 👤 팀원 및 역할

| 프로필 | 역할  | 담당 부분 | 기술 스택 |
|--------|-------|----------|-----------|
| ![강송구](https://github.com/user-attachments/assets/986e1819-2d0d-4715-97ce-590ea6495421) <br> [강송구](https://github.com/Throwball99) | 팀장  | HW, SW 개발 | Arduino, Fusion 360, Firebase |
| ![박정욱](https://github.com/Throwball99/2023ESWContest_free_1042/assets/143514249/c9eadced-f7e2-419b-a819-1612bf5ea15a) <br> [박정욱](https://github.com/wjddnr0920) | 팀원  | SW, 서버 개발 | Python, OpenCV, MediaPipe, Flask, Firebase |
| ![최지민](https://github.com/Throwball99/2023ESWContest_free_1042/assets/143514249/69319bbd-74bb-40c1-92d8-ae96e23b3500) <br> [최지민](https://github.com/irmu98) | 팀원  | SW, UI 개발 | Flutter, Android, Firebase |

---

## 🧾 회로도

- **도어락 회로도**  
  ![도어락 회로도](https://github.com/user-attachments/assets/ece91a11-e34d-447f-a80c-1111ed658291)

- **제어부 회로도**  
  ![제어부 회로도](https://github.com/user-attachments/assets/832fc948-5dd8-47a6-b7ee-9e728564179a)

---

## 📌 요약

> 본 프로젝트는 단순한 스마트 화분을 넘어서  
> **제스처 기반 인터랙션 + 앱 연동 + 클라우드 + 시각화 + 펌웨어 통합**까지 아우르는  
> **완성형 IoT 시스템 플랫폼**으로,  
> 사용자의 감성적 피드백과 실제 환경 제어가 자연스럽게 연결되도록 설계되었습니다.
