import '../dao/folder_dao.dart';
import '../../models/folder_model.dart';
import '../../models/card_model.dart';

class FolderRepository {
  FolderRepository(this._dao);
  final FolderDao _dao;
  Future<List<FolderModel>> all() => _dao.getAll();
  Future<int> create(FolderModel f) => _dao.insert(f);
  Future<int> update(FolderModel f) => _dao.update(f);
  Future<int> delete(int id) => _dao.remove(id);
  Future<int> count(int id) => _dao.countCards(id);
  Future<CardModel?> preview(int id) => _dao.firstCard(id);
}