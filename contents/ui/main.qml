import QtQuick
import QtQuick.Layouts
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

    function buildHtml() {
        var colorTheme = Plasmoid.configuration.colorTheme || "dark"
        var locale = Plasmoid.configuration.locale || "en"
        var backgroundColor = colorTheme === "light" ? "#ffffff" : "#232530"
        var borderColor = colorTheme === "light" ? "#e0e3eb" : "#363a45"

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

        #tv-error-message {
            display: none;
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 20px;
            box-sizing: border-box;
            color: #e06c75;
            background: ${backgroundColor};
        }

        #tv-error-message p {
            margin: 4px 0;
            color: ${colorTheme === "light" ? "#333333" : "#d1d4dc"};
        }

        #tv-error-retry {
            margin-top: 12px;
            padding: 6px 16px;
            border-radius: 4px;
            border: 1px solid #3d9eff;
            background: transparent;
            color: #3d9eff;
            cursor: pointer;
            font-size: 12px;
        }

        #tv-error-retry:hover {
            background: rgba(61, 158, 255, 0.15);
        }
    </style>
</head>
<body>
    <!-- TradingView Widget BEGIN -->
    <div class="tradingview-widget-container">

        <div id="tv-error-message">
            <strong>No se pudo cargar TradingView</strong>
            <p>Comprueba tu conexión a internet o si s3.tradingview.com está accesible.</p>
            <button id="tv-error-retry" onclick="window.location.reload()">Reintentar</button>
        </div>

        <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-market-overview.js" async
            onerror="document.getElementById('tv-error-message').style.display='flex'">
        {
            "colorTheme": "${colorTheme}",
            "dateRange": "12M",
            "showChart": true,
            "locale": "${locale}",
            "largeChartUrl": "",
            "isTransparent": false,
            "showSymbolLogo": true,
            "showFloatingTooltip": false,
            "width": "450",
            "height": "650",
            "plotLineColorGrowing": "rgba(38, 166, 154, 1)",
            "plotLineColorFalling": "rgba(239, 83, 80, 1)",
            "gridLineColor": "rgba(54, 58, 69, 0.06)",
            "scaleFontColor": "rgba(209, 212, 220, 1)",
            "belowLineFillColorGrowing": "rgba(38, 166, 154, 0.12)",
            "belowLineFillColorFalling": "rgba(239, 83, 80, 0.12)",
            "belowLineFillColorGrowingBottom": "rgba(38, 166, 154, 0)",
            "belowLineFillColorFallingBottom": "rgba(239, 83, 80, 0)",
            "symbolActiveColor": "rgba(61, 158, 255, 0.12)",
            "tabs": [
                {
                    "title": "Indices",
                    "symbols": [
                        {"s": "FOREXCOM:SPXUSD", "d": "S&P 500"},
                        {"s": "FOREXCOM:NSXUSD", "d": "NASDAQ 100"},
                        {"s": "FOREXCOM:DJI", "d": "Dow Jones"},
                        {"s": "INDEX:NKY", "d": "Japan 225"},
                        {"s": "INDEX:DEU40", "d": "DAX"},
                        {"s": "FOREXCOM:UKXGBP", "d": "FTSE 100"},
                        {"s": "KRX:KOSPI", "d": "KOSPI"}
                    ]
                },
                {
                    "title": "Futures",
                    "symbols": [
                        {"s": "OANDA:XAUUSD", "d": "Gold"},
                        {"s": "MATBAROFEX:WTI1!", "d": "WTI Oil"},
                        {"s": "BLACKBULL:BRENT", "d": "Brent Oil"},
                        {"s": "CAPITALCOM:NATURALGAS", "d": "Natural Gas"},
                        {"s": "OANDA:XAGUSD", "d": "Silver"}
                    ]
                },
                {
                    "title": "Forex",
                    "symbols": [
                        {"s": "FX:EURUSD", "d": "EUR/USD"},
                        {"s": "FX:GBPUSD", "d": "GBP/USD"},
                        {"s": "FX:USDJPY", "d": "USD/JPY"},
                        {"s": "FX:USDKRW", "d": "USD/KRW"},
                        {"s": "FX:AUDUSD", "d": "AUD/USD"}
                    ]
                },
                {
                    "title": "Crypto",
                    "symbols": [
                        {"s": "COINBASE:BTCUSD", "d": "Bitcoin"},
                        {"s": "COINBASE:ETHUSD", "d": "Ethereum"},
                        {"s": "BINANCE:XRPUSD", "d": "XRP"},
                        {"s": "COINBASE:ADAUSD", "d": "Cardano"},
                        {"s": "COINBASE:SOLUSD", "d": "Solana"}
                    ]
                }
            ]
        }
        </script>

        <script>
            // Si a los 10s el iframe del widget no se ha inyectado, TradingView
            // no respondio (bloqueo de red/DNS/firewall) aunque el <script> cargase.
            setTimeout(function () {
                var hasWidget = document.querySelector('.tradingview-widget-container__widget iframe')
                if (!hasWidget) {
                    document.getElementById('tv-error-message').style.display = 'flex'
                }
            }, 10000)
        </script>
    </div>
    <!-- TradingView Widget END -->
</body>
</html>`
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

            onLoadingChanged: function (loadRequest) {
                if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    statusLabel.visible = false
                } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                    statusLabel.text = "Error al cargar el widget: " + loadRequest.errorString
                    statusLabel.visible = true
                    busyIndicator.visible = false
                }
            }

            Component.onCompleted: loadHtml(root.buildHtml())

            Connections {
                target: Plasmoid.configuration
                function onColorThemeChanged() { webView.loadHtml(root.buildHtml()) }
                function onLocaleChanged() { webView.loadHtml(root.buildHtml()) }
            }
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
