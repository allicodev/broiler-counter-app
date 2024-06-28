class BroilerCount {
  int count;
  DateTime createdAt;
  BroilerCount({
    required this.count,
    required this.createdAt,
  });

  factory BroilerCount.fromJson(Map<String, dynamic> json) => BroilerCount(
      count: json["count"] as int,
      createdAt: DateTime.parse(json['createdAt'] as String)
          .add(const Duration(hours: 8)));
}
