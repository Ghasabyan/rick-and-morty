class InfoModel {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  const InfoModel({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      count: json['count'] as int,
      pages: json['pages'] as int,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'pages': pages,
      'next': next,
      'prev': prev,
    };
  }
}
