import '../dao/card_dao.dart';
import '../../models/card_model.dart';

class CardRepository {
  CardRepository(this._dao);
  final CardDao _dao;
  Future<List<CardModel>> inFolder(int folderId) => _dao.inFolder(folderId);
  Future<List<CardModel>> availableForSuit(String suit) => _dao.availableForSuit(suit);
  Future<int> addToFolder(int cardId, int folderId) => _dao.assignToFolder(cardId, folderId);
  Future<int> move(int cardId, int? folderId) => _dao.reassign(cardId, folderId);
  Future<int> update(CardModel c) => _dao.update(c);
  Future<int> delete(int cardId) => _dao.delete(cardId);
}