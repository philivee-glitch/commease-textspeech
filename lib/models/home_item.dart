enum HomeItemType { category, quick }

class HomeItem {
  final String label;
  final HomeItemType type;
  const HomeItem(this.label, this.type);
}