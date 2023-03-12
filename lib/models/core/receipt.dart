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

  // id is not included because this is used in insert DB calls (id is assigned by the DB)
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
            receipt_id: e['receipt_id']))
        .toList();
  }
}

class Suggestion {
  int id;
  int receipt_id;
  int item_id;
  String word;

  Suggestion(
      {required this.id,
      required this.receipt_id,
      required this.item_id,
      required this.word});

  factory Suggestion.fromJson(Map<String, Object> json) => Suggestion(
        id: int.parse(json['id'].toString()),
        receipt_id: int.parse(json['receipt_id'].toString()),
        item_id: int.parse(json['item_id'].toString()),
        word: json['word'].toString(),
      );

  Map<String, Object> toMap() {
    return {'receipt_id': receipt_id, 'item_id': item_id, 'word': word};
  }

  static List<Suggestion> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map((e) => Suggestion(
            id: e['id'],
            receipt_id: e['receipt_id'],
            item_id: e['item_id'],
            word: e['word']))
        .toList();
  }
}
