# TradingView Plasma Widget — Plasma 6 port

> **Fork** of [StrKare/tradingview-plasma-widget](https://github.com/StrKare/tradingview-plasma-widget), ported to **KDE Plasma 6 / Qt 6 / KDE Frameworks 6**.
>
> - **Original author:** [StrKare](https://github.com/StrKare) — Plasma 5 widget.
> - **Plasma 6 port maintainer:** [dguillermo](https://github.com/dguillermo).

A KDE Plasma desktop widget that displays live market data from TradingView (indices, futures, forex and cryptocurrencies), with native Plasma theme integration.

![KDE Plasma](https://img.shields.io/badge/KDE-Plasma%206-blue) ![Qt](https://img.shields.io/badge/Qt-6-green) ![License](https://img.shields.io/badge/license-MIT-green)

## Requirements

- **KDE Plasma** ≥ 6.0 (tested on Plasma 6.7.3)
- **Qt** ≥ 6.5 (tested on Qt 6.11.1)
- **KDE Frameworks** ≥ 6.0 (tested on KF6 6.28.0)
- **QtWebEngine for Qt6** installed (`qt6-webengine` on Arch/CachyOS, `qml6-module-qtwebengine` + `libqt6webenginecore6` on Debian/Ubuntu-based distros)
- Internet connection (the widget loads `s3.tradingview.com` in real time; no offline mode or local cache)
- `kpackagetool6` in your `PATH` (ships with `plasma-workspace`)

Quick dependency check:

```bash
plasmashell --version          # >= 6.0
qmake6 -query QT_VERSION       # >= 6.5
pkg-config --modversion KF6CoreAddons   # >= 6.0
find /usr/lib/qt6/qml/QtWebEngine -maxdepth 0   # must exist
```

## Installation

```bash
git clone https://github.com/dguillermo/tradingview-plasma6-widget.git
cd tradingview-plasma6-widget
kpackagetool6 --type Plasma/Applet --install .
```

Then:

1. Right-click on the desktop → **"Add Widgets..."**
2. Search for **"TradingView Market Overview"**
3. Drag it to the desktop or panel

If the widget does not appear in the picker, restart `plasmashell` (see Debugging section).

## Update

After pulling new changes:

```bash
kpackagetool6 --type Plasma/Applet --upgrade .
systemctl --user restart plasma-plasmashell.service   # X11 only
```

> On **Wayland**, `plasma-plasmashell.service` cannot be restarted the same way. To force a reload of an already-placed widget, remove it from the desktop and add it again, or log out and back in.

## Uninstall

```bash
kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.tradingview
```

## Configuration

Right-click the widget → **"Configure TradingView Market Overview..."**, or use the **configure** button (gear icon) in the top-right corner of the widget:

- **Color theme**: dark / light (default: dark, same as the original widget)
- **Language**: ISO code passed to TradingView (`en`, `es`, etc.)
- **Initial chart range**: `1D` / `1M` / `3M` / `12M` / `60M` / `ALL` (default: **1D**). Sets TradingView's `dateRange` when the widget loads.
- **Custom symbols**: one symbol per line, format `EXCHANGE:TICKER,Display Name` (display name optional, defaults to the symbol itself). The symbol **must** be a full TradingView symbol including the exchange prefix — bare tickers like `BTC` or `AAPL` are not valid TradingView instruments and will not resolve. Find the correct symbol via [TradingView's symbol search](https://www.tradingview.com/symbols/) (e.g. `COINBASE:BTCUSD`, `NASDAQ:AAPL`, `FOREXCOM:SPXUSD`). Leave empty to use the default Indices/Futures/Forex/Crypto tabs.

The widget has no Plasma shell frame (`NoBackground`) so it floats directly on the wallpaper. Default size is ~320×280 logical pixels (resize freely on the desktop using edit mode handles). Right-click → **"Show background"** to toggle the Plasma panel background on or off.

UI strings follow the Plasma/system language via gettext (`i18n()`). Source language is English; Spanish is shipped under `contents/locale/es/`. The **Language** setting above only controls the TradingView embed locale, not the Plasma config dialog.

## Debugging

**View widget/plasmashell logs:**

```bash
journalctl --user -f -u plasma-plasmashell.service    # X11 (if unit exists)
journalctl --user -f _COMM=plasmashell                # X11 and Wayland
```

**Run plasmashell in the foreground to see QML errors directly:**

```bash
plasmashell --replace &
```

**Test the plasmoid in isolation (without affecting the real desktop):**

```bash
plasmoidviewer -a org.kde.plasma.tradingview
```

**Common issues:**

| Symptom | Likely cause | Fix |
|---|---|---|
| Widget not in picker / "written for an older version of Plasma" | Missing `X-Plasma-API-Minimum-Version: "6.0"` in `metadata.json` | Add the key, reinstall with `kpackagetool6 --upgrade .` and re-add the widget |
| Widget not in picker | Package not installed or invalid `metadata.json` | Run `kpackagetool6 --type Plasma/Applet --install . --verbose` and review output |
| Permanent black/blank screen | QtWebEngine for Qt6 not installed | Install `qt6-webengine` and restart session |
| Spinner never goes away / widget stays loading | Upgraded package but plasmashell still uses old compiled QML from memory | `rm -rf ~/.cache/plasmashell/qmlcache/` then `kill $(pgrep plasmashell) && plasmashell --replace &`, remove and re-add the widget |
| "Could not load TradingView" message | No network, DNS blocking `s3.tradingview.com`, or firewall | Check `curl -I https://s3.tradingview.com` from the same user |
| Widget loads but renders poorly on Wayland | Known QtWebEngine/Chromium GPU acceleration issue under Wayland | See limitations below |
| Cannot resize smaller than initial size | Plasmashell still using old QML with `implicitHeight` set | Restart plasmashell (see above) and re-add the widget |
| General tab empty or only shows "Keyboard Shortcuts" | `configGeneral.qml` in wrong path | Must be at `contents/ui/configGeneral.qml` (not `contents/config/`). Reinstall with `kpackagetool6 --type Plasma/Applet --upgrade .` |
| `kpackagetool6 --upgrade` fails to remove previous install | Previous install was done with `sudo` (folder owned by root in `~/.local`) | `sudo kpackagetool6 --type Plasma/Applet --remove org.kde.plasma.tradingview`, then reinstall without sudo |
| Config dialog does not open | `contents/config/main.xml` missing or malformed | Validate with `xmllint --noout contents/config/main.xml` |

## X11 / Wayland compatibility

- **X11**: fully supported. `plasma-plasmashell.service` can be restarted to force a reload after changes.
- **Wayland**: functional support. QtWebEngine embeds a Chromium process; on some GPU driver combinations, hardware acceleration may need to be disabled if the widget area stays blank. Add to `~/.config/plasma-workspace/env/qtwebengine.sh`:

  ```bash
  export QTWEBENGINE_CHROMIUM_FLAGS="--disable-gpu"
  ```

  and restart your session. This is a QtWebEngine/Wayland limitation, not introduced by this port.

## Known limitations

- No cache or offline mode: if there is no network, the widget shows an error and has no local historical data.
- Display content is 100% dependent on the external script `s3.tradingview.com/external-embedding/embed-widget-market-overview.js`; future changes by TradingView to their public widget may require updates to the embedded HTML.
- Custom symbols replace *all* default tabs with a single "Watchlist" tab; there is currently no UI to define multiple custom tabs or mix custom symbols with the defaults.
- QtWebEngine spawns one Chromium process per widget instance: memory usage is significantly higher than a pure native QML widget.
- **Full transparency** (wallpaper visible through the widget interior) is not supported on all systems. It requires the Wayland compositor and GPU driver to support per-surface alpha compositing for Chromium/QtWebEngine surfaces. On systems where this is unavailable, the widget interior uses a solid background (`#131722` for dark theme) while the Plasma shell frame is still removed (`NoBackground`).

## Changes from the original repository

Full migration from Plasma 5 / Qt 5 / KF5 to Plasma 6 / Qt 6 / KF6:

### `metadata.json`
- Added **`"X-Plasma-API-Minimum-Version": "6.0"`** — required in Plasma 6. Without it, the system assumes the plasmoid is Plasma 5 only and shows *"This Widget was written for an unknown older version of Plasma"*.
- Removed `X-Plasma-API: declarativeappletscript` (Plasma 4 vestige, no effect in Plasma 5/6 QML2 engine).
- Removed `X-KDE-ServiceTypes` (redundant with `KPackageStructure: Plasma/Applet`).
- Removed `X-Plasma-MainScript` (Plasma 6 always uses `ui/main.qml` as entry point).
- Added explicit `Icon` and updated `Description`.
- Added port maintainer (`dguillermo`) to `Authors`, keeping StrKare as the original author.

### `contents/ui/main.qml`
- Versionless imports (`import QtQuick`, `import QtWebEngine`, etc.) — recommended style in Qt6/KF6 instead of `QtQuick 2.15`, `QtWebEngine 1.8`.
- Root item migrated from `Item` + attached `Plasmoid.fullRepresentation` / `Plasmoid.preferredRepresentation` to **`PlasmoidItem`** (standard in Plasma 6).
- Replaced `org.kde.plasma.core 2.0 as PlasmaCore` (restructured in KF6) with **`org.kde.kirigami.platform as Kirigami`** for theme colors (`Kirigami.Theme.backgroundColor`, etc.).
- `org.kde.plasma.components 2.0` (deprecated PlasmaComponents 2) replaced with versionless `org.kde.plasma.components` (PlasmaComponents 3 / QQC2).
- Two-layer error handling added:
  - **QML/WebEngineView**: `onLoadingChanged` detects `LoadFailedStatus` and surfaces the real `errorString`.
  - **Embedded HTML/JS**: `onerror` on the TradingView `<script>` + a `setTimeout` check to detect if the widget iframe was injected, showing a readable error with a Retry button.
- `PlasmaComponents.BusyIndicator` shown during initial load.
- Color theme and locale are now read from `Plasmoid.configuration` instead of being hardcoded in `buildHtml()`, and reload automatically when the user changes settings.

### `contents/config/` and `contents/ui/configGeneral.qml`
- `import org.kde.plasma.configuration 2.0` → versionless.
- The original `config.qml` referenced `configGeneral.qml`, a file that **did not exist** in the original repo (the config dialog was broken out of the box). Added:
  - `contents/config/main.xml`: KConfigXT schema with `colorTheme`, `locale`, `dateRange` and `customSymbols` keys.
  - `contents/ui/configGeneral.qml`: `KCM.SimpleKCM` form with `Kirigami.FormLayout` (required in Plasma 6). In Plasma 6, pages referenced from `config.qml` are loaded from `contents/ui/`, not `contents/config/`.

### Translations / i18n

All config-dialog strings use `i18n()` with **English as the source language** (KDE convention). Spanish is bundled under `contents/locale/es/`. The UI language follows the Plasma/system locale automatically.

> **Note:** user-installed plasmoids (`~/.local/share/plasma/plasmoids/`) require Plasma ≥ 6.5.6 to load bundled `.mo` files ([bug #501400](https://bugs.kde.org/show_bug.cgi?id=501400)). With an English system locale the msgid is displayed directly and no `.mo` lookup is needed.

**Adding a new language:**

```bash
cp translate/es.po translate/fr.po   # copy and edit msgstr lines
./translate/build.sh                  # compiles → contents/locale/fr/LC_MESSAGES/…
kpackagetool6 --type Plasma/Applet --upgrade .
rm -rf ~/.cache/plasmashell/qmlcache/
```

## Credits and license

| Role | Person | Link |
|------|--------|------|
| Original author (Plasma 5) | **StrKare** | [github.com/StrKare](https://github.com/StrKare) |
| Plasma 6 port & maintenance | **dguillermo** | [github.com/dguillermo](https://github.com/dguillermo) |

This project is a **fork with substantial changes** (Plasma 6 migration). The original widget concept and code are by StrKare; the Qt6/KF6 adaptations, working config dialog and port maintenance are from this repository.

**MIT License** — same as the original. See [LICENSE](LICENSE).
