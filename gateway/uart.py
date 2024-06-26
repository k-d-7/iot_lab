import serial.tools.list_ports


def getPort():
    ports = serial.tools.list_ports.comports()
    N = len(ports)
    commPort = "None"
    for i in range(0, N):
        port = ports[i]
        strPort = str(port)
        if "USB Serial Device" in strPort:
            splitPort = strPort.split(" ")
            commPort = splitPort[0]
    # return commPort
    return "/dev/pts/6"


if getPort() != "None":
    ser = serial.Serial(port=getPort(), baudrate=115200)
    print(ser)


def processData(client, data):
    data = data.replace("!", "")
    data = data.replace("#", "")
    splitData = data.split(":")
    print(splitData)
    if splitData[0] == "T":
        client.publishMessage("kd77/feeds/sensor1", splitData[1])
    elif splitData[0] == "H":
        client.publishMessage("kd77/feeds/sensor3", splitData[1])
    elif splitData[0] == "L":
        client.publishMessage("kd77/feeds/sensor2", splitData[1])


mess = ""


def readSerial(client):
    bytesToRead = ser.inWaiting()
    if bytesToRead > 0:
        global mess
        mess = mess + ser.read(bytesToRead).decode("UTF-8")
        print(mess)
        while ("#" in mess) and ("!" in mess):
            start = mess.find("!")
            end = mess.find("#")
            processData(client, mess[start : end + 1])
            if end == len(mess):
                mess = ""
            else:
                mess = mess[end + 1 :]


def writeSerial(data):
    ser.write(str(data).encode())
