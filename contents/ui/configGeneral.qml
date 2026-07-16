import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.plasma.plasmoid

KCM.SimpleKCM {
    id: page

    property string cfg_colorTheme
    property alias cfg_locale: localeField.text

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
    }
}
