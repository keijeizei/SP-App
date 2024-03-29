import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/receipt.dart';

class DBHelper {
  // A method to create the database and table
  Future<Database> initializeDB() async {
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'receipt_database.db'),
      // When the database is first created, create a table to store tasks.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE receipts(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, photo TEXT, date INTEGER, price REAL)',
        );
        await db.execute(
          'CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, abbreviation TEXT, price REAL, receipt_id INTEGER, FOREIGN KEY(receipt_id) REFERENCES receipts(id))',
        );
        await db.execute(
          'CREATE TABLE suggestions(id INTEGER PRIMARY KEY AUTOINCREMENT, receipt_id INTEGER, item_id INTEGER, word TEXT, FOREIGN KEY(receipt_id) REFERENCES receipts(id), FOREIGN KEY(item_id) REFERENCES items(id))',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    return database;
  }

  // ========================================= CREATE ========================================

  // Define a function that inserts receipt into the database
  Future<int> insertReceipt(Receipt receipt) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Insert the Receipt into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same task is inserted twice.
    //
    // In this case, replace any previous data.
    return await db.insert(
      'receipts',
      receipt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Define a function that inserts item into the database
  Future<void> insertItem(Item item) async {
    final db = await initializeDB();

    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Define a function that inserts suggestion into the database
  Future<void> insertSuggestion(Suggestion suggestion) async {
    final db = await initializeDB();

    await db.insert(
      'suggestions',
      suggestion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ========================================= READ ========================================

  // A method that retrieves all the tasks from the tasks table.
  Future<List<Receipt>> getReceipts() async {
    final db = await initializeDB();

    // Query the table for all The Tasks.
    final List<Map<String, dynamic>> maps =
        await db.query('receipts', orderBy: 'date DESC');

    // Convert the List<Map<String, dynamic> into a List<Task>.
    return List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          title: maps[i]['title'],
          photo: maps[i]['photo'],
          date: maps[i]['date'],
          price: maps[i]['price']);
    });
  }

  // A method that retrieves all the tasks from the tasks table.
  Future<List<Receipt>> searchReceipts(String keyword) async {
    // Get a reference to the database.
    final db = await initializeDB();

    // Query the table for all The Tasks.
    final List<Map<String, dynamic>> maps = await db.query(
      'receipts',
      where: 'title LIKE ?',
      whereArgs: ['%$keyword%'],
    );

    // Convert the List<Map<String, dynamic> into a List<Task>.
    return List.generate(maps.length, (i) {
      return Receipt(
          id: maps[i]['id'],
          title: maps[i]['title'],
          photo: maps[i]['photo'],
          date: maps[i]['date'],
          price: maps[i]['price']);
    });
  }

  // A method that retrieves all the items belonging to a receipt id
  Future<List<Item>> getItems(int id) async {
    final db = await initializeDB();

    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'receipt_id = ?',
      whereArgs: [id],
    );

    // Convert the List<Map<String, dynamic> into a List<Item>.
    return List.generate(maps.length, (i) {
      return Item(
          id: maps[i]['id'],
          name: maps[i]['name'],
          abbreviation: maps[i]['abbreviation'],
          price: maps[i]['price'],
          receipt_id: maps[i]['receipt_id']);
    });
  }

  // A method that retrieves all the suggestions belonging to an item id
  Future<List<Suggestion>> getSuggestions(int item_id) async {
    final db = await initializeDB();

    final List<Map<String, dynamic>> maps = await db.query(
      'suggestions',
      where: 'item_id = ?',
      whereArgs: [item_id],
    );

    // Convert the List<Map<String, dynamic> into a List<Suggestion>.
    return List.generate(maps.length, (i) {
      return Suggestion(
          id: maps[i]['id'],
          receipt_id: maps[i]['receipt_id'],
          item_id: maps[i]['item_id'],
          word: maps[i]['word']);
    });
  }

  // ========================================= UPDATE ========================================

  // Update a receipt
  Future<void> updateReceipt(Receipt receipt) async {
    final db = await initializeDB();

    await db.update(
      'receipts',
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  // Update an item
  Future<void> updateItem(Item item) async {
    final db = await initializeDB();

    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // ========================================= DELETE ========================================

  // A method that deletes a receipt given an id.
  Future<void> deleteReceipt(int id) async {
    final db = await initializeDB();

    await db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // A method that deletes an item given an id.
  Future<void> deleteItem(int id) async {
    final db = await initializeDB();

    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // A method that deletes all suggestions for a given item_id.
  Future<void> deleteSuggestionsByItem(int item_id) async {
    final db = await initializeDB();

    await db.delete(
      'suggestions',
      where: 'item_id = ?',
      whereArgs: [item_id],
    );
  }
}
