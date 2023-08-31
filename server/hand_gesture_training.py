# Jupyter Notebook으로 실행한 코드
# 학습 데이터 저장 코드
import cv2
import math
import mediapipe as mp
import pandas as pd

mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

hand_data_list_x = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
hand_data_list_y = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
x=[0] * 21 
y=[0] * 21

df = pd.DataFrame(data=None, 
                  columns=['hand_data_0_x', 'hand_data_0_y', 'hand_data_1_x', 'hand_data_1_y', 'hand_data_2_x', 'hand_data_2_y',
                           'hand_data_3_x', 'hand_data_3_y', 'hand_data_4_x', 'hand_data_4_y', 'hand_data_5_x', 'hand_data_5_y',
                           'hand_data_6_x', 'hand_data_6_y', 'hand_data_7_x', 'hand_data_7_y', 'hand_data_8_x', 'hand_data_8_y',
                           'hand_data_9_x', 'hand_data_9_y', 'hand_data_10_x', 'hand_data_10_y', 'hand_data_11_x', 'hand_data_11_y',
                           'hand_data_12_x', 'hand_data_12_y', 'hand_data_13_x', 'hand_data_13_y', 'hand_data_14_x', 'hand_data_14_y',
                           'hand_data_15_x', 'hand_data_15_y', 'hand_data_16_x', 'hand_data_16_y', 'hand_data_17_x', 'hand_data_17_y',
                           'hand_data_18_x', 'hand_data_18_y', 'hand_data_19_x', 'hand_data_19_y', 'hand_data_20_x', 'hand_data_20_y'])

COLOR = (255, 255, 255) # 하얀색
RADIUS = 5 # 반지름
THICKNESS = 5 # 두께

# For webcam input:
cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 320)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 240)
width = 320
height = 240
standard_width = width // 2
standard_height = height // 1.5
length = 87  # 표준 길이를 87로 지정

with mp_hands.Hands(
    model_complexity=1,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7) as hands:
    while cap.isOpened():
        success, image = cap.read()
        
        if not success:
            continue

        image.flags.writeable = False
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(image)

        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        
        if results.multi_hand_landmarks:

            for hand_num, hand_landmarks in enumerate(results.multi_hand_landmarks):
                height, width, _ = image.shape
                mp_drawing.draw_landmarks(
                image,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS,
                mp_drawing_styles.get_default_hand_landmarks_style(),
                mp_drawing_styles.get_default_hand_connections_style())
                if hand_num == 0:
                    for i in range(21):
                        x[i] = hand_landmarks.landmark[i].x * width
                        y[i] = hand_landmarks.landmark[i].y * height
                else:
                    pass
            
            if results.multi_handedness[0].classification[0].label == 'Right':
                for i in range(21):
                    x[i] = 1 - x[i]
                    
            if x[0] != standard_width:
                x_distance = standard_width - x[0]
                for i in range(21):
                    x[i] = x[i] + x_distance


            if y[0] != standard_height:
                y_distance = standard_height - y[0]
                for i in range(21):
                    y[i] = y[i] + y_distance


            if round(math.sqrt((x[5]- x[0]) ** 2 
                               + (y[5] - y[0]) **2), 1) != length:
                times = length / round(math.sqrt((x[5] - x[0]) ** 2
                                + (y[5] - y[0]) ** 2), 1)
                for i in range(1,21):
                    x[i] = x[0] + (x[i] -  x[0]) * times
                    y[i] = y[0] + (y[i] -  y[0]) * times

            for i in range(21):
                cv2.circle(image, (int(x[i]), int(y[i])), RADIUS, COLOR, cv2.FILLED, cv2.LINE_AA)

            for i in range(21):
                hand_data_list_x[i].append(round(x[i], 2))
                hand_data_list_y[i].append(round(y[i], 2))
        
                
        cv2.imshow('MediaPipe Hands', cv2.flip(image, 1))
        if cv2.waitKey(1) == ord('q'):
            break

df['hand_data_0_x'] = hand_data_list_x[0]
df['hand_data_0_y'] = hand_data_list_y[0]
df['hand_data_1_x'] = hand_data_list_x[1]
df['hand_data_1_y'] = hand_data_list_y[1]
df['hand_data_2_x'] = hand_data_list_x[2]
df['hand_data_2_y'] = hand_data_list_y[2]
df['hand_data_3_x'] = hand_data_list_x[3]
df['hand_data_3_y'] = hand_data_list_y[3]
df['hand_data_4_x'] = hand_data_list_x[4]
df['hand_data_4_y'] = hand_data_list_y[4]
df['hand_data_5_x'] = hand_data_list_x[5]
df['hand_data_5_y'] = hand_data_list_y[5]
df['hand_data_6_x'] = hand_data_list_x[6]
df['hand_data_6_y'] = hand_data_list_y[6]
df['hand_data_7_x'] = hand_data_list_x[7]
df['hand_data_7_y'] = hand_data_list_y[7]
df['hand_data_8_x'] = hand_data_list_x[8]
df['hand_data_8_y'] = hand_data_list_y[8]
df['hand_data_9_x'] = hand_data_list_x[9]
df['hand_data_9_y'] = hand_data_list_y[9]
df['hand_data_10_x'] = hand_data_list_x[10]
df['hand_data_10_y'] = hand_data_list_y[10]
df['hand_data_11_x'] = hand_data_list_x[11]
df['hand_data_11_y'] = hand_data_list_y[11]
df['hand_data_12_x'] = hand_data_list_x[12]
df['hand_data_12_y'] = hand_data_list_y[12]
df['hand_data_13_x'] = hand_data_list_x[13]
df['hand_data_13_y'] = hand_data_list_y[13]
df['hand_data_14_x'] = hand_data_list_x[14]
df['hand_data_14_y'] = hand_data_list_y[14]
df['hand_data_15_x'] = hand_data_list_x[15]
df['hand_data_15_y'] = hand_data_list_y[15]
df['hand_data_16_x'] = hand_data_list_x[16]
df['hand_data_16_y'] = hand_data_list_y[16]
df['hand_data_17_x'] = hand_data_list_x[17]
df['hand_data_17_y'] = hand_data_list_y[17]
df['hand_data_18_x'] = hand_data_list_x[18]
df['hand_data_18_y'] = hand_data_list_y[18]
df['hand_data_19_x'] = hand_data_list_x[19]
df['hand_data_19_y'] = hand_data_list_y[19]
df['hand_data_20_x'] = hand_data_list_x[20]
df['hand_data_20_y'] = hand_data_list_y[20]


#df.to_csv('1hand.csv', index=False)
#df.to_csv('2hand.csv', index=False)
#df.to_csv('3hand.csv', index=False)
#df.to_csv('3hand_v2.csv', index=False)
#df.to_csv('3hand_v3.csv', index=False)
#df.to_csv('4hand.csv', index=False)
#df.to_csv('5hand_v2.csv', index=False)
#df.to_csv('best.csv', index=False)
#df.to_csv('heart.csv', index=False)

cap.release()
cv2.destroyAllWindows()