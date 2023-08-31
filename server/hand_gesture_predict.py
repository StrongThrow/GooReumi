import pickle
import firebase_admin
import pandas as pd
import numpy as np
import time
import joblib
from firebase_admin import credentials
from firebase_admin import db
import Python.hand_gesture_processing as hand_gesture_processing
import warnings
warnings.filterwarnings('ignore')

cred = credentials.Certificate("firebaseKey.json")
firebase_admin.initialize_app(cred,{
    'databaseURL' : 'firebase URL'
})
dir = db.reference('/Machine_Learning') #path
ref = db.reference('Smart_Plnater_settings/Sleep_Mode')

hand_data_list_x = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
hand_data_list_y = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []]
width = 320
height = 240
standard_width = width // 2
standard_height = height // 1.5
length = 87  # 표준 길이를 87로 지정

hand_rf = joblib.load('./randomforest_model.pkl')
hand_df = pd.read_csv('./hand.csv')

human=0
start_time = time.time()
current_time = time.time()
def human_change(new_value, dir):
    global start_time
    global current_time
    global human
    if human != new_value and new_value == 1:
        human = new_value
        dir.update({'Human_detect': True})
        dir.update({'Human_not_detect': False})
    elif human != new_value and new_value == 2:
        human = new_value
        dir.update({'Human_detect': False})
    else:
       pass

    if human == 1:
        start_time = time.time()
    elif human == 2:
        current_time = time.time()
     

    if current_time - start_time > 10:
        dir.update({'Human_not_detect' : True})
        start_time = current_time       

hand = 0
heart = 0
best = 0

def hand_change(new_value, dir):
    global hand
    global heart
    global best
    if hand != new_value and new_value == 1:
        hand = new_value
        dir.update({'Hand_gesture': new_value})
    elif hand != new_value and new_value == 2:
        hand = new_value
        dir.update({'Hand_gesture': new_value})
    elif hand != new_value and new_value == 3:
        hand = new_value
        dir.update({'Hand_gesture': new_value})
    elif hand != new_value and new_value == 4:
        hand = new_value
        dir.update({'Hand_gesture': new_value})
    elif hand != new_value and new_value == 5:
        hand = new_value
        dir.update({'Hand_gesture': new_value})
    elif hand != new_value and new_value == 6:
        hand = new_value
        best += 1
        dir.update({'Hand_gesture': new_value})
        dir.update({'Best': best})
    elif hand != new_value and new_value == 7:
        hand = new_value
        heart += 1
        dir.update({'Hand_gesture': new_value})
        dir.update({'Heart': heart})
    elif hand != new_value and new_value == 0:
        hand = new_value
    else:
        pass


hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
def hand_sum(new_value):
    global hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9
    if new_value == 0:
        hand0 += 1
    elif new_value == 1:
        hand1 += 1
    elif new_value == 2:
        hand2 += 1
    elif new_value == 3:
        hand3 += 1
    elif new_value == 4:
       hand4 += 1
    elif new_value == 5:
        hand5 += 1
    elif new_value == 6:
        hand6 += 1
    elif new_value == 7:
        hand7 += 1
    elif new_value == 8:
        hand8 += 1
    elif new_value == 9:
        hand9 += 1
    else:
        pass

hand_detect=0
hand_start_time = time.time()
hand_current_time = time.time()
def hand_detect(new_value, dir):
    global hand_detect
    global hand_start_time
    global hand_current_time
    if new_value == 1:
        hand_start_time = time.time()
    elif new_value == 2:
        hand_current_time = time.time()
        
    else:
        pass

    if hand_current_time - hand_start_time > 2:
        dir.update({'Hand_gesture': 0})
        hand_change(0, dir)
        hand_start_time = hand_current_time  

global gesture
gesture = 0
global count
count = 0

