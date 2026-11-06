/// Types of dashboard cards available in the card library.
enum CardType {
  totalPlaytime('Total Playtime', 'Shows total gaming time for a period'),
  topGames('Top Games', 'Ranks games by playtime'),
  recentSessions('Recent Sessions', 'Lists your latest gaming sessions'),
  temperatureTrend('Temperature Trend', 'Battery temperature over time'),
  hottestSessions('Hottest Sessions', 'Sessions with highest peak temperatures'),
  batteryDrain('Battery Drain', 'Battery consumption per game'),
  avgDrainPerHour('Avg Drain/Hour', 'Average battery drain rate per hour of play'),
  sessionDistribution('Session Distribution', 'How your session lengths are distributed'),
  playtimeHeatmap('Playtime Heatmap', 'Daily playtime calendar view'),
  streaks('Streaks', 'Consecutive days with gaming activity'),
  liveSession('Live Session', 'Real-time stats for the current session'),
  entertainmentDeck('Media & Entertainment', 'Quick-launch and manage your favorite media and reading apps');

  const CardType(this.displayName, this.description);
  final String displayName;
  final String description;
}
