import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();
  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'card_organizer.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _db!;
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE folders (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, created_at INTEGER NOT NULL);');
    await db.execute('CREATE TABLE cards (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, suit TEXT NOT NULL, image_url TEXT NOT NULL, folder_id INTEGER, FOREIGN KEY(folder_id) REFERENCES folders(id) ON DELETE SET NULL);');
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final suit in ['Hearts','Spades','Diamonds','Clubs']) {
      await db.insert('folders', {'name': suit, 'created_at': now});
    }
    final ranks = ['Ace','2','3','4','5','6','7','8','9','10','Jack','Queen','King'];
    for (final suit in ['Hearts','Spades','Diamonds','Clubs']) {
      for (final rank in ranks) {
        final label = '$rank of $suit';
        final url = 'https://via.placeholder.com/300x420?text=${Uri.encodeComponent(label)}';
        await db.insert('cards', {'name': rank, 'suit': suit, 'image_url': url, 'folder_id': null});
      }
    }
  }
}