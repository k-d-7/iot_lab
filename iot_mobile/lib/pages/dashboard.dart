import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:smarthomeui/mqtt/mqtt_service.dart';
import 'package:smarthomeui/util/smart_device_box.dart';

//Create a shader linear gradient
final Shader linearGradient = const LinearGradient(
  colors: <Color>[
    Color.fromARGB(255, 227, 241, 255),
    Color.fromARGB(255, 225, 236, 252)
  ],
).createShader(const Rect.fromLTWH(255.0, 255.0, 255.0, 255.0));

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // padding constants
  final double horizontalPadding = 40;
  final double verticalPadding = 25;

  bool isLoading = false;
  bool isLoadingTemp = true;
  bool isLoadingLight = true;
  bool isLoadingHumid = true;

  MQTTService? mqttService;

  // list of smart devices
  List mySmartDevices = [
    ["LED", "lib/icons/light-bulb.png", false],
    ["PUMP", "lib/icons/fan.png", false]
  ];

  dynamic receiveTempData;
  dynamic receiveLightData;
  dynamic receiveHumidData;

  // power button switched
  void powerSwitchChanged(bool value, int index) {
    // final _service = MQTTService(
    //   topics: "/innovation/airmonitoring/smarthome/fan",
    // );
    // _service.initializeMQTTClient();
    // _service.connectMQTT();

    setState(() {
      try {
        if (index == 0) {
          // _service.publish(jsonEncode(dataLight));
          mqttService?.publish(
            value ? "1" : "0",
            "kd77/feeds/button1",
          );
        } else if (index == 1) {
          // _service.publish(jsonEncode(dataFan));
          mqttService?.publish(
            value ? "1" : "0",
            "kd77/feeds/button2",
          );
        }
        mySmartDevices[index][2] = value;
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initValueSensor();
  }

  void initValueSensor() {
    mqttService = MQTTService(
      topics: [
        "kd77/feeds/button1",
        "kd77/feeds/button2",
        "kd77/feeds/sensor1",
        "kd77/feeds/sensor2",
        "kd77/feeds/sensor3",
      ],
    );
    mqttService?.initializeMQTTClient();
    mqttService?.connectMQTT();
    mqttService?.onDataReceived = onDataReceived;
  }

  // Callback function to handle received data
  void onDataReceived(String topic, dynamic data) {
    print("Topic received: $topic");
    print("Received data: $data");
    setState(() {
      if (topic == "kd77/feeds/button1") {
        mySmartDevices[0][2] = data;
      } else if (topic == "kd77/feeds/button2") {
        mySmartDevices[1][2] = data;
      } else if (topic == "kd77/feeds/sensor1") {
        receiveTempData = data;
        isLoadingTemp = false;
      } else if (topic == "kd77/feeds/sensor2") {
        receiveLightData = data;
        isLoadingLight = false;
      } else if (topic == "kd77/feeds/sensor3") {
        receiveHumidData = data;
        isLoadingHumid = false;
      }
    });
  }

  void onDataLightReceived(Map<String, dynamic> data) {
    print("Received data in Light: $data");
    setState(() {
      mySmartDevices[0][2] = data['data_device']['status'];
      isLoadingLight = false;
    });
  }

  void onDataFanReceived(Map<String, dynamic> data) {
    print("Received data in Fan: $data");
    setState(() {
      mySmartDevices[1][2] = data['data_device']['status'];
      isLoadingLight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[300],
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome!",
                      style: TextStyle(
                        fontSize: 26.sp,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Divider(
                  thickness: 1,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),

                const SizedBox(height: 25),

                // general information
                Text(
                  "Sensors",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Colors.grey.shade800,
                  ),
                ),

                // const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // isLoadingLight
                      //     ? Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(20),
                      //           ),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color: Colors.grey
                      //                   .withOpacity(0.2), //color of shadow
                      //               spreadRadius: 4, //spread radius
                      //               blurRadius: 4, // blur radius
                      //               offset: const Offset(
                      //                 0,
                      //                 2,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         height: 100.r,
                      //         child: const Center(
                      //           child: SizedBox(
                      //             height: 30,
                      //             child: LoadingIndicator(
                      //                 indicatorType:
                      //                     Indicator.ballSpinFadeLoader,
                      //                 colors: [Colors.blueAccent],
                      //                 strokeWidth: 2,
                      //                 backgroundColor: Colors.white,
                      //                 pathBackgroundColor: Colors.white),
                      //           ),
                      //         ),
                      //       )
                      //     : MyCard(
                      //         title: receiveSensorData['data_sensor'] != null
                      //             ? receiveSensorData['data_sensor'][0]
                      //                 ['sensor_key']
                      //             : "",
                      //         icon: Icon(
                      //           size: 28.r,
                      //           FontAwesomeIcons.temperatureHalf,
                      //           color: Colors.blueAccent,
                      //         ),
                      //         value: Text(
                      //           receiveSensorData['data_sensor'] != null
                      //               ? "${receiveSensorData['data_sensor'][0]['sensor_value'].toString()} °C"
                      //               : "0 °C",
                      //           style: TextStyle(
                      //             fontSize: 30.sp,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.blueAccent,
                      //           ),
                      //         ),
                      //       ),
                      MyCard(
                        title: "Temperature",
                        icon: Icon(
                          size: 28.r,
                          FontAwesomeIcons.temperatureHalf,
                          color: Colors.blueAccent,
                        ),
                        value: Text(
                          isLoadingTemp ? "" : "${receiveTempData} °C",
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      MyCard(
                        title: "Light",
                        icon: Icon(
                          size: 28.r,
                          FontAwesomeIcons.boltLightning,
                          color: Colors.blueAccent,
                        ),
                        value: Text(
                          isLoadingLight ? "" : "${receiveLightData} cd",
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      MyCard(
                        title: "Humidity",
                        icon: Icon(
                          size: 28.r,
                          FontAwesomeIcons.water,
                          color: Colors.blueAccent,
                        ),
                        value: Text(
                          isLoadingHumid ? "" : "${receiveHumidData} %",
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  thickness: 1,
                  color: Color.fromARGB(255, 204, 204, 204),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Devices",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      child: isLoading
                          ? const LoadingIndicator(
                              indicatorType: Indicator.lineScale,
                              colors: [Colors.blueAccent],
                              strokeWidth: 2,
                              backgroundColor: Colors.white,
                              pathBackgroundColor: Colors.white,
                            )
                          : Container(),
                    )
                  ],
                ),
                const SizedBox(height: 10),

                // grid
                isLoading
                    ? Container()
                    : GridView.builder(
                        itemCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // padding: const EdgeInsets.symmetric(horizontal: 25),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1 / 1.2,
                        ),
                        itemBuilder: (context, index) {
                          return SmartDeviceBox(
                            smartDeviceName: mySmartDevices[index][0],
                            iconPath: mySmartDevices[index][1],
                            powerOn:
                                mySmartDevices[index][2] == "1" ? true : false,
                            onChanged: (value) =>
                                powerSwitchChanged(value, index),
                          );
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCard extends StatefulWidget {
  const MyCard(
      {super.key,
      required this.title,
      required this.icon,
      required this.value});

  final String title;
  final Icon icon;
  final Text value;

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), //color of shadow
            spreadRadius: 4, //spread radius
            blurRadius: 4, // blur radius
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0).r,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(44, 164, 167, 189),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(5.0).r,
                        child: Icon(
                          FontAwesomeIcons.airbnb,
                          size: 20.r,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.title.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.sp,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.cloud,
                  color: Colors.blueAccent,
                  size: 28.r,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    widget.icon,
                    const SizedBox(
                      width: 20,
                    ),
                    widget.value,
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Detail",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
