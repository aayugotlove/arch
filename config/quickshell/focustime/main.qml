import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "." // Imports the parent directory to access Colors.qml

ShellRoot {
    id: root

    property string selectedDate: Qt.formatDate(new Date(), "yyyy-MM-dd")
    property string selectedApp: ""

    property var stats: ({
        selected_date: "",
        total: 0,
        average: 0,
        yesterday: 0,
        apps: [],
        week: [],
        week_apps: [],
        month: [],
        hourly: [],
        peak_usage_str: "N/A"
    })

    // ─────────────────────────────────────────────
    // Palette (Matugen MD3 Dynamic Colors)
    // ─────────────────────────────────────────────

    readonly property string accent: Colors.md3.primary
    readonly property string accentSoft: Colors.md3.primary_container
    readonly property string onAccentSoft: Colors.md3.on_primary_container
    readonly property string textPrimary: Colors.md3.on_surface
    readonly property string textSecondary: Colors.md3.on_surface_variant
    readonly property string textMuted: Colors.md3.outline

    readonly property string panelBg: Colors.md3.surface
    readonly property string cardBg: Colors.md3.surface_container_low
    readonly property string cardBg2: Colors.md3.surface_container
    readonly property string border: Colors.md3.outline_variant
    readonly property string borderSoft: Colors.md3.surface_variant
    readonly property string track: Colors.md3.surface_container_highest
    readonly property string barDim: Colors.md3.surface_variant

    // ─────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────

    function pad(n) {
        return n < 10 ? "0" + n : "" + n
    }

    function dateFromString(s) {
        let p = s.split("-")
        return new Date(
            Number(p[0]),
            Number(p[1]) - 1,
            Number(p[2]),
            12, 0, 0
        )
    }

    function dateString(d) {
        return d.getFullYear()
             + "-"
             + pad(d.getMonth() + 1)
             + "-"
             + pad(d.getDate())
    }

    function formatTime(seconds) {
        seconds = Number(seconds || 0)

        if (seconds < 60)
            return Math.round(seconds) + "s"

        let hours = Math.floor(seconds / 3600)
        let minutes = Math.floor((seconds % 3600) / 60)

        if (hours > 0)
            return hours + "h " + minutes + "m"

        return minutes + "m"
    }

    function formatLongTime(seconds) {
        seconds = Number(seconds || 0)

        let hours = Math.floor(seconds / 3600)
        let minutes = Math.floor((seconds % 3600) / 60)
        let secs = Math.floor(seconds % 60)

        if (hours > 0)
            return hours + "h " + minutes + "m"

        if (minutes > 0)
            return minutes + "m " + secs + "s"

        return secs + "s"
    }

    function dateLabel() {
        let d = dateFromString(selectedDate)
        let today = new Date()
        let todayString = dateString(today)

        let yesterday = new Date(
            today.getFullYear(),
            today.getMonth(),
            today.getDate() - 1,
            12
        )

        if (selectedDate === todayString)
            return "Today"

        if (selectedDate === dateString(yesterday))
            return "Yesterday"

        return Qt.formatDate(d, "ddd, d MMM")
    }

    function monthLabel() {
        return Qt.formatDate(
            dateFromString(selectedDate),
            "MMMM yyyy"
        )
    }

    function shiftDay(delta) {
        let d = dateFromString(selectedDate)
        d.setDate(d.getDate() + delta)

        selectedDate = dateString(d)
        selectedApp = ""

        refreshStats()
    }

    function jumpToDate(s) {
        if (!s || s.length !== 10)
            return

        selectedDate = s
        selectedApp = ""

        refreshStats()
    }

    function refreshStats() {
        let args = [
            "python3",
            Quickshell.env("HOME") + "/.config/quickshell/focustime/get_stats.py",
            selectedDate
        ]

        if (selectedApp !== "")
            args.push("--app", selectedApp)

        statsProcess.exec(args)
    }

    function openApp(appClass) {
        selectedApp = appClass
        refreshStats()
    }

    function closeApp() {
        selectedApp = ""
        refreshStats()
    }

    function selectedAppInfo() {
        let list = stats.apps || []

        for (let i = 0; i < list.length; i++) {
            if (list[i].class === selectedApp)
                return list[i]
        }

        return {
            class: selectedApp,
            name: selectedApp,
            seconds: 0,
            percent: 0,
            icon: ""
        }
    }

    function weeklyAppTotal() {
        let list = stats.week_apps || []
        let total = 0

        for (let i = 0; i < list.length; i++) {
            if (list[i].class === selectedApp)
                return Number(list[i].seconds || 0)
        }

        return total
    }

    function getIconSource(iconName, appClass) {
        if (appClass === "Desktop") return "image://icon/user-desktop"
        if (appClass === "Locked") return "image://icon/system-lock-screen"
        if (!iconName) return ""
        return String(iconName).includes("/") ? "file://" + iconName : "image://icon/" + iconName
    }

    // ─────────────────────────────────────────────
    // Data
    // ─────────────────────────────────────────────

    Process {
        id: statsProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.stats = JSON.parse(this.text)
                } catch (e) {
                    console.log("FocusTime JSON error:", e)
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: root.selectedApp === ""
        repeat: true

        onTriggered: root.refreshStats()
    }

    Component.onCompleted: root.refreshStats()

    // ─────────────────────────────────────────────
    // Window
    // ─────────────────────────────────────────────

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        color: "transparent"

        Rectangle {
            id: panel

            // Slightly wider and taller for expressive breathing room
            width: 940
            height: 740

            anchors.centerIn: parent

            // M3 Extra Large shape
            radius: 32

            color: root.panelBg
            border.width: 1
            border.color: root.border

            // ─────────────────────────────────────
            // Header
            // ─────────────────────────────────────

            RowLayout {
                id: header

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right

                    topMargin: 24
                    leftMargin: 24
                    rightMargin: 24
                }

                height: 48
                spacing: 12

                // Fully rounded navigation button
                Rectangle {
                    width: 42
                    height: 42
                    radius: width / 2

                    color: previousMouse.containsMouse ? root.cardBg2 : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -2
                        text: "‹"
                        color: root.accent
                        font.pixelSize: 34
                    }

                    MouseArea {
                        id: previousMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.selectedApp !== "")
                                root.closeApp()
                            else
                                root.shiftDay(-1)
                        }
                    }
                }

                Text {
                    text: root.selectedApp === "" ? "Focus Time" : root.selectedAppInfo().name
                    color: root.textPrimary
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }

                // Prominent Pill-shaped Date Indicator
                Rectangle {
                    width: 140
                    height: 40
                    radius: height / 2
                    color: root.accentSoft

                    Text {
                        anchors.centerIn: parent
                        text: root.dateLabel()
                        // Use on-primary-container token if available, falling back to accent
                        color: root.onAccentSoft || root.accent
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selectedApp = ""
                            root.selectedDate = root.dateString(new Date())
                            root.refreshStats()
                        }
                    }
                }

                // Fully rounded navigation button
                Rectangle {
                    width: 42
                    height: 42
                    radius: width / 2

                    color: nextMouse.containsMouse ? root.cardBg2 : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -2
                        text: "›"
                        color: root.accent
                        font.pixelSize: 34
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.selectedApp === "")
                                root.shiftDay(1)
                        }
                    }
                }
            }

            // ─────────────────────────────────────
            // Main dashboard
            // ─────────────────────────────────────

            Item {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom

                    topMargin: 20
                    leftMargin: 24
                    rightMargin: 24
                    bottomMargin: 24
                }

                opacity: root.selectedApp === "" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

                // Metrics
                RowLayout {
                    id: metrics

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: 90
                    spacing: 16

                    Repeater {
                        model: [
                            { title: "USED", value: root.formatTime(root.stats.total) },
                            { title: "WEEK AVG", value: root.formatTime(root.stats.average) },
                            { title: "PEAK", value: root.stats.peak_usage_str || "N/A" }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            radius: 24
                            color: root.cardBg2
                            border.width: 1
                            border.color: root.border

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.title
                                    color: root.textMuted
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.value
                                    color: root.accent
                                    font.pixelSize: modelData.title === "PEAK" ? 18 : 32
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }

                // Graph row
                RowLayout {
                    id: graphRow

                    anchors {
                        top: metrics.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: 16
                    }

                    height: 190 
                    spacing: 16

                    // Weekly chart
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 24
                        color: root.cardBg
                        border.width: 1
                        border.color: root.border

                        Text {
                            anchors {
                                top: parent.top
                                left: parent.left
                                topMargin: 16
                                leftMargin: 20
                            }
                            text: "This week"
                            color: root.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Row {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                                leftMargin: 24
                                rightMargin: 24
                                bottomMargin: 16
                            }

                            height: 110
                            spacing: 14

                            Repeater {
                                model: root.stats.week || []

                                delegate: Column {
                                    width: 42
                                    height: 110
                                    spacing: 8

                                    Item {
                                        width: 42
                                        height: 82

                                        Rectangle {
                                            property real maxValue: {
                                                let max = 1
                                                for (let i = 0; i < root.stats.week.length; i++) {
                                                    max = Math.max(max, Number(root.stats.week[i].total))
                                                }
                                                return max
                                            }

                                            width: 22
                                            height: Number(modelData.total) > 0 ? Math.max(6, Math.min(82, (Number(modelData.total) / maxValue) * 82)) : 6
                                            
                                            Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutQuart } }

                                            anchors.bottom: parent.bottom
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            radius: width / 2
                                            color: modelData.is_target ? root.accent : root.barDim

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.jumpToDate(modelData.date)
                                            }
                                        }
                                    }

                                    Text {
                                        width: 42
                                        text: modelData.day
                                        horizontalAlignment: Text.AlignHCenter
                                        color: modelData.is_target ? root.accent : root.textSecondary
                                        font.pixelSize: 11
                                        font.weight: modelData.is_target ? Font.Bold : Font.Normal
                                    }
                                }
                            }
                        }
                    }

                    // Calendar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: 24
                        color: root.cardBg
                        border.width: 1
                        border.color: root.border

                        Text {
                            anchors {
                                top: parent.top
                                horizontalCenter: parent.horizontalCenter
                                topMargin: 16
                            }
                            text: root.monthLabel()
                            color: root.textPrimary
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }

                        Row {
                            anchors {
                                top: parent.top
                                horizontalCenter: parent.horizontalCenter
                                topMargin: 44
                            }
                            spacing: 16 

                            Repeater {
                                model: ["M", "T", "W", "T", "F", "S", "S"]
                                Text {
                                    width: 16 
                                    text: modelData
                                    horizontalAlignment: Text.AlignHCenter
                                    color: root.textMuted
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }
                        }

                        Grid {
                            anchors {
                                top: parent.top
                                horizontalCenter: parent.horizontalCenter
                                topMargin: 66
                            }
                            columns: 7
                            rowSpacing: 8
                            columnSpacing: 16

                            Repeater {
                                model: root.stats.month || []

                                Rectangle {
                                    width: 16 
                                    height: 16 
                                    // Make dots fully circular for M3
                                    radius: width / 2

                                    color: modelData.total < 0 ? "transparent"
                                         : modelData.is_target ? root.accent
                                         : modelData.total > 0 ? root.barDim
                                         : root.track

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: modelData.date !== ""
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.jumpToDate(modelData.date)
                                    }
                                }
                            }
                        }
                    }
                }

                // Applications
                Rectangle {
                    id: appsCard

                    anchors {
                        top: graphRow.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        topMargin: 16
                    }

                    radius: 24
                    color: root.cardBg
                    border.width: 1
                    border.color: root.border

                    Text {
                        anchors {
                            top: parent.top
                            left: parent.left
                            topMargin: 18
                            leftMargin: 20
                        }
                        text: "Applications"
                        color: root.textPrimary
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                    }

                    Flickable {
                        id: appsFlickable
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            topMargin: 56
                            leftMargin: 20
                            rightMargin: 20
                            bottomMargin: 20
                        }
                        
                        clip: true
                        contentHeight: appsColumn.height
                        boundsBehavior: Flickable.StopAtBounds

                        WheelHandler {
                            onWheel: (event) => {
                                let moveDist = event.angleDelta.y; 
                                appsFlickable.contentY = Math.max(0, Math.min(appsFlickable.contentHeight - appsFlickable.height, appsFlickable.contentY - moveDist));
                            }
                        }

                        Behavior on contentY {
                            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 8
                            contentItem: Rectangle {
                                implicitWidth: 8
                                radius: 4
                                color: root.barDim
                            }
                        }

                        Column {
                            id: appsColumn
                            width: parent.width - 12 
                            spacing: 12

                            Repeater {
                                model: root.stats.apps || []

                                delegate: Rectangle {
                                    width: appsColumn.width
                                    height: 64
                                    radius: 16

                                    color: appMouse.containsMouse ? root.cardBg2 : "transparent"
                                    Behavior on color { ColorAnimation { duration: 150 } }

                                    MouseArea {
                                        id: appMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.openApp(modelData.class)
                                    }

                                    RowLayout {
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            topMargin: 10
                                            leftMargin: 14
                                            rightMargin: 14
                                        }

                                        height: 32
                                        spacing: 16

                                        Image {
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            sourceSize: Qt.size(32, 32)
                                            source: root.getIconSource(modelData.icon, modelData.class)
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            visible: source.toString() !== ""
                                        }

                                        Text {
                                            text: modelData.name
                                            color: root.textPrimary
                                            font.pixelSize: 14
                                            font.weight: Font.DemiBold
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: root.formatTime(modelData.seconds)
                                            color: root.textSecondary
                                            font.pixelSize: 12
                                        }

                                        // Placed share inside an expressive primary container tag
                                        Rectangle {
                                            Layout.preferredWidth: 48
                                            Layout.preferredHeight: 22
                                            radius: 11
                                            color: root.accentSoft

                                            Text {
                                                anchors.centerIn: parent
                                                text: Number(modelData.percent || 0).toFixed(1) + "%"
                                                color: root.onAccentSoft || root.accent
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                            }
                                        }
                                    }

                                    // Thicker, more rounded progress indicator
                                    Rectangle {
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            bottom: parent.bottom
                                            leftMargin: 14
                                            rightMargin: 14
                                            bottomMargin: 10
                                        }

                                        height: 6
                                        radius: height / 2
                                        color: root.track

                                        Rectangle {
                                            width: parent.width * Number(modelData.percent || 0) / 100
                                            height: parent.height
                                            radius: height / 2
                                            color: root.accent

                                            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutQuart } }
                                        }
                                    }
                                }
                            }

                            Text {
                                visible: !root.stats.apps || root.stats.apps.length === 0
                                text: "No activity recorded on this day."
                                color: root.textMuted
                                leftPadding: 14
                                topPadding: 14
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }

            // ─────────────────────────────────────
            // Application detail
            // ─────────────────────────────────────

            Item {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom

                    topMargin: 20
                    leftMargin: 24
                    rightMargin: 24
                    bottomMargin: 24
                }

                opacity: root.selectedApp !== "" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

                // App identity
                Rectangle {
                    id: appIdentity

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    height: 80
                    radius: 24
                    color: root.cardBg
                    border.width: 1
                    border.color: root.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 24
                        spacing: 16

                        Image {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            sourceSize: Qt.size(48, 48)
                            source: root.getIconSource(root.selectedAppInfo().icon, root.selectedAppInfo().class)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: source.toString() !== ""
                        }

                        Column {
                            spacing: 4
                            Layout.fillWidth: true

                            Text {
                                text: root.selectedAppInfo().name
                                color: root.textPrimary
                                font.pixelSize: 20
                                font.weight: Font.Bold
                            }

                            Text {
                                text: root.dateLabel() + " · " + root.selectedApp
                                color: root.textSecondary
                                font.pixelSize: 12
                            }
                        }

                        Text {
                            text: root.formatLongTime(root.selectedAppInfo().seconds)
                            color: root.accent
                            font.pixelSize: 24
                            font.weight: Font.Bold
                        }
                    }
                }

                // Detail metrics
                RowLayout {
                    id: detailMetrics

                    anchors {
                        top: appIdentity.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: 16
                    }

                    height: 90
                    spacing: 16

                    Repeater {
                        model: [
                            { title: "USED", value: root.formatLongTime(root.selectedAppInfo().seconds) },
                            { title: "WEEK TOTAL", value: root.formatTime(root.weeklyAppTotal()) },
                            { title: "SHARE", value: Number(root.selectedAppInfo().percent || 0).toFixed(1) + "%" },
                            { title: "PEAK", value: root.stats.peak_usage_str || "N/A" }
                        ]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            radius: 24
                            color: root.cardBg2
                            border.width: 1
                            border.color: root.border

                            Column {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.title
                                    color: root.textMuted
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.value
                                    color: root.accent
                                    font.pixelSize: modelData.title === "PEAK" ? 14 : 20
                                    font.weight: Font.Bold
                                }
                            }
                        }
                    }
                }

                // Activity
                Rectangle {
                    id: activityCard

                    anchors {
                        top: detailMetrics.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: 16
                    }

                    height: 240
                    radius: 24
                    color: root.cardBg
                    border.width: 1
                    border.color: root.border

                    Text {
                        anchors {
                            top: parent.top
                            left: parent.left
                            topMargin: 18
                            leftMargin: 20
                        }
                        text: "Activity by time"
                        color: root.textPrimary
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    Text {
                        anchors {
                            top: parent.top
                            right: parent.right
                            topMargin: 20
                            rightMargin: 20
                        }
                        text: "24h"
                        color: root.textMuted
                        font.pixelSize: 11
                    }

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                            leftMargin: 24
                            rightMargin: 24
                            bottomMargin: 42
                        }

                        height: 110
                        spacing: 8

                        Repeater {
                            model: 24

                            delegate: Item {
                                width: (parent.width - 184) / 24
                                height: 110

                                property real value: {
                                    let a = Number(root.stats.hourly[index * 2] || 0)
                                    let b = Number(root.stats.hourly[index * 2 + 1] || 0)
                                    return a + b
                                }

                                property real maxValue: {
                                    let max = 1
                                    for (let i = 0; i < 48; i++) {
                                        max = Math.max(max, Number(root.stats.hourly[i] || 0))
                                    }
                                    return max
                                }

                                Rectangle {
                                    width: 14
                                    height: parent.value > 0 ? Math.max(10, Math.min(84, (parent.value / parent.maxValue) * 84)) : 6
                                    
                                    Behavior on height { NumberAnimation { duration: 400; easing.type: Easing.OutQuart } }

                                    anchors.bottom: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    radius: width / 2
                                    color: parent.value > 0 ? root.accent : root.barDim
                                }

                                Text {
                                    visible: index % 4 === 0
                                    anchors {
                                        top: parent.bottom
                                        topMargin: 10
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    text: index + ":00"
                                    color: root.textMuted
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    height: 72
                    radius: 24
                    color: root.cardBg2
                    border.width: 1
                    border.color: root.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        anchors.rightMargin: 24

                        Text {
                            text: "Weekly total"
                            color: root.textSecondary
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.formatTime(root.weeklyAppTotal())
                            color: root.accent
                            font.pixelSize: 22
                            font.weight: Font.Bold
                        }
                    }
                }
            }
        }
    }
}
