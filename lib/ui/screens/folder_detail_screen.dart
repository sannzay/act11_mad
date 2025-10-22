import 'package:flutter/material.dart';
import '../../models/folder_model.dart';
import '../../models/card_model.dart';
import '../../data/dao/card_dao.dart';
import '../../data/dao/folder_dao.dart';
import '../widgets/card_tile.dart';

class FolderDetailScreen extends StatefulWidget {
  final FolderModel folder;
  const FolderDetailScreen({super.key, required this.folder});
  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  static const minCards = 3;
  static const maxCards = 6;
  final _cardDao = CardDao();
  final _folderDao = FolderDao();
  late Future<List<CardModel>> _futureCards;
  @override
  void initState() { super.initState(); _futureCards = _cardDao.inFolder(widget.folder.id!); }
  void _refresh() { setState(() => _futureCards = _cardDao.inFolder(widget.folder.id!)); }
  Future<void> _addCard() async {
    final currentCount = await _folderDao.countCards(widget.folder.id!);
    if (currentCount >= maxCards) { _showSnack('This folder can only hold $maxCards cards.', Colors.red); return; }
    final options = await _cardDao.availableForSuit(widget.folder.name);
    if (options.isEmpty) { _showSnack('No available ${widget.folder.name} cards left to add.', Colors.blue); return; }
    final choice = await showModalBottomSheet<CardModel>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return Column(children: [
              Padding(padding: const EdgeInsets.all(12.0), child: Text('Add a ${widget.folder.name} card', style: Theme.of(context).textTheme.titleMedium)),
              Expanded(child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 0.7),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final c = options[index];
                  return InkWell(
                    onTap: () => Navigator.pop(context, c),
                    child: Card(child: Column(children: [
                      Expanded(child: Image.network(c.imageUrl, fit: BoxFit.cover)),
                      Padding(padding: const EdgeInsets.all(6.0), child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ])),
                  );
                },
              ))
            ]);
          },
        );
      },
    );
    if (choice != null) { await _cardDao.assignToFolder(choice.id!, widget.folder.id!); _refresh(); _validateMinCards(); }
  }
  Future<void> _editCard(CardModel card) async {
    final nameCtrl = TextEditingController(text: card.name);
    final suits = const ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    String suit = card.suit;
    final result = await showDialog<CardModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Card'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(decoration: const InputDecoration(labelText: 'Name'), controller: nameCtrl),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(value: suit, items: suits.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => suit = v!, decoration: const InputDecoration(labelText: 'Suit')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () { final updated = card.copyWith(name: nameCtrl.text.trim(), suit: suit); Navigator.pop(ctx, updated); }, child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      if (result.suit != widget.folder.name) {
        final folders = await FolderDao().getAll();
        final target = folders.firstWhere((f) => f.name == result.suit, orElse: () => widget.folder);
        final targetCount = await _folderDao.countCards(target.id!);
        if (targetCount >= maxCards) { _showSnack('Cannot move: "$suit" folder already has $maxCards cards.', Colors.red); return; }
        await _cardDao.update(result.copyWith(folderId: target.id));
      } else {
        await _cardDao.update(result);
      }
      _refresh();
      _validateMinCards();
    }
  }
  Future<void> _deleteCard(CardModel card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('Remove ${card.name} of ${card.suit} from this folder?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) { await _cardDao.delete(card.id!); _refresh(); _validateMinCards(); }
  }
  Future<void> _reassignCard(CardModel card) async {
    final folders = await FolderDao().getAll();
    final target = await showDialog<FolderModel>(
      context: context,
      builder: (ctx) => SimpleDialog(title: const Text('Move to folder'), children: [
        for (final f in folders) SimpleDialogOption(onPressed: () => Navigator.pop(ctx, f), child: Text(f.name))
      ]),
    );
    if (target == null) return;
    if (target.id == widget.folder.id) return;
    final targetCount = await _folderDao.countCards(target.id!);
    if (targetCount >= maxCards) { _showSnack('Target folder can only hold $maxCards cards.', Colors.red); return; }
    await _cardDao.reassign(card.id!, target.id);
    _refresh();
    _validateMinCards();
  }
  Future<void> _validateMinCards() async {
    final count = await _folderDao.countCards(widget.folder.id!);
    if (count < minCards) { _showSnack('You need at least $minCards cards in this folder.', Colors.orange); }
  }
  void _showSnack(String msg, Color color) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color)); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name), actions: [IconButton(icon: const Icon(Icons.info_outline), onPressed: _validateMinCards)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addCard, icon: const Icon(Icons.add), label: const Text('Add')),
      body: FutureBuilder<List<CardModel>>(
        future: _futureCards,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final cards = snapshot.data!;
          if (cards.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('No cards yet.'),
              const SizedBox(height: 8),
              ElevatedButton.icon(onPressed: _addCard, icon: const Icon(Icons.add), label: const Text('Add Card')),
            ]));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.7),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final c = cards[index];
              return CardTile(card: c, onEdit: () => _editCard(c), onMove: () => _reassignCard(c), onDelete: () => _deleteCard(c));
            },
          );
        },
      ),
    );
  }
}
