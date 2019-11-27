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

// onUserPannedChanged: {
//     if (userPanned) {
//         console.log("user panned")
//         userPanned = false
//         _disableVehicleTracking = true
//         panRecenterTimer.restart()
//     }
// }


Item {
    id: qhroot
    Rectangle {

        // Prevent all clicks from going through to lower layers
        DeadMouseArea {
            anchors.fill: parent
        }

        id: qhgovernor

        height: 170
        width: 350
        radius: 1

        anchors.bottom: parent.bottom
        anchors.right: parent.right

        color: Qt.darker("grey",5.0)
        
        GridLayout {
            id:                 qhinstrumentsgrid
            columnSpacing:      ScreenTools.defaultFontPixelWidth
            columns:            3
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 5

            //Voltage Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 1
                text: qsTr("Voltage:") 
            }

            QHProgressBar {
                
                id: progressbarvoltage
                
                //Position parameters
                Layout.column: 2
                Layout.row: 1

                //Values and conditions
                minimumValue: 42
                maximumValue: 51   
                indeterminate: (_activeVehicle && _activeVehicle.battery.voltage.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.voltage.value !== -1) ? _activeVehicle.battery.voltage.value : 0

                //This logic should be in a Controller interface. For speed pourpouses it will be first implemented here
                valueType: {
                    if(_activeVehicle && _activeVehicle.battery.voltage.value !== -1 ){
                        if (_activeVehicle.battery.voltage.value <= 48 && _activeVehicle.battery.voltage.value >= 46)
                        return "warning"
                        if (_activeVehicle.battery.voltage.value < 46)
                        return "critical"
                    }
                    return "normal"
                }
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 1
                text: (_activeVehicle && _activeVehicle.battery.voltage.value != -1) ? (_activeVehicle.battery.voltage.valueString + " " + _activeVehicle.battery.voltage.units) : "N/A" 
            }

            //Battery current  Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 2
                text: qsTr("Battery current:") 
            }

            //ProgressBar for the negative side of Battery Current
            ProgressBar {

                Layout.column: 2
                Layout.row: 2

                Layout.preferredHeight: 10
                Layout.preferredWidth: 60

                minimumValue: 0
                maximumValue: 20 //Max current the battereis are supposed to charge to is 10A

                indeterminate: (_activeVehicle && _activeVehicle.battery.current.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.current.value !== -1 && _activeVehicle.battery.current.value < 0) ? (20 +_activeVehicle.battery.current.value) : 20
                
                style: ProgressBarStyle {

                    background: Rectangle{
                        radius: 1
                        color: "red"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }

                    progress: Rectangle{
                        color: "lightgrey"
                    }

                    
                }
            }

            //ProgressBar for the positive side  of Battery Current
            ProgressBar {

                Layout.column: 2
                Layout.row: 2

                Layout.preferredHeight: 10
                Layout.preferredWidth: 60
                Layout.leftMargin: 60

                minimumValue: 0
                maximumValue: 20 //Max current the battereis are supposed to charge to is 10A

                indeterminate: (_activeVehicle && _activeVehicle.battery.current.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.current.value !== -1 && _activeVehicle.battery.current.value >= 0) ? (_activeVehicle.battery.current.value) : 0

                style: ProgressBarStyle {

                    background: Rectangle{
                        radius: 1
                        color: "lightgrey"
                        implicitWidth: parent.Layout.preferredWidth
                        implicitHeight: parent.Layout.preferredHeight
                    }

                    progress: Rectangle{
                        color: "green"
                    }

                   
                }
            }                                                                                                                                                                                                                                                                                                                                                                            


            QGCLabel { 
                Layout.column: 3
                Layout.row: 2
                text: (_activeVehicle && _activeVehicle.battery.current.value != -1) ? (_activeVehicle.battery.current.valueString + " " + _activeVehicle.battery.current.units) : "N/A"
             }
            
            //Generator current  Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 3
                text: qsTr("Generator current:") 
            }

            QHProgressBar {

                id: progressbargenerator

                //Position parameters
                Layout.column: 2
                Layout.row: 3
                
                //Values and conditions
                maximumValue: 50    //Max current the generator produces is 50A
                indeterminate: (_activeVehicle && _activeVehicle.battery.current_generator.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.current_generator.value !== -1) ? _activeVehicle.battery.current_generator.value : 0
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 3
                text: (_activeVehicle && _activeVehicle.battery.current_generator.value != -1) ? (_activeVehicle.battery.current_generator.valueString + " A" + _activeVehicle.battery.current_generator.units) : "N/A"
             }

            //Motors current display  Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 5
                text: qsTr("Motors current:")
            }

            QHProgressBar {

                id: progressbarrotor

                valueType: "normal" //This progressBar will always be green

                //Position parameters
                Layout.column: 2
                Layout.row: 5
                
                //Values and conditions
                maximumValue: 55    //Max current consumed by the motors has been recorded to be 55A
                indeterminate: (_activeVehicle && _activeVehicle.battery.current_rotor.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle && _activeVehicle.battery.current_rotor.value !== -1) ? _activeVehicle.battery.current_rotor.value : 0
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 5
                text: (_activeVehicle && _activeVehicle.battery.current_rotor.value != -1) ? (_activeVehicle.battery.current_rotor.valueString + " A") : "N/A" 
            }

            //Total Power  Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 6
                text: qsTr("Power:")
            }

            QHProgressBar {

                id: progresspower

                valueType: "normal" //This progressBar will always be green

                //Position parameters
                Layout.column: 2
                Layout.row: 6
                
                //Values and conditions
                maximumValue: 2750    //Max power 2750 W
                indeterminate: (_activeVehicle && _activeVehicle.battery.current_generator.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.current_generator.value != -1) ? (_activeVehicle.battery.current_generator.value * _activeVehicle.battery.voltage.value) : 0
            }

            QGCLabel { 
                Layout.column: 3
                Layout.row: 6
                text: (_activeVehicle && _activeVehicle.battery.current_generator.value != -1) ? ((_activeVehicle.battery.current_generator.value * _activeVehicle.battery.voltage.value) + " W") : "N/A" 
            }

            //Fuel level Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 7
                text: qsTr("Fuel level:") 
            }

            QHProgressBar {

                id: progressbarfuel

                //Position parameters
                Layout.column: 2
                Layout.row: 7
                
                //Values and conditions
                maximumValue: 5000  //Max capacity of the fuel tank is 5000ml
                indeterminate: (_activeVehicle && _activeVehicle.battery.fuel_level.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle && _activeVehicle.battery.fuel_level.value !== -1) ? _activeVehicle.battery.fuel_level.value : 0

                //This logic should be in a Controller interface. For speed pourpouses it will be first implemented here
                valueType: {
                    if(_activeVehicle && _activeVehicle.battery.fuel_level.value !== -1 ){
                        if (_activeVehicle.battery.fuel_level.value < 500)
                        return "critical"
                        if (_activeVehicle.battery.fuel_level.value >= 500 && _activeVehicle.battery.fuel_level.value < 1000)
                        return "warning"
                    }
                    return "normal"
                }
                
            }
            
            QGCLabel { 
                Layout.column: 3
                Layout.row: 7
                text: (_activeVehicle && _activeVehicle.battery.fuel_level.value != -1) ? (_activeVehicle.battery.fuel_level.valueString + " ml") : "N/A" 
            }

            //Throttle percentage Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 8
                text: qsTr("Throttle percentage:") 
            }

            QHProgressBar {

                id: progressbarthrottle

                //Position parameters
                Layout.column: 2
                Layout.row: 8
                
                //Values and conditions
                maximumValue: 100
                indeterminate: (_activeVehicle && _activeVehicle.battery.throttle_percentage.value !== -1) ? false : true
                value: (_activeVehicle && _activeVehicle.battery.throttle_percentage.value !== -1) ? _activeVehicle.battery.throttle_percentage.value : 0
            
                //This logic should be in a Controller interface. For speed pourpouses it will be first implemented here
                valueType: {
                    if(_activeVehicle && _activeVehicle.battery.throttle_percentage.value !== -1 ){
                        if (_activeVehicle.battery.throttle_percentage.value >= 90)
                        return "critical"
                        if (_activeVehicle.battery.throttle_percentage.value >= 85 && _activeVehicle.battery.throttle_percentage.value < 90)
                        return "warning"
                    }
                    return "normal"
                }
            }
            
            QGCLabel { 
                Layout.column: 3
                Layout.row: 8
                text: (_activeVehicle && _activeVehicle.battery.throttle_percentage.value != -1) ? (_activeVehicle.battery.throttle_percentage.valueString + " %") : "N/A" 
            }
        }
    }

    Rectangle {

        
        visible: false //Earase this line once we introduce EFI messages
        
        // Prevent all clicks from going through to lower layers
        DeadMouseArea {
            anchors.fill: parent
        }
        
        id: qhefi
        
        height: 150
        width: 100

        anchors.bottom: qhgovernor.top
        anchors.bottomMargin: 5
        anchors.right: qhgovernor.right

        color: Qt.darker("grey",5.0)
        radius: 1

        GridLayout {

            id: ghefigrid

            columnSpacing:      ScreenTools.defaultFontPixelWidth
            columns:            2
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 5

            //RPM Display
            QGCLabel { 
                Layout.column: 1
                Layout.row: 1
                text: qsTr("RPM:") 
            }

            QGCLabel { 
                Layout.column: 2
                Layout.row: 1
                //text: (_activeVehicle && _activeVehicle. != -1) ? (_activeVehicle. + " %") : "N/A" 
                text: "N/A"
            }

            //TPS Display
            QGCLabel { 
                Layout.column:1
                Layout.row: 2
                text: qsTr("TPS:") 
            }

            QGCLabel { 
                Layout.column: 2
                Layout.row: 2
                //text: (_activeVehicle && _activeVehicle. != -1) ? (_activeVehicle. + " %") : "N/A" 
                text: "N/A"
            }

            //CLT Display
            QGCLabel { 
                Layout.column:1
                Layout.row: 3
                text: qsTr("CLT:") 
            }

            QGCLabel { 
                Layout.column: 2
                Layout.row: 3
                //text: (_activeVehicle && _activeVehicle. != -1) ? (_activeVehicle. + " %") : "N/A" 
                text: "N/A"
            }

            //MAT Display
            QGCLabel { 
                Layout.column:1
                Layout.row: 4
                text: qsTr("MAT:") 
            }

            QGCLabel { 
                Layout.column: 2
                Layout.row: 4
                //text: (_activeVehicle && _activeVehicle. != -1) ? (_activeVehicle. + " %") : "N/A" 
                text: "N/A"
            }

            //PMS Display
            QGCLabel { 
                Layout.column:1
                Layout.row: 5
                text: qsTr("PMS:") 
            }

            QGCLabel { 
                Layout.column: 2
                Layout.row: 5
                //text: (_activeVehicle && _activeVehicle. != -1) ? (_activeVehicle. + " %") : "N/A" 
                text: "N/A"
            }

            //EFI Voltage Display
            QGCLabel { 
                Layout.column:1
                Layout.row: 6
                text: qsTr("VOL:") 
            }

            QGCLabel { 
                Layout.column: 2
                Layout.row: 6
                //text: (_activeVehicle && _activeVehicle. != -1) ? (_activeVehicle. + " %") : "N/A" 
                text: "N/A"
            }




        }


    }
}