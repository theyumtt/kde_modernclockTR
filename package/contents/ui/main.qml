import QtQml 2.15
import QtQuick 2.15
import QtQuick.Layouts 1.0
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    // setting background as transparent with a drop shadow
    Plasmoid.backgroundHints: PlasmaCore.Types.ShadowBackground | PlasmaCore.Types.ConfigurableBackground

    // loading fonts
    FontLoader {
        id: font_anurati
        source: "../fonts/Anurati.otf"
    }
    FontLoader {
        id: font_poppins
        source: "../fonts/Poppins.ttf"
    }

    // setting preferred size
    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        id: mainItem

        // applet default size
        Layout.minimumWidth: container.implicitWidth
        Layout.minimumHeight: container.implicitHeight
        Layout.preferredWidth: Layout.minimumWidth
        Layout.preferredHeight: Layout.minimumHeight

        // Local properties bound to config - these create reactive bindings
        property int clockLanguage: plasmoid.configuration.clock_language
        property bool use24HourFormat: plasmoid.configuration.use_24_hour_format
        property bool showSeconds: plasmoid.configuration.show_seconds
        property string timeCharacter: plasmoid.configuration.time_character
        property string dateFormat: plasmoid.configuration.date_format
        property bool textShadow: plasmoid.configuration.text_shadow

        // React to all config changes
        onClockLanguageChanged: updateClock()
        onUse24HourFormatChanged: updateClock()
        onShowSecondsChanged: updateClock()
        onTimeCharacterChanged: updateClock()
        onDateFormatChanged: updateClock()

        // Data source for time
        Plasma5Support.DataSource {
            id: dataSource
            engine: "time"
            connectedSources: ["Local"]
            interval: mainItem.showSeconds ? 1000 : 60000
            intervalAlignment: mainItem.showSeconds ? 0 : Plasma5Support.Types.AlignToMinute
            onDataChanged: updateClock()
        }

        function updateClock() {
            var localData = dataSource.data["Local"]
            if (!localData || !localData["DateTime"]) return
                var curDate = localData["DateTime"]

                // Time format
                var tf
                if (mainItem.use24HourFormat) {
                    tf = mainItem.showSeconds ? "HH:mm:ss" : "HH:mm"
                } else {
                    tf = mainItem.showSeconds ? "hh:mm:ss AP" : "hh:mm AP"
                }

                var lang = mainItem.clockLanguage
                var dateFmt = mainItem.dateFormat
                var tc = mainItem.timeCharacter

                // Day name
                if (lang === 0) {
                    // Turkish
                    var gunler = ["PAZAR", "PAZARTESI", "SALI", "CARSAMBA", "PERSEMBE", "CUMA", "CUMARTESI"]
                    display_day.text = gunler[curDate.getDay()]
                } else if (lang === 1) {
                    // English
                    var daysEn = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
                    display_day.text = daysEn[curDate.getDay()]
                } else {
                    // System Default
                    display_day.text = Qt.locale().dayName(curDate.getDay(), Locale.LongFormat).toUpperCase()
                }

                // Date
                var dateStr = Qt.formatDate(curDate, dateFmt)
                if (lang === 0) {
                    // Turkish month replacements (long first, then short)
                    dateStr = dateStr
                    .replace("January", "Ocak").replace("February", "Şubat").replace("March", "Mart")
                    .replace("April", "Nisan").replace("May", "Mayıs").replace("June", "Haziran")
                    .replace("July", "Temmuz").replace("August", "Ağustos").replace("September", "Eylül")
                    .replace("October", "Ekim").replace("November", "Kasım").replace("December", "Aralık")
                    .replace("Jan", "Oca").replace("Feb", "Şub").replace("Mar", "Mar")
                    .replace("Apr", "Nis").replace("Jun", "Haz")
                    .replace("Jul", "Tem").replace("Aug", "Ağu").replace("Sep", "Eyl")
                    .replace("Oct", "Eki").replace("Nov", "Kas").replace("Dec", "Ara")
                }
                display_date.text = dateStr.toUpperCase()

                // Time
                display_time.text = tc + " " + Qt.formatTime(curDate, tf) + " " + tc
        }

        // Main Content
        Column {
            id: container

            // Column genişliği = en geniş label'ın implicitWidth'i
            // Bu sayede children width: parent.width kullanabilir, döngüsel bağımlılık olmaz
            width: Math.max(display_day.implicitWidth, display_date.implicitWidth, display_time.implicitWidth)

            anchors.centerIn: parent
            spacing: 5

            // The day ("Tuesday", "Wednesday" etc..)
            PlasmaComponents.Label {
                id: display_day

                visible: plasmoid.configuration.show_day

                width: parent.width
                horizontalAlignment: Text.AlignHCenter

                font.pixelSize: plasmoid.configuration.day_font_size
                font.letterSpacing: plasmoid.configuration.day_letter_spacing
                font.family: font_anurati.name
                color: plasmoid.configuration.day_font_color
                style: mainItem.textShadow ? Text.Raised : Text.Normal
                styleColor: Qt.rgba(0, 0, 0, 0.7)
            }

            // The Date
            PlasmaComponents.Label {
                id: display_date

                visible: plasmoid.configuration.show_date

                width: parent.width
                horizontalAlignment: Text.AlignHCenter

                font.pixelSize: plasmoid.configuration.date_font_size
                font.letterSpacing: plasmoid.configuration.date_letter_spacing
                font.family: font_poppins.name
                color: plasmoid.configuration.date_font_color
                style: mainItem.textShadow ? Text.Raised : Text.Normal
                styleColor: Qt.rgba(0, 0, 0, 0.7)
            }

            // The Time
            PlasmaComponents.Label {
                id: display_time

                visible: plasmoid.configuration.show_time

                width: parent.width
                horizontalAlignment: Text.AlignHCenter

                font.pixelSize: plasmoid.configuration.time_font_size
                font.family: font_poppins.name
                color: plasmoid.configuration.time_font_color
                style: mainItem.textShadow ? Text.Raised : Text.Normal
                styleColor: Qt.rgba(0, 0, 0, 0.7)
                font.letterSpacing: plasmoid.configuration.time_letter_spacing
            }
        }
    }
}
