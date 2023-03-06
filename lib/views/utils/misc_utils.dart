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
