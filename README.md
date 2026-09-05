# Bike Renting App

Flutter mobile app for renting shared bikes. Material 3 UI, light and dark themes, accessible touch targets, and reduced-motion support.

## Modules

| Module | Functions |
| --- | --- |
| Global layout | `BikeShell` app shell, safe-area layout, bottom navigation, settings, theme switcher. |
| User | Profile, wallet, permissions, ride history. |
| Renting | QR scan, bike check, payment hold, unlock, active ride, return station, dock return, charging, receipt. |
| Station | Nearby stations, dock capacity, return points, station status. |
| Bike management | Fleet health, battery status, availability, maintenance queue. |

The home dashboard summarizes available bikes, active rides, open docks, and a station preview.

## SDG 9: Industry, Innovation and Infrastructure

The app supports SDG 9 by making shared transport infrastructure easier to access and manage: riders discover bikes and stations and unlock bikes via QR scan, while station capacity, bike availability, and fleet-health data help operators plan docks, redistribute bikes, and keep cycling infrastructure reliable.

## Government Dataset Use

Home currently shows local weather values at the UI integration point, with a TODO marking where the cached `api.met.gov.my` response and location lookup will replace them.

Planned datasets: MET Malaysia weather forecasts (rider weather display), open-data cycling infrastructure (supported bike locations and routes), public transport stops and timetables (first/last-mile trip planning), traffic and weather alerts (route warnings and operations planning), and local authority boundaries and points of interest (station coverage). Each dataset must be checked for licence, update frequency, accuracy, and API terms before release.

## Navigation

One global shell (`BikeShell`) hosts: Home dashboard, QRCode/current ride, Station page, Profile (planned), Settings, and an Admin page (bike, station, and user management) shown via a header icon. The renting flow is a linear chain: bike check → payment authorization → unlock → active ride → return station → dock confirm → charge → receipt → home. Pages labelled "planned" in the structure do not yet have dedicated pages.

## Run

```bash
flutter pub get
flutter run
```

## Main Files

- `lib/main.dart` - application entry point.
- `lib/shell/bike_shell.dart` - global layout and navigation coordination.
- `lib/navigation/app_page.dart` - typed page enum and route metadata.
- `lib/navigation/app_navigator.dart` - route factory and navigation observer.
- `lib/features/renting/` - bike renting flow, models, and controller.
- `lib/features/home/home_page.dart` - home dashboard.
