import 'package:flutter/material.dart';
import '../../models/folder_model.dart';
import '../../models/card_model.dart';
import '../../data/dao/folder_dao.dart';
import '../widgets/folder_tile.dart';
import 'folder_detail_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});
  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final _dao = FolderDao();
  late Future<List<_FolderWithMeta>> _future;
  @override
  void initState() { super.initState(); _future = _load(); }
  Future<List<_FolderWithMeta>> _load() async {
    final folders = await _dao.getAll();
    final data = <_FolderWithMeta>[];
    for (final f in folders) {
      final count = await _dao.countCards(f.id!);
      final preview = await _dao.firstCard(f.id!);
      data.add(_FolderWithMeta(folder: f, count: count, preview: preview));
    }
    return data;
  }
  void _refresh() { setState(() => _future = _load()); }
  Future<void> _rename(_FolderWithMeta item) async {
    final controller = TextEditingController(text: item.folder.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Folder name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) { await _dao.update(item.folder.copyWith(name: newName)); _refresh(); }
  }
  Future<void> _delete(_FolderWithMeta item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete folder?'),
        content: const Text('Cards will be unassigned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) { await _dao.remove(item.folder.id!); _refresh(); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer — Folders')),
      body: FutureBuilder<List<_FolderWithMeta>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('No folders'));
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final item = items[index];
                return FolderTile(
                  folder: item.folder,
                  count: item.count,
                  preview: item.preview,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => FolderDetailScreen(folder: item.folder)));
                    _refresh();
                  },
                  onRename: () => _rename(item),
                  onDelete: () => _delete(item),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: items.length,
            ),
          );
        },
      ),
    );
  }
}

class _FolderWithMeta {
  final FolderModel folder;
  final int count;
  final CardModel? preview;
  _FolderWithMeta({required this.folder, required this.count, required this.preview});
}
