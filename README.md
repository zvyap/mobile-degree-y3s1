# Bike Renting App

Flutter mobile application assignment for a small bike renting product.

## Current Scope

- Home page dashboard for bike renting status.
- Global navigation shell with a slightly larger center ride action.
- Light and dark Material 3 themes.
- Motion using Flutter implicit animations with reduced-motion handling.
- Module entry points for user, renting, station, and bike management.

## Modules

- User: profile, wallet, permissions, ride history.
- Renting: QR unlock, active ride, payment, return flow.
- Station and Bike Management: stations, docks, bikes, maintenance.

## Run

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
```

## Main Files

- `lib/main.dart` - app theme, home page, nav shell, module placeholders.
- `test/widget_test.dart` - smoke test for home, theme toggle, and center nav.
