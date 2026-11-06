/// Size of a dashboard card, determines how many grid columns it spans.
enum CardSize {
  small(1, 'Small'),
  medium(2, 'Medium'),
  large(4, 'Large');

  const CardSize(this.columnSpan, this.displayName);

  /// How many grid columns this card takes.
  final int columnSpan;
  final String displayName;
}
