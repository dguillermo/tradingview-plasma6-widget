import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: page

    property string cfg_colorTheme
    property string cfg_colorThemeDefault: "dark"
    property alias cfg_locale: localeField.text
    property string cfg_localeDefault: "en"
    property string cfg_dateRange
    property string cfg_dateRangeDefault: "1D"
    property alias cfg_showChart: showChartCheck.checked
    property bool cfg_showChartDefault: true
    property alias cfg_showSymbolLogo: showSymbolLogoCheck.checked
    property bool cfg_showSymbolLogoDefault: true
    property alias cfg_showFloatingTooltip: showFloatingTooltipCheck.checked
    property bool cfg_showFloatingTooltipDefault: false
    property alias cfg_customSymbols: customSymbolsField.text
    property string cfg_customSymbolsDefault: ""

    readonly property var colorThemeModel: [
        { text: i18n("Dark"), value: "dark" },
        { text: i18n("Light"), value: "light" }
    ]

    readonly property var dateRangeModel: [
        { text: i18n("1 day"), value: "1D" },
        { text: i18n("1 month"), value: "1M" },
        { text: i18n("3 months"), value: "3M" },
        { text: i18n("12 months"), value: "12M" },
        { text: i18n("60 months"), value: "60M" },
        { text: i18n("All"), value: "ALL" }
    ]

    function indexForValue(model, value, fallback) {
        for (var i = 0; i < model.length; i++) {
            if (model[i].value === value) {
                return i
            }
        }
        for (var j = 0; j < model.length; j++) {
            if (model[j].value === fallback) {
                return j
            }
        }
        return 0
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: colorThemeCombo
            Kirigami.FormData.label: i18n("Color theme:")
            textRole: "text"
            valueRole: "value"
            model: page.colorThemeModel
            currentIndex: page.indexForValue(page.colorThemeModel, page.cfg_colorTheme || "dark", "dark")
            onActivated: function(index) {
                page.cfg_colorTheme = page.colorThemeModel[index].value
            }
        }

        QQC2.TextField {
            id: localeField
            Kirigami.FormData.label: i18n("Language (ISO code, e.g. en, es):")
            placeholderText: "en"
        }

        QQC2.ComboBox {
            id: dateRangeCombo
            Kirigami.FormData.label: i18n("Initial chart range:")
            textRole: "text"
            valueRole: "value"
            model: page.dateRangeModel
            currentIndex: page.indexForValue(page.dateRangeModel, page.cfg_dateRange || "1D", "1D")
            onActivated: function(index) {
                page.cfg_dateRange = page.dateRangeModel[index].value
            }
        }

        QQC2.CheckBox {
            id: showChartCheck
            Kirigami.FormData.label: i18n("Show mini chart:")
            text: i18n("Display sparkline chart under the symbol list")
        }

        QQC2.CheckBox {
            id: showSymbolLogoCheck
            Kirigami.FormData.label: i18n("Show symbol logos:")
            text: i18n("Display exchange/company logos next to each symbol")
        }

        QQC2.CheckBox {
            id: showFloatingTooltipCheck
            Kirigami.FormData.label: i18n("Floating tooltip:")
            text: i18n("Show price details when hovering the chart")
        }

        QQC2.ScrollView {
            Kirigami.FormData.label: i18n("Custom symbols:")
            Layout.fillWidth: true
            Layout.preferredHeight: 160

            QQC2.TextArea {
                id: customSymbolsField
                wrapMode: TextEdit.NoWrap
                placeholderText: "COINBASE:BTCUSD,Bitcoin\nNASDAQ:AAPL,Apple\nFOREXCOM:SPXUSD,S&P 500"
            }
        }

        QQC2.Label {
            Kirigami.FormData.label: ""
            Layout.fillWidth: true
            Layout.maximumWidth: 400
            text: i18n("One symbol per line, format TRADINGVIEW_SYMBOL,Display Name (display name is optional). The symbol must be EXCHANGE:TICKER (e.g. COINBASE:BTCUSD, NASDAQ:AAPL). Leave empty for the default tabs (Indices/Futures/Forex/Crypto).")
            wrapMode: Text.WordWrap
            opacity: 0.7
        }
    }
}
