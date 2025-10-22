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
    _db = await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade, onOpen: _onOpen);
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
        final fileSafeRank = rank.toLowerCase();
        final fileSafeSuit = suit.toLowerCase();
        final assetPath = 'assets/cards/${fileSafeSuit}_$fileSafeRank.png';
        await db.insert('cards', {'name': rank, 'suit': suit, 'image_url': assetPath, 'folder_id': null});
      }
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final rows = await db.query('cards', columns: ['id','name','suit']);
      for (final row in rows) {
        final name = (row['name'] as String).toLowerCase();
        final suit = (row['suit'] as String).toLowerCase();
        final assetPath = 'assets/cards/${suit}_$name.png';
        await db.update('cards', {'image_url': assetPath}, where: 'id = ?', whereArgs: [row['id']]);
      }
    }
    if (oldVersion < 3) {
      await _ensureDefaultFolders(db);
    }
  }

  Future<void> _onOpen(Database db) async {
    await _ensureDefaultFolders(db);
  }

  Future<void> _ensureDefaultFolders(Database db) async {
    final need = {'Hearts','Spades','Diamonds','Clubs'};
    final rows = await db.query('folders', columns: ['name']);
    for (final r in rows) {
      need.remove(r['name'] as String);
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final name in need) {
      await db.insert('folders', {'name': name, 'created_at': now});
    }
  }
}
