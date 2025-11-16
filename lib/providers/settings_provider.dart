import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scroll direction options for caption display
enum ScrollDirection { topToBottom, bottomToTop }

/// Manages app settings/preferences
///
/// Currently manages:
/// - Scroll direction
/// - Recognition engine (placeholder for future)
///
/// Settings are persisted using SharedPreferences
class SettingsProvider extends ChangeNotifier {
  ScrollDirection _scrollDirection = ScrollDirection.bottomToTop;

  static const String _scrollDirectionKey = 'scroll_direction';

  ScrollDirection get scrollDirection => _scrollDirection;

  SettingsProvider() {
    _loadSettings();
  }

  /// Load saved settings from storage
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final scrollDirectionIndex = prefs.getInt(_scrollDirectionKey);
    if (scrollDirectionIndex != null) {
      if (scrollDirectionIndex >= 0 && scrollDirectionIndex < ScrollDirection.values.length) {
        _scrollDirection = ScrollDirection.values[scrollDirectionIndex];
      }
      notifyListeners();
    }
  }

  /// Update scroll direction preference
  Future<void> setScrollDirection(ScrollDirection direction) async {
    if (_scrollDirection == direction) return;

    _scrollDirection = direction;
    notifyListeners(); // Rebuilds widgets listening to this provider

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scrollDirectionKey, direction.index);
  }
}
