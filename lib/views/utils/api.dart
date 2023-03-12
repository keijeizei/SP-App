import 'dart:convert';
import 'package:http/http.dart' as http;

const API_URL = '10.0.2.2:5000';

Future<bool> checkInternetStatus() async {
  try {
    final url = Uri.https('google.com');
    var response = await http.get(url).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response('Error', 408);
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

class Response {
  final List data;
  final bool success;

  const Response({required this.data, required this.success});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      data: json['data'],
      success: true,
    );
  }
}

Future<Response> expandItemNameAPI(String abbreviation, bool isFast) async {
  bool hasInternet = await checkInternetStatus();
  if (!hasInternet) return const Response(data: [], success: false);

  Uri uri;

  // Fast -> using LSTM (faster but no suggestions)
  if (isFast) {
    uri = Uri.parse('http://$API_URL/expand/LSTM?item=$abbreviation');
  }
  // not fast -> using KNN (slower but has suggestions (and sometimes more accurate))
  else {
    uri = Uri.parse('http://$API_URL/expand/KNN?item=$abbreviation');
  }

  final response = await http.get(uri).timeout(
    const Duration(seconds: 60),
    onTimeout: () {
      return http.Response('Error', 408);
    },
  );

  if (response.statusCode == 200) {
    return Response.fromJson(jsonDecode(response.body));
  } else {
    return const Response(data: [], success: false);
  }
}
