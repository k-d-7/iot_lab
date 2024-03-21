import time
from mqtt import MQTTClient
import os
from dotenv import load_dotenv
from simpleAI import *
from uart import *

load_dotenv()
MQTT_SERVER = os.getenv("MQTT_SERVER")
MQTT_PORT = os.getenv("MQTT_PORT")
print(MQTT_PORT)

MQTT_USERNAME = os.getenv("MQTT_USERNAME")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD")
TOPICS = [
    "kd77/feeds/button1",
    "kd77/feeds/button2",
    "kd77/feeds/sensor1",
    "kd77/feeds/sensor2",
    "kd77/feeds/sensor3",
]


# def test(payload):
#     print("test: " + payload)


mqttClient = MQTTClient(MQTT_SERVER, MQTT_PORT, TOPICS, MQTT_USERNAME, MQTT_PASSWORD)
mqttClient.setRecvCallBack(writeSerial)
mqttClient.connect()

# counter_ai = 5
while True:
    # counter_ai -= 1
    # if counter_ai <= 0:
    #     result, confidence_score = imageDetector()
    #     if result is not None and confidence_score is not None:
    #         msg = result + " " +  str(np.round(confidence_score * 100))[:-2]
    #         mqttClient.publishMessage("kd77/feeds/ai", msg)
    #     counter_ai = 5


    readSerial(mqttClient)
    time.sleep(1)
