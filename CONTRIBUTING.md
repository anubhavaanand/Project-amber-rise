# Contributing

Bug reports and pull requests are welcome.

## Before you open a PR

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

`flutter analyze` must report **0 errors**. `flutter test` must pass.

## House rules

- **One concern per change.** Don't mix a refactor with a feature.
- **Surgical edits.** Don't reformat code you aren't changing.
- **Match the surrounding style.**
- **No generated files by hand.** `.g.dart` comes from `build_runner`; pixel art comes from the
  recipes in `docs/brand/`.
- **Remove what your change orphans.** If your edit makes an import or a file unused, delete it.
- **Don't add dependencies** without saying why in the PR description.

## Reporting a bug

Include: device and Android version, what you did, what happened, and what you expected. If it is an
alarm that did not ring, say whether the app was force-stopped, the device was in Doze, or it had
rebooted — those are different failures.
