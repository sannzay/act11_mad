import 'package:sqflite/sqflite.dart';
import '../db/app_db.dart';
import '../../models/folder_model.dart';
import '../../models/card_model.dart';

class FolderDao {
  Future<List<FolderModel>> getAll() async {
    final db = await AppDb.instance.database;
    final rows = await db.query('folders', orderBy: 'id ASC');
    return rows.map(FolderModel.fromMap).toList();
  }
  Future<int> insert(FolderModel f) async {
    final db = await AppDb.instance.database;
    return db.insert('folders', f.toMap());
  }
  Future<int> update(FolderModel f) async {
    final db = await AppDb.instance.database;
    return db.update('folders', f.toMap(), where: 'id = ?', whereArgs: [f.id]);
  }
  Future<int> remove(int id) async {
    final db = await AppDb.instance.database;
    await db.update('cards', {'folder_id': null}, where: 'folder_id = ?', whereArgs: [id]);
    return db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> countCards(int folderId) async {
    final db = await AppDb.instance.database;
    final r = await db.rawQuery('SELECT COUNT(*) c FROM cards WHERE folder_id = ?', [folderId]);
    return (r.first['c'] as int);
  }
  Future<CardModel?> firstCard(int folderId) async {
    final db = await AppDb.instance.database;
    final rows = await db.query('cards', where: 'folder_id = ?', whereArgs: [folderId], limit: 1);
    if (rows.isEmpty) return null;
    return CardModel.fromMap(rows.first);
  }
}