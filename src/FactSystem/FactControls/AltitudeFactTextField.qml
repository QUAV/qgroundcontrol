import QtQuick                      2.3
import QGroundControl               1.0
import QGroundControl.FactSystem    1.0

FactTextField {
    unitsLabel:         fact ? fact.units : ""
    extraUnitsLabel:    fact ? _altitudeModeExtraUnits : ""
    showUnits:          true
    showHelp:           true

    property int altitudeMode: QGroundControl.AltitudeModeNone

    readonly property string _altModeNoneExtraUnits:            ""
    readonly property string _altModeRelativeExtraUnits:        qsTr("(Rel)")
    readonly property string _altModeAbsoluteExtraUnits:        qsTr("(AMSL)")
    readonly property string _altModeAboveTerrainExtraUnits:    qsTr("(Abv Terr)")
    readonly property string _altModeTerrainFrameExtraUnits:    qsTr("(TerrF)")

    property string _altitudeModeExtraUnits: _altModeNoneExtraUnits

    onAltitudeModeChanged: updateAltitudeModeExtraUnits()

    function updateAltitudeModeExtraUnits() {
        if (altitudeMode === QGroundControl.AltitudeModeNone) {
            _altitudeModeExtraUnits = _altModeNoneExtraUnits
        } else if (altitudeMode === QGroundControl.AltitudeModeRelative) {
            _altitudeModeExtraUnits = _altModeRelativeExtraUnits
        } else if (altitudeMode === QGroundControl.AltitudeModeAbsolute) {
            _altitudeModeExtraUnits = _altModeAbsoluteExtraUnits
        } else if (altitudeMode === QGroundControl.AltitudeModeAboveTerrain) {
            _altitudeModeExtraUnits = _altModeAboveTerrainExtraUnits
        } else if (altitudeMode === QGroundControl.AltitudeModeTerrainFrame) {
            _altitudeModeExtraUnits = _altModeTerrainFrameExtraUnits
        } else {
            console.log("AltitudeFactTextField Internal error: Unknown altitudeMode", altitudeMode)
            _altitudeModeExtraUnits = ""
        }
    }
}
