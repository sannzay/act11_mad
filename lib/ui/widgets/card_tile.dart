import 'package:flutter/material.dart';
import '../../models/card_model.dart';

class CardTile extends StatelessWidget {
  final CardModel card;
  final VoidCallback onEdit;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  const CardTile({super.key, required this.card, required this.onEdit, required this.onMove, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        final action = await showMenu<String>(context: context, position: RelativeRect.fill, items: const [
          PopupMenuItem(value: 'edit', child: Text('Update')),
          PopupMenuItem(value: 'move', child: Text('Move')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ]);
        if (action == 'edit') onEdit();
        if (action == 'move') onMove();
        if (action == 'delete') onDelete();
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: Image.network(card.imageUrl, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${card.name} of ${card.suit}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.edit), onPressed: onEdit, tooltip: 'Update'),
                IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.delete_outline), onPressed: onDelete, tooltip: 'Delete'),
              ])
            ]),
          ),
        ]),
      ),
    );
  }
}
