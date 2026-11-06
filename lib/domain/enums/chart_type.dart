/// Chart visualization types for dashboard cards.
enum ChartType {
  line('Line'),
  bar('Bar'),
  donut('Donut');

  const ChartType(this.displayName);
  final String displayName;
}
