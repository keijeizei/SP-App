import 'dart:convert';
import 'package:http/http.dart' as http;

const API_URL = '10.0.2.2:5000';

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

Future<Response> expandItemName(String abbreviation) async {
  final response = await http
      .get(Uri.parse('http://$API_URL/expand/KNN?item=$abbreviation'));
  if (response.statusCode == 200) {
    return Response.fromJson(jsonDecode(response.body));
  } else {
    return const Response(data: [], success: false);
  }
}
