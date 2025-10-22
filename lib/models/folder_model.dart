class FolderModel {
  final int? id;
  final String name;
  final DateTime createdAt;
  FolderModel({this.id, required this.name, required this.createdAt});
  FolderModel copyWith({int? id, String? name, DateTime? createdAt}) => FolderModel(id: id ?? this.id, name: name ?? this.name, createdAt: createdAt ?? this.createdAt);
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'created_at': createdAt.millisecondsSinceEpoch};
  static FolderModel fromMap(Map<String, dynamic> map) => FolderModel(id: map['id'] as int?, name: map['name'] as String, createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int));
}