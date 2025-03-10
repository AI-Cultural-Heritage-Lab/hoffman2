from flask import Flask
import datetime

app = Flask(__name__)

@app.route('/hello')
def hello():
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return "Hi from test server! Current time: {}".format(current_time), 200

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
