enum Priority implements Comparable<Priority> {
  low('Basse'),
  medium('Moyenne'),
  high('Haute');

  final String label;
  const Priority(this.label);

  @override
  int compareTo(Priority other) => index.compareTo(other.index);

  static Priority parse(String value) {
    switch (value.toLowerCase()) {
      case 'high':
      case 'haute':
      case '3':
        return Priority.high;
      case 'medium':
      case 'moyenne':
      case '2':
        return Priority.medium;
      case 'low':
      case 'basse':
      case '1':
      default:
        return Priority.low;
    }
  }
}

