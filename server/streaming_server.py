from flask import Flask, render_template, Response
import cv2
import time
app = Flask(__name__)

def generate_frames():
    while True:
        try:
            frame = cv2.imread('Python/static/img/streaming.jpg')
            frame = cv2.resize(frame, (320, 240), interpolation=cv2.INTER_LINEAR) 
            _, frame = cv2.imencode('.jpg', frame)
            frame = frame.tobytes()
            yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')  # 프레임을 바이트 스트림으로 전송
            before_frame = frame
            time.sleep(0.6)
        except cv2.error:             
            yield (b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + before_frame + b'\r\n')
            pass

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__' :
    app.run(host = '0.0.0.0', port = 'PORT_NUMBER', debug=True)