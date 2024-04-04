import 'dart:convert';
import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef OnDataReceivedCallback = void Function(String topic, dynamic data);

class MQTTService {
  MQTTService({
    this.host,
    this.port,
    this.topics,
    // this.model,
    this.isMe = false,
  });

  // final MQTTModel? model;

  final String? host;

  final int? port;

  final List<String>? topics;

  late MqttServerClient _client;

  bool isMe;

  OnDataReceivedCallback? onDataReceived;

  void initializeMQTTClient() {
    _client = MqttServerClient("io.adafruit.com", 'flutter_mobile')
      ..port = 1883
      ..logging(on: false)
      ..onDisconnected = onDisConnected
      ..onSubscribed = onSubscribed
      ..keepAlivePeriod = 20
      ..onConnected = onConnected;

    final connMess = MqttConnectMessage()
        .authenticateAs('kd77', 'aio_sfhl12k3LtORyGyX8A8rfUK1PPfz')
        .withWillTopic('willTopic')
        .withWillMessage('willMessage')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('Connecting....');
    _client.connectionMessage = connMess;
  }

  Future connectMQTT() async {
    try {
      await _client.connect();
    } on NoConnectionException catch (e) {
      log(e.toString());
      _client.disconnect();
    }
  }

  void disConnectMQTT() {
    try {
      _client.disconnect();
    } catch (e) {
      log(e.toString());
    }
  }

  dynamic onConnected() {
    log('Connected');
    dynamic data;

    try {
      for (var topic in topics!) {
        _client.subscribe(topic, MqttQos.atLeastOnce);
        _client.updates!.listen(
          (List<MqttReceivedMessage<MqttMessage?>>? t) {
            final recMess = t![0].payload as MqttPublishMessage;
            final message = MqttPublishPayload.bytesToStringAsString(
                recMess.payload.message);

            // log('message id : ${recMess.variableHeader?.messageIdentifier}');
            // log('message : $message');
            // data = json.decode(message);
            // print(data['data_sensor']);

            if (onDataReceived != null) {
              onDataReceived!(t[0].topic, message);
            }
          },
        );
      }

      return data;
    } catch (e) {
      log(e.toString());
      return data;
    }
  }

  void onDisConnected() {
    log('Disconnected');
  }

  void publish(String message, String topic) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    builder.clear();
  }

  void onSubscribed(String topic) {
    log(topic);
  }
}
