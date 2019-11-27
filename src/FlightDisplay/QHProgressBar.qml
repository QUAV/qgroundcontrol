/*
This is a custom progress bar for governor values
*/



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

ProgressBar {

    id: qhprogressbar

    //Properties (variable)
    property var valueType: ["normal", "warning", "critical"]

    //Common position parameters
    Layout.preferredHeight: 10
    Layout.preferredWidth: 120
                
    //Values and conditions need to be added especifically
                
    /*
    Style and colors for the progress bar. When a value goes from normal to critical it will change color from green
    to red and the bar will glow.
    */
    style: ProgressBarStyle{

        background: Rectangle {
            radius: 1
            color: "lightgrey"
            implicitWidth: parent.Layout.preferredWidth
            implicitHeight: parent.Layout.preferredHeight
        }

        progress: Rectangle {

            color: {
                if(qhprogressbar.valuetype !== null){
                    if(qhprogressbar.valueType === "normal")
                        return "green"
                    if(qhprogressbar.valueType === "warning")
                        return "orange"
                }
                return "red"
            }

            ColorAnimation on color {
                running: qhprogressbar.valueType === "critical"
                from: "red"
                to: "lightgrey"
                duration: 1000
                loops: qhprogressbar.valueType === "critical" ? Animation.Infinite : 1
            }

            // Indeterminate animation by animating alternating stripes:
            Item {
                anchors.fill: parent
                visible: indeterminate
                clip: true
                Row {
                    Repeater {
                        Rectangle {
                            color: index % 2 ? "steelblue" : "lightsteelblue"
                                width: 20 ; height: control.height
                        }
                        model: control.width / 20 + 2
                    }
                    
                    XAnimator on x {
                    from: 0 ; to: -40
                    loops: Animation.Infinite
                    running: indeterminate
                    }
                }
            }
        }
    }
}