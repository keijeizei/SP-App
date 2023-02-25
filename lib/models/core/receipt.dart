class Receipt {
  String title;
  String photo;
  int date;
  double price;

  List<Item> items;

  Receipt(
      {required this.title,
      required this.photo,
      required this.date,
      required this.price,
      required this.items});

  factory Receipt.fromJson(Map<String, Object> json) {
    return Receipt(
      title: json['title'].toString(),
      photo: json['photo'].toString(),
      date: int.parse(json['date'].toString()),
      price: double.parse(json['price'].toString()),
      items: [],
    );
  }
}

class Item {
  String name;
  String price;

  Item({required this.name, required this.price});
  factory Item.fromJson(Map<String, Object> json) => Item(
        name: json['name'].toString(),
        price: json['price'].toString(),
      );

  Map<String, Object> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }

  static List<Item> toList(List<Map<String, Object>> json) {
    return List.from(json)
        .map((e) => Item(name: e['name'], price: e['price']))
        .toList();
  }
}
