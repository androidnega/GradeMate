class DelayUtils {
  /// Default delay duration for loading states
  static const defaultLoadingDelay = Duration(milliseconds: 800);

  /// Shorter delay for error states
  static const errorDelay = Duration(milliseconds: 500);

  /// Quick feedback delay (e.g., button presses)
  static const quickFeedbackDelay = Duration(milliseconds: 200);

  /// Delay for transitions (e.g., screen changes)
  static const transitionDelay = Duration(milliseconds: 300);

  /// Shows loading state for a minimum duration
  static Future<T> withLoadingDelay<T>(
    Future<T> Function() action, {
    Duration minimumDuration = defaultLoadingDelay,
  }) async {
    final timer = Future.delayed(minimumDuration);
    try {
      final result = await action();
      await timer; // Ensure minimum duration has passed
      return result;
    } catch (e) {
      await Future.delayed(errorDelay);
      rethrow;
    }
  }

  /// Ensures a minimum delay between user actions
  static Future<void> withMinimumDelay(
    Future<void> Function() action, {
    Duration minimumDuration = quickFeedbackDelay,
  }) async {
    final startTime = DateTime.now();
    await action();
    final elapsedTime = DateTime.now().difference(startTime);

    if (elapsedTime < minimumDuration) {
      await Future.delayed(minimumDuration - elapsedTime);
    }
  }

  /// Adds a delay before executing an action
  static Future<T> withDelay<T>(
    Future<T> Function() action, {
    Duration delay = defaultLoadingDelay,
  }) async {
    await Future.delayed(delay);
    return action();
  }
}
