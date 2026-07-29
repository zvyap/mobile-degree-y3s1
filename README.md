# Bike Renting App

Flutter mobile application for renting shared bikes. It uses a Material 3 interface, light and dark themes, accessible touch controls, and reduced-motion support.

## Core Modules and Pages

| Module | Pages / functions |
| --- | --- |
| Global layout module | `BikeShell` app shell, safe-area layout, page header, back action, settings page, theme switcher, and bottom navigation. |
| User module | User module landing page for profile, wallet, permissions, and ride history. |
| Bike renting module | QR scan, bike check, payment-hold authorization, unlock, active ride tracking, return-station selection, dock return, charging, and receipt. |
| Bike station module | Station module landing page for nearby stations, dock capacity, available return points, and station status. |
| Bike management module | Bike module landing page for fleet health, battery status, bike availability, and maintenance queue. |

The home dashboard combines summary information from the renting, station, and bike management modules: available bikes, active rides, open docks, and a station preview.

## SDG 9: Industry, Innovation and Infrastructure

This app supports **SDG 9** by using a digital shared-mobility service to make transport infrastructure easier to access and manage.

- Riders can discover bikes and stations, unlock a bike through QR scanning, and return it to an available dock.
- Station capacity and bike availability can help operators make better infrastructure decisions, such as where to add docks or redistribute bikes.
- Fleet-health and maintenance information support more reliable, efficient cycling infrastructure.
- The app's data-driven design can reduce manual operational work and encourage innovation in sustainable urban transport.

## Government Dataset Use

Home currently shows local weather values at the UI integration point. A TODO marks where the cached government API response and location lookup will replace them.

The planned implementation will fetch and cache weather data from `api.met.gov.my`, resolve the user's current coordinates into a detailed location, translate documented Bahasa Melayu forecast values into English, and preserve unknown Bahasa Melayu wording as a fallback.

| Dataset type | Use in the app |
| --- | --- |
| MET Malaysia weather forecast | Display current and next-hour weather conditions around the rider. |
| Government open-data portal station, road, and cycling-infrastructure data | Show supported bike locations, cycling routes, and safe access to stations. |
| Public transport stop and timetable data | Help users plan first-mile and last-mile bike trips to buses, rail stations, or other public transport. |
| Traffic, road-closure, and weather-alert data | Warn riders about disrupted routes and help operations plan bike redistribution or maintenance. |
| Local authority geographic boundaries and points of interest | Organize station coverage areas and help users find nearby public destinations. |

Before release, the weather TODO must be completed with the cached API integration. Each dataset must be checked for its licence, update frequency, geographic accuracy, and API terms. Cached government data should keep the app usable when a source is temporarily unavailable.

## Navigation Relation

Current navigation has one global shell. The items labelled **planned** are in the intended structure but do not yet have dedicated pages in the current code.

```text
BikeRent App
|
L-- Global layout: BikeShell
    |
    +-- Login (planned)
    |   |
    |   +-- Register (planned)
    |   L-- Forgot password (planned)
    |
    +-- Home dashboard
    |   L-- QRCode / current ride
    |
    +-- Admin page: top-bar icon beside Settings
    |   +-- Bike management page
    |   |   L-- Bike list (planned)
    |   +-- Station management page
    |   |   L-- Station create (planned)
    |   L-- User management page
    |       +-- User create (planned)
    |       L-- User renting history (planned)
    |           L-- Ride details (planned)
    |
    +-- Ride history (planned)
    |   L-- Ride details (planned)
    +-- QRCode / current ride
    |   L-- Bike check
    |       L-- Payment authorization
    |           L-- Unlock bike
    |               L-- Active ride
    |                   L-- Select return station
    |                       L-- Return and confirm dock
    |                           L-- Charge payment
    |                               L-- Rental receipt
    |                                   L-- Home dashboard
    +-- Station page
    |   L-- Station details (planned)
    |       L-- Station route (planned)
    +-- Profile page (planned)
    L-- Settings page
```

The bottom navigation opens Home, Stations, Scan, History, and Profile. When `BikeShell._isAdmin` is `true`, the header shows an **Admin management** icon beside Settings. It opens the Admin page, whose actions open station management, bike management, and user management destinations. The header back action returns to Home when no rental-flow step needs to be revisited; the renting flow instead moves back through its previous applicable step.

## Run

```bash
flutter pub get
flutter run
```

## Main Files

- `lib/main.dart` - application entry point.
- `lib/shell/bike_shell.dart` - global layout, page switching, settings, and navigation coordination.
- `lib/features/renting/` - bike renting flow, models, and controller.
- `lib/features/home/home_page.dart` - home dashboard.