global sum_start_time
global sum_current_time
sum_start_time = time.time()
sum_current_time = time.time()
while True:
    with open('human_detect.pkl', 'rb') as file_h, open("hand_x_list.pkl","rb") as file_x,\
        open("hand_x_temp_list.pkl","rb") as file_x_temp, open('hand_y_list.pkl', 'rb') as file_y,\
        open("hand_y_temp_list.pkl", "rb") as file_y_temp, open("hand_detect.pkl","rb") as file_hand:
        try:
            if ref.get() == False:   # 슬립모드가 아닐 시
                count = 0                 
                human_list = pickle.load(file_h)
                human_change(human_list[-1], dir)
                hand_list = pickle.load(file_hand)
                hand_detect(hand_list[-1], dir)
                

                x = pickle.load(file_x)
                x_temp = pickle.load(file_x_temp)
                y = pickle.load(file_y)
                y_temp = pickle.load(file_y_temp)

                if gesture != x[0]: 
                    gesture = x[0]
                else: # 손목의 landmark 값이 이전 프레임과 똑같을 때(손 감지가 안 될 때)
                    time.sleep(2)
                    continue

                new_hand_data = hand_gesture_processing.hand_data_process(x, y, width, height, length, 
                                    standard_width, standard_height, hand_data_list_x, hand_data_list_y)
                new_hand_data_temp = hand_gesture_processing.hand_data_process(x_temp, y_temp, width, height, length, 
                                    standard_width, standard_height, hand_data_list_x, hand_data_list_y)
                if new_hand_data_temp == -1: # 한 손만 감지될 때
                    hand_df = hand_df.append(new_hand_data, ignore_index=True)
                    X_features_web = np.array(hand_df.iloc[-1, :-1]).reshape(1, -1)
                    predict = hand_rf.predict(X_features_web)
                    proba = hand_rf.predict_proba(X_features_web)

                else: # 양손 모두 감지될 때
                    hand_df = hand_df.append(new_hand_data, ignore_index=True)
                    hand_df = hand_df.append(new_hand_data_temp, ignore_index=True)
                    X_features_web = np.array(hand_df.iloc[-2:, :-1])
                    predict = hand_rf.predict(X_features_web)
                    proba = hand_rf.predict_proba(X_features_web)

                    if max(proba[1]) > max(proba[0]): # 두 손 중 정확도가 높은 hand gesture만 인식
                        proba[0][int(predict[1]) - 1] = max(proba[1])
                        predict[0] = predict[1]

                if max(proba[0]) < 0.6: # 제스쳐 정확도가 60% 미만일 때
                    hand_df.drop(len(hand_df) - 1, axis=0, inplace=True) # 데이터프레임에서 해당 데이터셋 삭제
                    print('감지X', end=' ')
                    hand_state = 0
                else:
                    if int(predict[0]) == 1:
                        print('손가락 1개', end=' ')
                        hand_state = 1
                    elif int(predict[0]) == 2:
                        print('손가락 2개', end=' ')
                        hand_state = 2
                    elif int(predict[0]) == 3:
                        print('손가락 3개', end=' ')
                        hand_state = 3
                    elif int(predict[0]) == 4:
                        print('손가락 4개', end=' ')
                        hand_state = 4
                    elif int(predict[0]) == 5:
                        print('손가락 5개', end=' ')
                        hand_state = 5
                    elif int(predict[0]) == 6:
                        print('엄지척', end=' ')
                        hand_state = 6
                    elif int(predict[0]) == 7:
                        print('손하트', end=' ')
                        hand_state = 7
                    elif int(predict[0]) == 8:
                        print('손가락 3개', end=' ')
                        hand_state = 8
                    elif int(predict[0]) == 9:
                        print('손가락 3개', end=' ')
                        hand_state = 9
                    hand_df.iloc[-1, -1] = int(predict[0])
                
                print(round(max[proba[0]] * 100, 2), '%')
                hand_sum(hand_state)
                sum_current_time = time.time()

                if sum_current_time - sum_start_time > 2: # 2초 동안 인식된 각각의 gestur 횟수를 비교해 가장 많이 인식된 gesture를 선택
                    if hand0==hand1==hand2==hand3==hand4==hand5==hand6==hand7==hand8==hand9:
                        pass
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand0:
                        hand_change(0, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand1:
                        hand_change(1, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand2:
                        hand_change(2, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand3:
                        hand_change(3, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand4:
                        hand_change(4, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand5:
                        hand_change(5, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand6:
                        hand_change(6, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand7:
                        hand_change(7, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand8:
                        hand_change(3, dir)
                    elif max(hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9) == hand9:
                        hand_change(3, dir)
                    sum_start_time = sum_current_time
                    hand0, hand1, hand2, hand3, hand4, hand5, hand6, hand7, hand8, hand9 = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                
            else:   # 슬립모드일 시
                if count == 0: # 무한 반복을 방지
                    print('학습중...')
                    hand_rf.fit(hand_df.iloc[:, :-1] , hand_df.iloc[:, -1])
                    print('학습 완료')
                    count += 1
                else:
                    pass
        except (EOFError, pickle.UnpicklingError):
            pass       