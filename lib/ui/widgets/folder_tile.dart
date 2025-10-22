import 'package:flutter/material.dart';
import '../../models/folder_model.dart';
import '../../models/card_model.dart';

class FolderTile extends StatelessWidget {
  final FolderModel folder;
  final int count;
  final CardModel? preview;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  const FolderTile({super.key, required this.folder, required this.count, required this.preview, this.onTap, this.onRename, this.onDelete});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _Preview(preview: preview),
      title: Text(folder.name),
      subtitle: Text('$count card(s)'),
      trailing: PopupMenuButton<String>(
        onSelected: (v) { if (v=='rename') onRename?.call(); if (v=='delete') onDelete?.call(); },
        itemBuilder: (ctx) => const [
          PopupMenuItem(value: 'rename', child: Text('Rename')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _Preview extends StatelessWidget {
  final CardModel? preview;
  const _Preview({required this.preview});
  @override
  Widget build(BuildContext context) {
    final size = 48.0;
    if (preview == null) {
      return Container(width: size, height: size, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).colorScheme.surfaceVariant), child: const Icon(Icons.folder_open));
    }
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(preview!.imageUrl, width: size, height: size, fit: BoxFit.cover));
  }
}