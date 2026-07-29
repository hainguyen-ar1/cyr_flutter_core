# Publishing Checklist

Use this checklist before publishing `cyr_flutter_core` to pub.dev.

## Package Metadata

* Confirm `pubspec.yaml` has a clear `description`, `homepage`, `repository`,
  `issue_tracker`, `topics`, and the intended `version`.
* Confirm every runtime dependency is used by `lib/`.
* Run `flutter pub outdated` and update dependencies where compatible.
* Keep `pubspec.lock` out of source control for this library package.

## Documentation

* Keep `README.md` focused on the public package page: what it does, how to
  install it, and a short working usage sample.
* Keep release notes in `CHANGELOG.md` with one version heading per release.
* Keep the license text in `LICENSE` and verify the copyright holder.
* Keep a package example in `example/main.dart`; pub.dev shows it in the
  Example tab.
* Keep deeper guides in `doc/`.

## Verification

Run these commands from the package root:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter pub publish --dry-run
```

For a closer pub.dev score estimate, run `pana` on a copy of the package:

```bash
dart pub global activate pana
dart pub global run pana .
```

## Release

1. Update `version` in `pubspec.yaml`.
2. Add the matching section to `CHANGELOG.md`.
3. Commit the release changes.
4. Run `flutter pub publish --dry-run`.
5. Publish with `flutter pub publish`.
