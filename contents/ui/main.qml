import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami.platform as Kirigami

PlasmoidItem {
    id: root

    // Desktop resize uses fullRepresentation Layout.* below.
    // Keep root hints aligned so panel/desktop agree on mins.
    Layout.minimumWidth: 150
    Layout.minimumHeight: 150
    // 280 logical × 1.4 scale ≈ 390 physical px — sensible default on this display
    Layout.preferredWidth: 320
    Layout.preferredHeight: 280

    // No Plasma frame drawn — widget floats directly on the wallpaper.
    // WebEngine interior remains solid (#131722); only the Plasma shell border is removed.
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground | PlasmaCore.Types.ConfigurableBackground

    preferredRepresentation: fullRepresentation

    // _reloadRequest is a counter. Incrementing it from anywhere triggers
    // the Connections inside WebEngineView (which CAN access webView).
    property int _reloadRequest: 0
    property bool _widgetReady: false

    // One line per symbol: "EXCHANGE:TICKER,Display Name" (display name optional).
    function parseCustomSymbols(raw) {
        var lines = (raw || "").split("\n")
        var symbols = []
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line) continue
            var commaIndex = line.indexOf(",")
            var symbol = (commaIndex === -1 ? line : line.substring(0, commaIndex)).trim()
            if (!symbol) continue
            var display = commaIndex === -1 ? symbol : line.substring(commaIndex + 1).trim()
            if (!display) display = symbol
            symbols.push({ "s": symbol, "d": display })
        }
        return symbols
    }

    function defaultTabs() {
        return [
            {
                "title": "Indices",
                "symbols": [
                    { "s": "FOREXCOM:SPXUSD", "d": "S&P 500" },
                    { "s": "FOREXCOM:NSXUSD", "d": "NASDAQ 100" },
                    { "s": "FOREXCOM:DJI", "d": "Dow Jones" },
                    { "s": "INDEX:NKY", "d": "Japan 225" },
                    { "s": "INDEX:DEU40", "d": "DAX" },
                    { "s": "FOREXCOM:UKXGBP", "d": "FTSE 100" },
                    { "s": "KRX:KOSPI", "d": "KOSPI" }
                ]
            },
            {
                "title": "Futures",
                "symbols": [
                    { "s": "OANDA:XAUUSD", "d": "Gold" },
                    { "s": "MATBAROFEX:WTI1!", "d": "WTI Oil" },
                    { "s": "BLACKBULL:BRENT", "d": "Brent Oil" },
                    { "s": "CAPITALCOM:NATURALGAS", "d": "Natural Gas" },
                    { "s": "OANDA:XAGUSD", "d": "Silver" }
                ]
            },
            {
                "title": "Forex",
                "symbols": [
                    { "s": "FX:EURUSD", "d": "EUR/USD" },
                    { "s": "FX:GBPUSD", "d": "GBP/USD" },
                    { "s": "FX:USDJPY", "d": "USD/JPY" },
                    { "s": "FX:USDKRW", "d": "USD/KRW" },
                    { "s": "FX:AUDUSD", "d": "AUD/USD" }
                ]
            },
            {
                "title": "Crypto",
                "symbols": [
                    { "s": "COINBASE:BTCUSD", "d": "Bitcoin" },
                    { "s": "COINBASE:ETHUSD", "d": "Ethereum" },
                    { "s": "BINANCE:XRPUSD", "d": "XRP" },
                    { "s": "COINBASE:ADAUSD", "d": "Cardano" },
                    { "s": "COINBASE:SOLUSD", "d": "Solana" }
                ]
            }
        ]
    }

    // Actual pixel height of the webView, updated once dimensions are known.
    // Used to tell TradingView exactly how tall to render; "100%" is unreliable in loadHtml().
    property int _tvHeight: 280

    // These can stay here: buildHtml and openConfigure don't touch webView.
    function buildHtml() {
        var colorTheme = Plasmoid.configuration.colorTheme || "dark"
        var locale = Plasmoid.configuration.locale || "en"
        var dateRange = Plasmoid.configuration.dateRange || "1D"
        var tvHeight = Math.max(200, root._tvHeight)

        var customSymbols = root.parseCustomSymbols(Plasmoid.configuration.customSymbols)
        var tabs = customSymbols.length > 0
            ? [{ "title": "Watchlist", "symbols": customSymbols }]
            : root.defaultTabs()

        var widgetConfig = {
            "colorTheme": colorTheme,
            "dateRange": dateRange,
            "showChart": true,
            "locale": locale,
            "largeChartUrl": "",
            "isTransparent": true,
            "showSymbolLogo": true,
            "showFloatingTooltip": false,
            "width": "100%",
            "height": tvHeight,
            "plotLineColorGrowing": "rgba(38, 166, 154, 1)",
            "plotLineColorFalling": "rgba(239, 83, 80, 1)",
            "gridLineColor": "rgba(54, 58, 69, 0.06)",
            "scaleFontColor": "rgba(209, 212, 220, 1)",
            "belowLineFillColorGrowing": "rgba(38, 166, 154, 0.12)",
            "belowLineFillColorFalling": "rgba(239, 83, 80, 0.12)",
            "belowLineFillColorGrowingBottom": "rgba(38, 166, 154, 0)",
            "belowLineFillColorFallingBottom": "rgba(239, 83, 80, 0)",
            "symbolActiveColor": "rgba(61, 158, 255, 0.12)",
            "tabs": tabs
        }

        return `<!DOCTYPE html>
<html lang="${locale}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TradingView Widget</title>
    <style>
        /* 100vh = exact WebEngineView height inside loadHtml() */
        html, body {
            margin: 0;
            padding: 0;
            width: 100vw;
            height: 100vh;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        }

        /* Make TradingView's injected iframe fill the full viewport */
        .tradingview-widget-container {
            width: 100vw;
            height: 100vh;
        }

        .tradingview-widget-container__widget {
            width: 100%;
            height: 100%;
        }
    </style>
</head>
<body>
    <!-- TradingView Widget BEGIN -->
    <div class="tradingview-widget-container">
        <div class="tradingview-widget-container__widget"></div>
        <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-market-overview.js" async>
        ${JSON.stringify(widgetConfig)}
        </script>
    </div>
    <!-- TradingView Widget END -->
</body>
</html>`
    }

    function openConfigure() {
        var action = Plasmoid.internalAction("configure")
        if (action) {
            action.trigger()
        }
    }

    // Incrementing _reloadRequest triggers the Connections inside WebEngineView.
    // fullRepresentation is a Component scope: webView is NOT visible from here.
    Connections {
        target: Plasmoid.configuration
        function onColorThemeChanged() { if (root._widgetReady) root._reloadRequest++ }
        function onLocaleChanged() { if (root._widgetReady) root._reloadRequest++ }
        function onDateRangeChanged() { if (root._widgetReady) root._reloadRequest++ }
        function onCustomSymbolsChanged() { if (root._widgetReady) root._reloadRequest++ }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: 150
        Layout.minimumHeight: 150
        Layout.preferredWidth: 320
        Layout.preferredHeight: 280
        // Do NOT set implicitWidth/implicitHeight here — Plasma would treat them as the minimum.

        // Debounce timer: reloads TradingView only after resize gesture stops (500 ms idle).
        // This prevents fighting with Plasma's drag-to-resize interaction.
        Timer {
            id: resizeDebounce
            interval: 500
            repeat: false
            onTriggered: {
                if (root._widgetReady)
                    webView.loadHtml(root.buildHtml(), "https://example.com/")
            }
        }

        WebEngineView {
            id: webView
            anchors.fill: parent
            // Use a solid color matching TradingView's dark/light theme.
            // Qt.rgba(0,0,0,0) (transparent) requires compositor alpha support which may be absent.
            backgroundColor: Plasmoid.configuration.colorTheme === "light" ? "#ffffff" : "#131722"
            // Prevent Chromium from reporting a large implicit size upward to Plasma.
            implicitWidth: 1
            implicitHeight: 1

            settings.javascriptEnabled: true
            settings.localContentCanAccessRemoteUrls: true
            settings.errorPageEnabled: false
            settings.webGLEnabled: true

            // Update _tvHeight when the view is resized; debounce to avoid reload storms.
            onHeightChanged: {
                var h = Math.floor(height)
                if (h > 50 && Math.abs(h - root._tvHeight) > 20) {
                    root._tvHeight = h
                    resizeDebounce.restart()
                }
            }

            Connections {
                target: root
                function on_ReloadRequestChanged() {
                    webView.loadHtml(root.buildHtml(), "https://example.com/")
                }
            }

            onLoadingChanged: function (loadRequest) {
                if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    statusLabel.visible = false
                    busyIndicator.visible = false
                } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                    statusLabel.text = "Error: " + loadRequest.errorString
                    statusLabel.visible = true
                    busyIndicator.visible = false
                }
            }

            onRenderProcessTerminated: function(terminationStatus, exitCode) {
                var reasons = ["Normal", "Abnormal", "Crashed", "Killed"]
                statusLabel.text = "Renderer crash (" + reasons[terminationStatus] + ")"
                statusLabel.visible = true
                busyIndicator.visible = false
            }

            Component.onCompleted: {
                root._tvHeight = Math.max(200, Math.floor(height))
                root._widgetReady = true
                webView.loadHtml(root.buildHtml(), "https://example.com/")
            }
        }

        PlasmaComponents.ToolButton {
            id: configureButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 8
            z: 1000
            icon.name: "configure"
            text: i18n("Configure")
            display: PlasmaComponents.ToolButton.IconOnly
            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.text: i18n("Configure TradingView Market Overview")
            Accessible.name: i18n("Configure")
            onClicked: root.openConfigure()
        }

        PlasmaComponents.BusyIndicator {
            id: busyIndicator
            anchors.centerIn: parent
            running: statusLabel.visible
            visible: running
        }

        PlasmaComponents.Label {
            id: statusLabel
            anchors.top: busyIndicator.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n("Loading TradingView widget...")
            visible: true
            z: 999
            font.pixelSize: 14
            color: Kirigami.Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width - 24
        }
    }
}
