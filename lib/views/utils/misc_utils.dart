import 'package:url_launcher/url_launcher.dart';

bool isNumeric(String str) {
  return double.tryParse(str) != null;
}

String? validateText(value) {
  if (value == null || value.isEmpty) {
    return 'This field cannot be empty';
  }
  return null;
}

String? validatePrice(value) {
  if (value == null || value.isEmpty) {
    return 'This field cannot be empty';
  }
  if (!isNumeric(value)) {
    return 'Enter a valid price';
  }
  return null;
}

launchURL(url) async {
  if (await canLaunchUrl(Uri.parse(Uri.encodeFull(url)))) {
    await launchUrl(Uri.parse(Uri.encodeFull(url)));
  } else {
    throw 'Could not launch $url';
  }
}

List<List<String>> rotateSuggestions(List<dynamic> suggestions) {
  // rotate a KNN response.data (word: i: suggestion: j) to a suggestionsTable (suggestion: i, word: j)
  List<List<String>> table = [];
  for (int i = 0; i < 5; i++) {
    List<String> row = [];
    for (int j = 0; j < suggestions.length; j++) {
      if (suggestions[j].length > i) {
        row.add(suggestions[j][i]);
      }
    }
    table.add(row);
  }
  return table;
}
