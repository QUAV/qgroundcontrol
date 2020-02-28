import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Layouts          1.2
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0

import QtGraphicalEffects   1.0

// onUserPannedChanged: {
//     if (userPanned) {
//         console.log("user panned")
//         userPanned = false
//         _disableVehicleTracking = true
//         panRecenterTimer.restart()
//     }
// }


Rectangle { //Item

    id: qhroot

    property real size:     _defaultSize
    property var  vehicle:  null
    property real _defaultSize: ScreenTools.defaultFontPixelHeight * (15)
    property real _sizeRatio:   ScreenTools.isTinyScreen ? (size / _defaultSize) * 0.5 : size / _defaultSize
    property int  _fontSize:    ScreenTools.defaultFontPointSize * _sizeRatio

    property real _radiusScale: 0.5

    property int numberOfParameters: 6
    property int padding: 0
    width:    getCustomWindowWidth()*1.25
    height:   ScreenTools.defaultFontPixelHeight * (numberOfParameters + padding)
    radius:   ScreenTools.defaultFontPixelHeight*_radiusScale

    function getCustomWindowWidth() {
        // Don't allow instrument panel to chew more than 1/4 of full window
        var defaultWidth = ScreenTools.defaultFontPixelWidth * 30
        var maxWidth = mainWindow.width * 0.25
        return Math.min(maxWidth, defaultWidth)
    }

    function getBarWidth() {
        var defaultWidth = 45 * ScreenTools.smallFontPointSize
        var maxWidth = getCustomWindowWidth()*0.6  //mainWindow.width * 0.07
        return Math.min(maxWidth, defaultWidth)
    }

    // Prevent all clicks from going through to lower layers
    DeadMouseArea {
        anchors.fill: parent
    }

    Rectangle {

        id: qhrectangle
        anchors.fill: parent
        color:  qgcPal.window
        width:  parent.width
        radius:   ScreenTools.defaultFontPixelHeight*_radiusScale

        GridLayout {
            id:                 qhinstrumentsgrid
            columnSpacing:      ScreenTools.defaultFontPixelWidth
            columns:            3
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
            anchors.topMargin: ScreenTools.defaultFontPixelHeight

            QGCLabel {
                Layout.column: 1
                Layout.row: 1
                text: qsTr("Voltage:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            QGCLabel {
                Layout.column: 2
                Layout.row: 1
                text: (activeVehicle && activeVehicle.quaternium.voltage_battery.value != -1) ? (activeVehicle.quaternium.voltage_battery.valueString + " " + activeVehicle.quaternium.voltage_battery.units) : "N/A"
                font.pointSize:  ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize * 1.5

            }

            QGCLabel {
                Layout.column: 1
                Layout.row: 2
                text: qsTr("Current:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            /*-------------TEST-----------
            ProgressBar {
                id: progressbarcurrent

                //Position parameters
                Layout.column: 2
                Layout.row: 2
                Layout.preferredHeight: 10
                Layout.preferredWidth: 125

                //Values and conditions
                maximumValue: 70    //Max current ever recorded in a peak was 55A
                indeterminate: (activeVehicle && activeVehicle.battery.current.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle.battery.current.value !== -1) ? activeVehicle.battery.current.value : 0

                style: ProgressBarStyle{
                    background: Rectangle {
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }
                    progress: Rectangle {
                        color: "green"
                        border.color: "darkred"
                    }
                }
            }
            ------------TEST----------*/


            QHProgressBar {

                id: progressbarcurrent

                Layout.column: 2
                Layout.row: 2

                //Values and conditions
                maximumValue: 70    //Max current ever recorded in a peak was 55A
                indeterminate: (activeVehicle && activeVehicle.quaternium.current_battery.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle.quaternium.current_battery.value !== -1) ? activeVehicle.quaternium.current_battery.value : 0

                style: ProgressBarStyle{
                    progress: Rectangle {
                        color: "#5bb85d"
                        //border.color: "darkred"
                        /*gradient: Gradient{
                          GradientStop { position: 0.0; color: "#f8306a" }
                        GradientStop { position: 1.0; color: "#fb5b40" }
                      }*/
                    }
                    background: Rectangle {
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }
                }
            }


            QGCLabel {
                Layout.column: 3
                Layout.row: 2
                text: (activeVehicle && activeVehicle.quaternium.current_battery.value != -1) ? (activeVehicle.quaternium.current_battery.valueString + " " + activeVehicle.quaternium.current_battery.units) : "N/A"
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
                fontSizeMode:           Text.HorizontalFit
             }

            QGCLabel {
                Layout.column: 1
                Layout.row: 3
                text: qsTr("Current generator:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }


            ProgressBar {
                id: progressbargenerator

                //Position parameters
                Layout.column: 2
                Layout.row: 3
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5// ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize //10
                Layout.preferredWidth: getBarWidth() // 10 * ScreenTools.smallFontPointSize

                //Values and conditions
                maximumValue: 70    //Max current the generator produces is 50A
                indeterminate: (activeVehicle && activeVehicle.quaternium.current_generator.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle.quaternium.current_generator.value !== -1) ? activeVehicle.quaternium.current_generator.value : 0

                style: ProgressBarStyle{
                    background: Rectangle {
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }
                    progress: Rectangle {
                        color: "#5bbfde" //blue
                        //border.color: "darkred"
                    }
                }
            }

            QGCLabel {
                Layout.column: 3
                Layout.row: 3
                text: (activeVehicle && activeVehicle.quaternium.current_generator.value != -1) ? (activeVehicle.quaternium.current_generator.valueString + " " + activeVehicle.quaternium.current_generator.units) : "N/A"
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
             }


            QGCLabel {
                Layout.column: 1
                Layout.row: 5
                text: qsTr("Current rotor:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            ProgressBar {
                id: progressbarrotor

                //Position parameters
                Layout.column: 2
                Layout.row: 5
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
                Layout.preferredWidth: getBarWidth() //10 * ScreenTools.smallFontPointSize


                //Values and conditions
                minimumValue: -70   //Current provided by governor to batteries is limited to 15A
                maximumValue: 70    //Current provided by governor to batteries is limited to 15A
                indeterminate: (activeVehicle && activeVehicle.quaternium.current_rotor.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle && activeVehicle.quaternium.current_rotor.value !== -1) ? activeVehicle.quaternium.current_rotor.value : 0

                style: ProgressBarStyle{
                    background: Rectangle {
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }
                    progress: Rectangle {
                        color: "#3479b6"
                    }
                }
            }

            QGCLabel {
                Layout.column: 3
                Layout.row: 5
                text: (activeVehicle && activeVehicle.quaternium.current_rotor.value != -1) ? (activeVehicle.quaternium.current_rotor.valueString + " " + activeVehicle.quaternium.current_rotor.units) : "N/A"
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            QGCLabel {
                Layout.column: 1
                Layout.row: 6
                text: qsTr("Throttle percentage:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            ProgressBar {
                id: progressbarthrottle

                //Position parameters
                Layout.column: 2
                Layout.row: 6
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
                Layout.preferredWidth: getBarWidth() //10 * ScreenTools.smallFontPointSize

                //Values and conditions
                maximumValue: 100
                indeterminate: (activeVehicle && activeVehicle.quaternium.throttle_percentage.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle && activeVehicle.quaternium.throttle_percentage.value !== -1) ? activeVehicle.quaternium.throttle_percentage.value : 0

                style: ProgressBarStyle{
                    background: Rectangle {
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }
                    progress: Rectangle {
                        color: "#d9544f"// red "orchid"
                        //border.color: "yellow"
                    }
                }
            }

            QGCLabel {
                Layout.column: 3
                Layout.row: 6
                text: (activeVehicle && activeVehicle.quaternium.throttle_percentage.value != -1) ? (activeVehicle.quaternium.throttle_percentage.valueString + " " + activeVehicle.quaternium.throttle_percentage.units) : "N/A"
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }
        }
    }
}
