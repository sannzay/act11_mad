import '../db/app_db.dart';
import '../../models/card_model.dart';

class CardDao {
  Future<List<CardModel>> inFolder(int folderId) async {
    final db = await AppDb.instance.database;
    final rows = await db.query('cards', where: 'folder_id = ?', whereArgs: [folderId], orderBy: 'id ASC');
    return rows.map(CardModel.fromMap).toList();
  }
  Future<List<CardModel>> availableForSuit(String suit) async {
    final db = await AppDb.instance.database;
    final rows = await db.query('cards', where: 'suit = ? AND folder_id IS NULL', whereArgs: [suit], orderBy: 'id ASC');
    return rows.map(CardModel.fromMap).toList();
  }
  Future<int> assignToFolder(int cardId, int folderId) async {
    final db = await AppDb.instance.database;
    return db.update('cards', {'folder_id': folderId}, where: 'id = ?', whereArgs: [cardId]);
  }
  Future<int> reassign(int cardId, int? folderId) async {
    final db = await AppDb.instance.database;
    return db.update('cards', {'folder_id': folderId}, where: 'id = ?', whereArgs: [cardId]);
  }
  Future<int> update(CardModel c) async {
    final db = await AppDb.instance.database;
    return db.update('cards', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }
  Future<int> delete(int cardId) async {
    final db = await AppDb.instance.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }
}