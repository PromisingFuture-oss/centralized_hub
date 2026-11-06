import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centralized_hub/core/utils/duration_formatter.dart';
import 'package:centralized_hub/core/utils/temperature_utils.dart';
import 'package:centralized_hub/domain/enums/card_type.dart';
import 'package:centralized_hub/features/dashboard/providers/entertainment_deck_provider.dart';
import 'package:centralized_hub/shared/widgets/empty_state.dart';

void main() {
  group('DurationFormatter', () {
    test('formats ms correctly', () {
      expect(DurationFormatter.formatMs(null), '0s');
      expect(DurationFormatter.formatMs(0), '0s');
      expect(DurationFormatter.formatMs(45000), '45s');
      expect(DurationFormatter.formatMs(120000), '2m');
      expect(DurationFormatter.formatMs(3661000), '1h 1m');
    });

    test('formatTimer pads digits', () {
      expect(
        DurationFormatter.formatTimer(const Duration(hours: 1, minutes: 5, seconds: 9)),
        '01:05:09',
      );
    });

    test('formatLong produces human readable string', () {
      expect(
        DurationFormatter.formatLong(const Duration(hours: 1, minutes: 20)),
        '1 hour 20 minutes',
      );
    });
  });

  group('TemperatureUtils', () {
    test('converts celsius to fahrenheit accurately', () {
      expect(TemperatureUtils.celsiusToFahrenheit(0), 32);
      expect(TemperatureUtils.celsiusToFahrenheit(100), 212);
      expect(TemperatureUtils.celsiusToFahrenheit(30), 86);
    });

    test('converts fahrenheit to celsius accurately', () {
      expect(TemperatureUtils.fahrenheitToCelsius(32), 0);
      expect(TemperatureUtils.fahrenheitToCelsius(212), 100);
    });

    test('formats temperatures with units', () {
      expect(TemperatureUtils.format(35.5), '35.5°C');
      expect(TemperatureUtils.format(35.5, useFahrenheit: true), '95.9°F');
    });

    test('assigns correct severity labels', () {
      expect(TemperatureUtils.getTemperatureLabel(25.0), 'Cool');
      expect(TemperatureUtils.getTemperatureLabel(32.0), 'Normal');
      expect(TemperatureUtils.getTemperatureLabel(37.0), 'Warm');
      expect(TemperatureUtils.getTemperatureLabel(42.0), 'Hot');
      expect(TemperatureUtils.getTemperatureLabel(47.0), 'Very Hot');
    });
  });

  group('EmptyState Widget', () {
    testWidgets('renders title and triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.videogame_asset,
              title: 'No Games Tracked',
              subtitle: 'Start playing games to see stats',
              actionLabel: 'Refresh',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('No Games Tracked'), findsOneWidget);
      expect(find.text('Start playing games to see stats'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('EntertainmentDeck CardType & Heuristics', () {
    test('CardType.entertainmentDeck has correct attributes', () {
      expect(CardType.entertainmentDeck.displayName, 'Media & Entertainment');
      expect(
        CardType.entertainmentDeck.description,
        'Quick-launch and manage your favorite media and reading apps',
      );
    });

    test('entertainmentKeywords identifies popular media & reading apps', () {
      const testPackages = [
        'com.google.android.youtube',
        'app.revanced.android.youtube',
        'org.schabi.newpipe',
        'eu.kanade.tachiyomi',
        'mihon.app',
        'com.naver.linewebtoon',
        'com.netflix.mediaclient',
        'tv.twitch.android.app',
        'com.spotify.music',
      ];

      for (final pkg in testPackages) {
        final matches = entertainmentKeywords.any((k) => pkg.contains(k));
        expect(matches, isTrue, reason: '$pkg should match entertainment keywords');
      }
    });
  });
}

