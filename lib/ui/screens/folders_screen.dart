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
  final ValueNotifier<List<_FolderWithMeta>> items = ValueNotifier<List<_FolderWithMeta>>([]);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final folders = await _dao.getAll();
    final data = <_FolderWithMeta>[];
    for (final f in folders) {
      final count = await _dao.countCards(f.id!);
      final preview = await _dao.firstCard(f.id!);
      data.add(_FolderWithMeta(folder: f, count: count, preview: preview));
    }
    if (!mounted) return;
    items.value = data;
  }

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
    if (newName != null && newName.isNotEmpty) {
      await _dao.update(item.folder.copyWith(name: newName));
      await _reload();
    }
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
    if (ok == true) {
      await _dao.remove(item.folder.id!);
      await _reload();
    }
  }

  Future<void> _createFolder() async {
    final nameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Folder name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _dao.insert(FolderModel(name: result, createdAt: DateTime.now()));
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Organizer — Folders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createFolder,
        icon: const Icon(Icons.create_new_folder),
        label: const Text('New Folder'),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ValueListenableBuilder<List<_FolderWithMeta>>(
          valueListenable: items,
          builder: (context, data, _) {
            if (data.isEmpty) {
              return ListView(children: const [SizedBox(height: 300), Center(child: Text('No folders'))]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final item = data[index];
                return FolderTile(
                  folder: item.folder,
                  count: item.count,
                  preview: item.preview,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => FolderDetailScreen(folder: item.folder)));
                    await _reload();
                  },
                  onRename: () => _rename(item),
                  onDelete: () => _delete(item),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: data.length,
            );
          },
        ),
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
