class Receipt {
  int id;
  String title;
  String photo;
  int date;
  double price;

  Receipt(
      {required this.id,
      required this.title,
      required this.photo,
      required this.date,
      required this.price});

  factory Receipt.fromJson(Map<String, Object> json) {
    return Receipt(
      id: int.parse(json['id'].toString()),
      title: json['title'].toString(),
      photo: json['photo'].toString(),
      date: int.parse(json['date'].toString()),
      price: double.parse(json['price'].toString()),
    );
  }

  // TODO: id is not included here, check if it is needed
  Map<String, dynamic> toMap() {
    return {'title': title, 'photo': photo, 'date': date, 'price': price};
  }
}

class Item {
  int id;
  String name;
  String abbreviation;
  double price;
  int receipt_id;

  Item(
      {required this.id,
      required this.name,
      required this.abbreviation,
      required this.price,
      required this.receipt_id});

  factory Item.fromJson(Map<String, Object> json) => Item(
        id: int.parse(json['id'].toString()),
        name: json['name'].toString(),
        abbreviation: json['abbreviation'].toString(),
        price: double.parse(json['price'].toString()),
        receipt_id: int.parse(json['receipt_id'].toString()),
      );

  Map<String, Object> toMap() {
    return {
      'name': name,
      'abbreviation': abbreviation,
      'price': price,
      'receipt_id': receipt_id
    };
  }

  static List<Item> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map((e) => Item(
            id: e['id'],
            name: e['name'],
            abbreviation: e['abbreviation'],
            price: e['price'],
            receipt_id: e.receipt_id))
        .toList();
  }
}
