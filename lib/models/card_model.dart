class CardModel {
  final int? id;
  final String name;
  final String suit;
  final String imageUrl;
  final int? folderId;
  CardModel({this.id, required this.name, required this.suit, required this.imageUrl, this.folderId});
  CardModel copyWith({int? id, String? name, String? suit, String? imageUrl, int? folderId}) => CardModel(id: id ?? this.id, name: name ?? this.name, suit: suit ?? this.suit, imageUrl: imageUrl ?? this.imageUrl, folderId: folderId ?? this.folderId);
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'suit': suit, 'image_url': imageUrl, 'folder_id': folderId};
  static CardModel fromMap(Map<String, dynamic> map) => CardModel(id: map['id'] as int?, name: map['name'] as String, suit: map['suit'] as String, imageUrl: map['image_url'] as String, folderId: map['folder_id'] as int?);
}