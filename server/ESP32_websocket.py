import cv2
import numpy as np
import asyncio
import websockets
import pickle
import time
import mediapipe as mp
import warnings
warnings.filterwarnings('ignore')

mp_face_detection = mp.solutions.face_detection
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

COLOR = (255, 255, 255) # 하얀색
THICKNESS = 3 # 두께

x = [0] * 21
y = [0] * 21
x_temp = [0] * 21
y_temp = [0] * 21
human_list =[]
human=0
hand_list = []
hand=0
def human_state(new_face, new_hand):
    global human
    global hand
    if new_face == 2 and new_hand == 2:
        new_value = 2
    else:
        new_value = 1
    
    if hand != new_hand and new_hand == 1:
        hand = new_hand
        hand_list.append(new_hand)
    elif hand != new_hand and new_hand == 2:
        hand = new_hand
        hand_list.append(new_hand)
    else:
        pass

    if human != new_value and new_value == 1:
        human = new_value
        human_list.append(new_value)        
    elif human != new_value and new_value == 2:
        human = new_value
        human_list.append(new_value)
    else:
        pass
    with open("human_detect.pkl","wb") as file_h, open("hand_detect.pkl","wb") as file_hand:
        pickle.dump(human_list, file_h)
        pickle.dump(hand_list, file_hand)

async def video_stream(websocket, path):
    global x
    global y
    with mp_face_detection.FaceDetection( # 얼굴, 손가락 감지
    model_selection=1, min_detection_confidence=0.7) as face_detection,\
    mp_hands.Hands(
    model_complexity=1,
    max_num_hands=2,
    min_detection_confidence=0.75,
    min_tracking_confidence=0.75) as hands:
        start_time = time.time()   
        while True:           
            frame_data = await websocket.recv()
            np_array = np.frombuffer(frame_data, dtype=np.uint8)
            image = cv2.imdecode(np_array, cv2.IMREAD_COLOR)
            image = cv2.flip(image, 1)
            current_time = time.time()
            if current_time - start_time >= 0.6: # 0.6초마다 프레임을 저장해 외부 스트리밍에 쓰임
                cv2.imwrite('Python/static/img/streaming.jpg', image)
                cv2.imwrite('Python/static/img/image.jpg', image)
                start_time = current_time
            image = cv2.resize(image, (320, 240), interpolation=cv2.INTER_LINEAR)
            image.flags.writeable = False
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            results_face = face_detection.process(image)
            results_hand = hands.process(image)

            image.flags.writeable = True
            image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
            
            if results_face.detections:
                new_face = 1
                for detection in results_face.detections:
                    box = detection.location_data.relative_bounding_box
                    height, width, _ = image.shape # 얼굴 감지를 사각형으로 표현하는 작업
                    xmin = box.xmin * width
                    ymin = box.ymin * height
                    xmax = xmin + box.width * width
                    ymax = ymin + box.height * height
                    cv2.rectangle(image, (int(xmin), int(ymin)), (int(xmax), int(ymax)), COLOR, THICKNESS)
            else: # 얼굴 감지 안 될시
                new_face = 2
            
            if results_hand.multi_hand_landmarks:
                if results_hand.multi_handedness[0].classification[0].score <= 0.75: # 손 감지 정확도가 75% 이하일 시
                    cv2.imshow('ESP32 CAM', image)
                    if cv2.waitKey(1) == ord('q'):
                        break
                    continue
                new_hand = 1               
                for hand_num, hand_landmarks in enumerate(results_hand.multi_hand_landmarks):
                    mp_drawing.draw_landmarks(
                    image,
                    hand_landmarks,
                    mp_hands.HAND_CONNECTIONS,
                    mp_drawing_styles.get_default_hand_landmarks_style(),
                    mp_drawing_styles.get_default_hand_connections_style())
                    x_temp = [0] * 21
                    y_temp = [0] * 21
                    if hand_num == 0: # 한 손만 감지될 때
                        for i in range(21):
                            x[i] = hand_landmarks.landmark[i].x
                            y[i] = hand_landmarks.landmark[i].y
                    else: # 양손 모두 감지될 때
                        for i in range(21):
                            x_temp[i] = hand_landmarks.landmark[i].x
                            y_temp[i] = hand_landmarks.landmark[i].y

                if results_hand.multi_handedness[0].classification[0].label == 'Right':
                    for i in range(21):
                        x[i] = 1 - x[i]    
                else:
                    for i in range(21):
                        x_temp[i] = 1 - x_temp[i]       
                
                with open("hand_x_list.pkl","wb") as file_x,\
                    open("hand_x_temp_list.pkl","wb") as file_x_temp,\
                    open("hand_y_list.pkl", "wb") as file_y,\
                    open("hand_y_temp_list.pkl", "wb") as file_y_temp: # hand landmark 값들을 리스트로 저장해 영상 처리 py로 전달
                    pickle.dump(x, file_x) 
                    pickle.dump(x_temp, file_x_temp)
                    pickle.dump(y, file_y)
                    pickle.dump(y_temp, file_y_temp) 
            else:
                new_hand = 2

            cv2.imshow("ESP32 CAM", image)
            human_state(new_face, new_hand)            

            if cv2.waitKey(1) == ord('q'):
                break

start_server = websockets.serve(video_stream, "0.0.0.0", 'PORT_NUMBER', ping_interval=None)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()

cv2.destroyAllWindows()