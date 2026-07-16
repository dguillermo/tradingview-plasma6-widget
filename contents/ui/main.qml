import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami.platform as Kirigami

PlasmoidItem {
    id: root

    Layout.minimumWidth: 350
    Layout.minimumHeight: 500
    Layout.preferredWidth: 450
    Layout.preferredHeight: 700

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

    // These can stay here: buildHtml and openConfigure don't touch webView.
    function buildHtml() {
        var colorTheme = Plasmoid.configuration.colorTheme || "dark"
        var locale = Plasmoid.configuration.locale || "en"
        var backgroundColor = colorTheme === "light" ? "#ffffff" : "#232530"
        var borderColor = colorTheme === "light" ? "#e0e3eb" : "#363a45"

        var customSymbols = root.parseCustomSymbols(Plasmoid.configuration.customSymbols)
        var tabs = customSymbols.length > 0
            ? [{ "title": "Watchlist", "symbols": customSymbols }]
            : root.defaultTabs()

        var widgetConfig = {
            "colorTheme": colorTheme,
            "dateRange": "12M",
            "showChart": true,
            "locale": locale,
            "largeChartUrl": "",
            "isTransparent": false,
            "showSymbolLogo": true,
            "showFloatingTooltip": false,
            "width": "100%",
            "height": "100%",
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
        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: ${backgroundColor};
        }

        .tradingview-widget-container {
            width: 100%;
            height: 100vh;
            background: ${backgroundColor};
        }

        .tradingview-widget-container__widget {
            width: 100%;
            height: calc(100% - 25px);
        }

        .tradingview-widget-copyright {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            font-size: 10px;
            text-align: center;
            padding: 5px;
            background: ${backgroundColor};
            border-top: 1px solid ${borderColor};
        }

        .tradingview-widget-copyright a {
            text-decoration: none;
            color: #3d9eff;
        }

        .blue-text {
            color: #3d9eff;
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
        function onCustomSymbolsChanged() { if (root._widgetReady) root._reloadRequest++ }
    }

    fullRepresentation: Rectangle {
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
        border.color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.3)
        border.width: 1
        radius: 4

        WebEngineView {
            id: webView
            anchors.fill: parent
            anchors.margins: 3

            settings.javascriptEnabled: true
            settings.localContentCanAccessRemoteUrls: true
            settings.errorPageEnabled: false
            settings.webGLEnabled: true

            // _reloadRequest incremented from PlasmoidItem → load new HTML here
            // (webView IS in scope inside fullRepresentation Component)
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
            text: "Cargando widget de TradingView..."
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
