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
    property alias cfg_customSymbols: customSymbolsField.text
    property string cfg_customSymbolsDefault: ""

    readonly property var colorThemeModel: [
        { text: i18n("Oscuro"), value: "dark" },
        { text: i18n("Claro"), value: "light" }
    ]

    function indexForValue(value) {
        for (var i = 0; i < colorThemeModel.length; i++) {
            if (colorThemeModel[i].value === value) {
                return i
            }
        }
        return 0
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: colorThemeCombo
            Kirigami.FormData.label: i18n("Tema de color:")
            textRole: "text"
            valueRole: "value"
            model: page.colorThemeModel
            currentIndex: page.indexForValue(page.cfg_colorTheme || "dark")
            onActivated: function(index) {
                page.cfg_colorTheme = page.colorThemeModel[index].value
            }
        }

        QQC2.TextField {
            id: localeField
            Kirigami.FormData.label: i18n("Idioma (código ISO, ej. en, es):")
            placeholderText: "en"
        }

        QQC2.ScrollView {
            Kirigami.FormData.label: i18n("Símbolos personalizados:")
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
            text: i18n("Un símbolo por línea, formato SIMBOLO_TRADINGVIEW,Nombre a mostrar (el nombre es opcional). El símbolo debe ir en formato EXCHANGE:TICKER (ej. COINBASE:BTCUSD, NASDAQ:AAPL). Vacío = pestañas por defecto (Indices/Futures/Forex/Crypto).")
            wrapMode: Text.WordWrap
            opacity: 0.7
        }
    }
}
