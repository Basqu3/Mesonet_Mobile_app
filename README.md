# Montana Climate Office Mesonet App

## Overview
A **Flutter** application that visualizes mesonet data from the Montana Climate Office. It fetches station data via the public API and presents it on an interactive map with temperature and precipitation overlays.

## Features
- Interactive map with **temperature**, **precipitation**, and **normal** view modes (controlled by the FAB).
- Filter stations by **HydroMet**, **AgriMet**, or **All** using a toggle switch.
- Tap a marker to open a detailed **Station Page** with current data, charts, and photos.
- WebView pages for **About**, **Feedback**, and **Streamflow**.
- In‑memory **caching** of API responses (5‑minute TTL) to reduce network calls.
- Robust error handling with retry SnackBar.

## Architecture & Folder Structure
```
lib/
├─ main.dart                # App entry point & theme
├─ Screens/
│   ├─ HomeManager.dart    # Bottom navigation hub
│   ├─ map.dart            # MapPage with markers & FAB logic
│   ├─ StationPage.dart    # Detailed station view (PageView)
│   └─ DataPages/
│       ├─ CurrentDataPretty.dart   # Current station data
│       ├─ Chartmanager.dart        # Historical charts
│       └─ ... (other data pages)
└─ services/
    └─ data_cache.dart     # Simple in‑memory cache for API calls
```

## Page Flow (Visualization)
1. **HomeManager** – Bottom navigation selects one of the main screens:
   - **Map** → `MapPage`
   - **About** → WebView
   - **Feedback** → WebView
   - **Streamflow** → WebView
2. **MapPage** – Displays a FlutterMap with station markers.
   - **FAB** cycles view mode: **Temperature → Precipitation → Normal**.
   - **ToggleSwitch** filters station types.
   - **Tap marker** → opens **StationPage**.
3. **StationPage** – Shows a `PageView` of data pages for the selected station:
   - `CurrentDataPretty` (current observations)
   - `Chartmanager` (historical charts)
   - Additional pages (photos, alerts, etc.)
4. **Data Pages** – Fetch data via the API (cached) and display it.

## Installation
```bash
# Ensure Flutter SDK and Java are installed
flutter pub get
flutter run   # Run on a connected device or emulator
```

## Building the APK
```bash
flutter build apk   # Generates app-release.apk in build/app/outputs/flutter-apk/
```

## License
This project is open source and available under the MIT License.
