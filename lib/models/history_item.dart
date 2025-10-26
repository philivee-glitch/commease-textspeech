class HistoryItem {
  final String phrase;
  final DateTime at;
  
  HistoryItem(this.phrase, this.at);
  
  Map<String, dynamic> toJson() => {
    'p': phrase,
    't': at.toIso8601String(),
  };
  
  static HistoryItem fromJson(Map<String, dynamic> j) => HistoryItem(
    j['p'] as String,
    DateTime.parse(j['t'] as String),
  );
}