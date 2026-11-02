/// Test tags used to build suites from the command line, for example:
///
/// ```bash
/// patrol test --tags smoke
/// patrol test --tags "regression && !android-only"
/// ```
abstract final class Tags {
  /// Fast checks that the app starts and its main screens are reachable.
  static const smoke = 'smoke';

  /// Business workflows and validation rules.
  static const regression = 'regression';

  /// Tests that drive the operating system (home button, dark mode, share sheet).
  static const native = 'native';

  /// Tests that rely on Android-only behaviour (for example the system back button).
  static const androidOnly = 'android-only';
}
