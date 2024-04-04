import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:smarthomeui/util/constant.dart';

Future<List<dynamic>> fetchData(String url) async {
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'X-AIO-Key': APIConstant.adafruitKey.toString(),
      },
    );
    List<dynamic> data = json.decode(response.body);
    data.sort((a, b) {
      DateTime dateA = DateTime.parse(a['created_at']);
      DateTime dateB = DateTime.parse(b['created_at']);
      return dateB.compareTo(
          dateA); // Change to dateA.compareTo(dateB) for ascending order
    });

    // print(data);
    return data;
  } catch (e) {
    print(e);
    return [];
  }
}

void postData(String url, bool value) async {
  try {
    final response = await http.post(Uri.parse(url), headers: {
      'X-AIO-Key': "aio_ugOo69QCzTivkT2LYYZeRO8pCqlk",
    }, body: {
      "value": '${value == false ? 0 : 1}',
    });
    Map<String, dynamic> data = json.decode(response.body);
    print(data);
  } catch (e) {
    print(e);
  }
}

Future<String> postTextData(String url, String value) async {
  try {
    final param = jsonEncode({"textVoice": value});
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: param,
    );
    Map<String, dynamic> data = json.decode(response.body);
    print("Value in function: " + value);
    print(data);
    return data['Message'];
  } catch (e) {
    print(e);
    return "Error";
  }
}
