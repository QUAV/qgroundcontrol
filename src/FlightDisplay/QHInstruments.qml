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


Rectangle {
    id: qhroot

    property real size:     _defaultSize
    property var  vehicle:  null
    property real _defaultSize: ScreenTools.defaultFontPixelHeight * (15)
    property real _sizeRatio:   ScreenTools.isTinyScreen ? (size / _defaultSize) * 0.5 : size / _defaultSize
    property int  _fontSize:    ScreenTools.defaultFontPointSize * _sizeRatio

    property real _radiusScale: 0.5

    property int numberOfParameters: 6
    property int padding: 0
    width:    getCustomWindowWidth()// size
    height:   ScreenTools.defaultFontPixelHeight * (numberOfParameters + padding)
    radius:   ScreenTools.defaultFontPixelHeight*_radiusScale

    function getCustomWindowWidth() {
        // Don't allow instrument panel to chew more than 1/4 of full window
        var defaultWidth = ScreenTools.defaultFontPixelWidth * 30
        var maxWidth = mainWindow.width * 0.25
        return Math.min(maxWidth, defaultWidth)
    }

    function getBarWidth() {
        var defaultWidth = 20 * ScreenTools.smallFontPointSize
        var maxWidth = getCustomWindowWidth()*0.32  //mainWindow.width * 0.07
        return Math.min(maxWidth, defaultWidth)
    }

    // Prevent all clicks from going through to lower layers
    DeadMouseArea {
        anchors.fill: parent
    }

    Rectangle {

        id: qhgovernor

        anchors.fill: parent
        width:  parent.width
        radius:   ScreenTools.defaultFontPixelHeight*_radiusScale
        color:  qgcPal.window

        GridLayout {
            id:                 qhinstrumentsgrid
            columnSpacing:      ScreenTools.defaultFontPixelWidth
            columns:            3
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.leftMargin: ScreenTools.defaultFontPixelWidth
            anchors.topMargin: ScreenTools.defaultFontPixelHeight

            //Voltage Display
            QGCLabel {
                Layout.column: 1
                Layout.row: 1
                text: qsTr("Voltage:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            QGCLabel {
                Layout.column: 2
                Layout.row: 1
                text: (activeVehicle && activeVehicle.battery.voltage.value != -1) ? (activeVehicle.battery.voltage.valueString + " " + activeVehicle.battery.voltage.units) : "N/A"
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            //Battery current  Display
            QGCLabel {
                Layout.column: 1
                Layout.row: 2
                text: qsTr("Battery current:")
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
            }

            //ProgressBar for the negative side of Battery Current
            QHProgressBar {

                id: progressbarcurrent

                Layout.column: 2
                Layout.row: 2

                //Values and conditions
                maximumValue: 70    //Max current ever recorded in a peak was 55A
                indeterminate: (activeVehicle && activeVehicle.battery.current.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle.battery.current.value !== -1) ? activeVehicle.battery.current.value : 0

                style: ProgressBarStyle{
                    progress: Rectangle {
                        color: "#5bb85d"
                        //border.color: "darkred"
                        /*gradient: Gradient{
                          GradientStop { position: 0.0; color: "#f8306a" }
                        GradientStop { position: 1.0; color: "#fb5b40" }
                      }*/
                    }
                }
            }



            QGCLabel {
                Layout.column: 3
                Layout.row: 2
                text: (activeVehicle && activeVehicle.battery.current.value != -1) ? (activeVehicle.battery.current.valueString + " " + activeVehicle.battery.current.units) : "N/A"
                font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
                fontSizeMode:           Text.HorizontalFit
             }

            //Generator current  Display
            QGCLabel {
                Layout.column: 1
                Layout.row: 3
                text: qsTr("Generator current:")
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
                indeterminate: (activeVehicle && activeVehicle.battery.current_generator.value !== -1) ? false : true
                value: (activeVehicle && activeVehicle.battery.current_generator.value !== -1) ? activeVehicle.battery.current_generator.value : 0

                style: ProgressBarStyle{
                    /*background: Rectangle {
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }*/
                    progress: Rectangle {
                        color: "#5bbfde" //blue
                        //border.color: "darkred"
                    }
                }
            }

            QGCLabel {
                Layout.column: 3
                Layout.row: 3
                text: (activeVehicle && activeVehicle.battery.current_generator.value != -1) ? (activeVehicle.battery.current_generator.valueString + " A" + activeVehicle.battery.current_generator.units) : "N/A"
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
                 minimumValue: -15   //Current provided by governor to batteries is limited to 15A
                 maximumValue: 15    //Current provided by governor to batteries is limited to 15A
                 indeterminate: (activeVehicle && activeVehicle.battery.current_rotor.value !== -1) ? false : true
                 value: (activeVehicle && activeVehicle && activeVehicle.battery.current_rotor.value !== -1) ? activeVehicle.battery.current_rotor.value : 0

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
                 text: (activeVehicle && activeVehicle.battery.current_rotor.value != -1) ? (activeVehicle.battery.current_rotor.valueString + " " + activeVehicle.battery.current_rotor.units) : "N/A"
                 font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
             }

             QGCLabel {
                 Layout.column: 1
                 Layout.row: 6
                 text: qsTr("Fuel level:")
                 font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
             }

             ProgressBar {
                 id: progressbarfuel

                 //Position parameters
                 Layout.column: 2
                 Layout.row: 6
                 Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
                 Layout.preferredWidth: getBarWidth() //10 * ScreenTools.smallFontPointSize


                 //Values and conditions
                 maximumValue: 5000  //Max capacity of the fuel tank is 5000ml
                 indeterminate: (activeVehicle && activeVehicle.battery.fuel_level.value !== -1) ? false : true
                 value: (activeVehicle && activeVehicle && activeVehicle.battery.fuel_level.value !== -1) ? activeVehicle.battery.fuel_level.value : 0

                 style: ProgressBarStyle{
                     background: Rectangle {
                         radius: 1
                         color: "lightgrey"
                         implicitWidth: parent.Layout.preferredWidth
                         implicitHeight: parent.Layout.preferredHeight
                     }
                     progress: Rectangle {
                         color: "#efae4d" //yellow
                         //border.color: "green"
                     }
                 }
             }

             QGCLabel {
                 Layout.column: 3
                 Layout.row: 6
                 text: (activeVehicle && activeVehicle.battery.fuel_level.value != -1) ? (activeVehicle.battery.fuel_level.valueString + " " + activeVehicle.battery.fuel_level.units) : "N/A"
                 font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
             }

             QGCLabel {
                 Layout.column: 1
                 Layout.row: 7
                 text: qsTr("Throttle percentage:")
                 font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
             }

             ProgressBar {
                 id: progressbarthrottle

                 //Position parameters
                 Layout.column: 2
                 Layout.row: 7
                 Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.5
                 Layout.preferredWidth: getBarWidth() //10 * ScreenTools.smallFontPointSize

                 //Values and conditions
                 maximumValue: 2000
                 indeterminate: (activeVehicle && activeVehicle.battery.throttle_percentage.value !== -1) ? false : true
                 value: (activeVehicle && activeVehicle && activeVehicle.battery.throttle_percentage.value !== -1) ? activeVehicle.battery.throttle_percentage.value : 0

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
                 Layout.row: 7
                 text: (activeVehicle && activeVehicle.battery.throttle_percentage.value != -1) ? (activeVehicle.battery.throttle_percentage.valueString + " " + activeVehicle.battery.throttle_percentage.units) : "N/A"
                 font.pointSize: ScreenTools.isTinyScreen ? ScreenTools.smallFontPointSize * 0.75 : ScreenTools.smallFontPointSize
             }
         }
     }
 }
