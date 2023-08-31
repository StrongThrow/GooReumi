import math

def hand_data_process(x, y, width, height, length, standard_width, standard_height,
                      hand_data_list_x, hand_data_list_y):
    if x[0] == 0 or x[0] == 1:
        return -1
    else:
        for i in range(21):
            x[i] = x[i] * width
            y[i] = y[i] * height
            
                
        if x[0] != standard_width:
            x_distance = standard_width - x[0]
            for i in range(21):
                x[i] = x[i] + x_distance
                
            
        if y[0] != standard_height:
            y_distance = standard_height - y[0]
            for i in range(21):
                y[i] = y[i] + y_distance
                
            
        if round(math.sqrt((x[5]- x[0]) ** 2  + (y[5] - y[0]) **2), 1) != length:
            times = length / round(math.sqrt((x[5] - x[0]) ** 2 + (y[5] - y[0]) ** 2), 1)
            for i in range(1,21):
                x[i] = x[0] + (x[i] - x[0]) * times
                y[i] = y[0] + (y[i] - y[0]) * times
                    
        for i in range(21):
            hand_data_list_x[i].append(round(x[i], 2))
            hand_data_list_y[i].append(round(y[i], 2))
            
            
        new_hand_data = {
                'hand_data_0_x' : hand_data_list_x[0][-1],
                'hand_data_0_y' : hand_data_list_y[0][-1],
                'hand_data_1_x' : hand_data_list_x[1][-1],
                'hand_data_1_y' : hand_data_list_y[1][-1],
                'hand_data_2_x' : hand_data_list_x[2][-1],
                'hand_data_2_y' : hand_data_list_y[2][-1],
                'hand_data_3_x' : hand_data_list_x[3][-1],
                'hand_data_3_y' : hand_data_list_y[3][-1],
                'hand_data_4_x' : hand_data_list_x[4][-1],
                'hand_data_4_y' : hand_data_list_y[4][-1],
                'hand_data_5_x' : hand_data_list_x[5][-1],
                'hand_data_5_y' : hand_data_list_y[5][-1],
                'hand_data_6_x' : hand_data_list_x[6][-1],
                'hand_data_6_y' : hand_data_list_y[6][-1],
                'hand_data_7_x' : hand_data_list_x[7][-1],
                'hand_data_7_y' : hand_data_list_y[7][-1],
                'hand_data_8_x' : hand_data_list_x[8][-1],
                'hand_data_8_y' : hand_data_list_y[8][-1],
                'hand_data_9_x' : hand_data_list_x[9][-1],
                'hand_data_9_y' : hand_data_list_y[9][-1],
                'hand_data_10_x' : hand_data_list_x[10][-1],
                'hand_data_10_y' : hand_data_list_y[10][-1],
                'hand_data_11_x' : hand_data_list_x[11][-1],
                'hand_data_11_y' : hand_data_list_y[11][-1],
                'hand_data_12_x' : hand_data_list_x[12][-1],
                'hand_data_12_y' : hand_data_list_y[12][-1],
                'hand_data_13_x' : hand_data_list_x[13][-1],
                'hand_data_13_y' : hand_data_list_y[13][-1],
                'hand_data_14_x' : hand_data_list_x[14][-1],
                'hand_data_14_y' : hand_data_list_y[14][-1],
                'hand_data_15_x' : hand_data_list_x[15][-1],
                'hand_data_15_y' : hand_data_list_y[15][-1],
                'hand_data_16_x' : hand_data_list_x[16][-1],
                'hand_data_16_y' : hand_data_list_y[16][-1],
                'hand_data_17_x' : hand_data_list_x[17][-1],
                'hand_data_17_y' : hand_data_list_y[17][-1],
                'hand_data_18_x' : hand_data_list_x[18][-1],
                'hand_data_18_y' : hand_data_list_y[18][-1],
                'hand_data_19_x' : hand_data_list_x[19][-1],
                'hand_data_19_y' : hand_data_list_y[19][-1],
                'hand_data_20_x' : hand_data_list_x[20][-1],
                'hand_data_20_y' : hand_data_list_y[20][-1],
                'target' : 0
        }
        return new_hand_data


if __name__ == '__main__':
    hand_data_process()