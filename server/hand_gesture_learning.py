import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import joblib
import warnings 
warnings.filterwarnings('ignore')

hand1_df = pd.read_csv('./1hand.csv')
hand1_df['target'] = 1
hand2_df = pd.read_csv('./2hand.csv')
hand2_df['target'] = 2
hand3_df = pd.read_csv('./3hand.csv')
hand3_df['target'] = 3
hand4_df = pd.read_csv('./4hand.csv')
hand4_df['target'] = 4
hand5_df = pd.read_csv('./5hand_v2.csv')
hand5_df['target'] = 5
best_df = pd.read_csv('./best.csv')
best_df['target'] = 6
heart_df = pd.read_csv('./heart.csv')
heart_df['target'] = 7
hand3_v2_df = pd.read_csv('./3hand_v2.csv')
hand3_v2_df['target'] = 8
hand3_v2_df.drop(hand3_v2_df.index[:10], inplace=True)
hand3_v3_df = pd.read_csv('./3hand_v3.csv')
hand3_v3_df['target'] = 9
hand3_v3_df.drop(hand3_v3_df.index[:10], inplace=True)

hand_df = pd.concat([hand1_df, hand2_df, hand3_df, hand4_df, hand5_df, 
                     best_df, heart_df, hand3_v2_df, hand3_v3_df], axis=0)

X_train , X_test , y_train , y_test = train_test_split(hand_df.iloc[:, :-1], hand_df.iloc[:, -1],
                                                       test_size=0.2,  random_state=0)

hand_rf = RandomForestClassifier(n_estimators=1000, random_state=0, max_depth=8, min_samples_leaf=1,
                                 min_samples_split=2)
hand_rf.fit(X_train , y_train)
pred = hand_rf.predict(X_test)
print(set(pred))

hand_df.to_csv('hand.csv', index=False)
joblib.dump(hand_rf, './randomforest_model.pkl')
accuracy = accuracy_score(y_test , pred)
print('랜덤 포레스트 정확도: {0:.4f}'.format(accuracy))