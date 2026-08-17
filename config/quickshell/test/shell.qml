import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
        }

        width: 400
        height: 200

        color: "#202020"

        Text {
            anchors.centerIn: parent
            text: "Quickshell works!"
            color: "white"
            font.pixelSize: 24
        }
    }
}
