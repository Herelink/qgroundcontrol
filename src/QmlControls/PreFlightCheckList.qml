/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQml.Models     2.1

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

Rectangle {
    width:  mainColumn.width + 3*ScreenTools.defaultFontPixelWidth
    height: mainColumn.height + ScreenTools.defaultFontPixelHeight
    color:  qgcPal.windowShade
    radius: 3

    property alias model: checkListRepeater.model

    property bool _passed: false

    function reset() {
        for (var i=0; i<model.count; i++) {
            var group = model.get(i)
            group.reset()
            group.enabled = i === 0
            group._checked = i === 0
        }
    }

    Component.onCompleted: reset()

    Column {
        id:                     mainColumn
        width:                  40*ScreenTools.defaultFontPixelWidth
        spacing:                0.8*ScreenTools.defaultFontPixelWidth
        anchors.left:           parent.left
        anchors.top:            parent.top
        anchors.topMargin:      0.6*ScreenTools.defaultFontPixelWidth
        anchors.leftMargin:     1.5*ScreenTools.defaultFontPixelWidth

        function groupPassedChanged(index) {
            if (index + 1 < checkListRepeater.count) {
                var group = checkListRepeater.itemAt(index + 1)
                group.enabled = true
                group._checked = true
            }
            for (var i=0; i<checkListRepeater.count; i++) {
                if (!checkListRepeater.itemAt(i).passed) {
                    _passed = false
                    return
                }
            }
            _passed = true
        }

        // Header/title of checklist
        Item {
            width:  parent.width
            height: 1.75*ScreenTools.defaultFontPixelHeight

            QGCLabel {
                text:                   qsTr("Pre-Flight Checklist %1").arg(_passed ? qsTr("(passed)") : "")
                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pointSize:         ScreenTools.mediumFontPointSize
            }
            QGCButton {
                width:                  1.2*ScreenTools.defaultFontPixelHeight
                height:                 1.2*ScreenTools.defaultFontPixelHeight
                anchors.right:          parent.right
                anchors.verticalCenter: parent.verticalCenter
                opacity :               0.2+0.8*(QGroundControl.multiVehicleManager.vehicles.count > 0)
                tooltip:                qsTr("Reset the checklist (e.g. after a vehicle reboot)")

                onClicked: reset()

                Image { source:"/qmlimages/MapSyncBlack.svg" ; anchors.fill: parent }
            }
        }

        // All check list items
        Repeater {
            id: checkListRepeater
        }
    } // Column
} //Rectangle