import 'package:sp_app/models/core/receipt.dart';

class ReceiptHelper {
  static List<Receipt> sarchResultReceipt = recipeSearchResultRawData
      .map((data) => Receipt(
          title: data['title'].toString(),
          photo: data['photo'].toString(),
          date: int.parse(data['date'].toString()),
          price: double.parse(data['price'].toString()),
          items: List<Item>.from(
              (data["items"] as List).map((x) => Item.fromJson(x)))))
      .toList();

  static List<Receipt> bookmarkedReceipt = bookmarkedReceiptRawData
      .map((data) => Receipt(
          title: data['title'].toString(),
          photo: data['photo'].toString(),
          date: int.parse(data['date'].toString()),
          price: double.parse(data['price'].toString()),
          items: List<Item>.from(
              (data["items"] as List).map((x) => Item.fromJson(x)))))
      .toList();
}

var recipeSearchResultRawData = [
  {
    'title': 'Healthy Vege Green Egg.',
    'photo': 'assets/images/list1.jpg',
    'date': '1677299899069',
    'price': '453.45',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Delicious Salad by Ron.',
    'photo': 'assets/images/list2.jpg',
    'date': '1677299899069',
    'price': '876.54',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Basil Leaves & Avocado Bread.',
    'photo': 'assets/images/list4.jpg',
    'date': '1677299899069',
    'price': '7454.95',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Healthy Beef & Egg.',
    'photo': 'assets/images/list5.jpg',
    'date': '1677299899069',
    'price': '41.54',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Meats and Vegetables Bowl.',
    'photo': 'assets/images/list6.jpg',
    'date': '1677299899069',
    'price': '843.54',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Breakfast Delimenu.',
    'photo': 'assets/images/list3.jpg',
    'date': '1677299899069',
    'price': '83.54',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
];

var bookmarkedReceiptRawData = [
  {
    'title': 'Puregold',
    'photo': 'assets/images/list1.jpg',
    'date': '1677299899069',
    'price': '167.75',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'SM',
    'photo': 'assets/images/list2.jpg',
    'date': '1677299899069',
    'price': '870.45',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Basil Leaves & Avocado Bread.',
    'photo': 'assets/images/list4.jpg',
    'date': '1677299899069',
    'price': '848.50',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Healthy Beef & Egg.',
    'photo': 'assets/images/list5.jpg',
    'date': '1677299899069',
    'price': '8835.15',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Meats and Vegetables Bowl.',
    'photo': 'assets/images/list6.jpg',
    'date': '1677299899069',
    'price': '12.45',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
  {
    'title': 'Breakfast Delimenu.',
    'photo': 'assets/images/list3.jpg',
    'date': '1677299899069',
    'price': '954.42',
    'items': [
      {
        'name': 'Spinach',
        'price': '250',
      },
      {
        'name': 'Noodles',
        'price': '1000',
      },
      {
        'name': 'Chili',
        'price': '50',
      },
      {
        'name': 'Chocolatte',
        'price': '1000',
      },
      {
        'name': 'Brocolli',
        'price': '150',
      }
    ]
  },
];
