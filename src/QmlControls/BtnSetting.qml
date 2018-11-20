/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtCharts                 2.0
import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0


import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

QGCView {
    id:         freqCalibration
    viewPanel:  panel
    property var _qgcView: qgcView
    property real __xMaxNum: 20
    property real __yminNum: 47000
    property real __ymaxNum: 47820
    property real __xcurrent: 0
    property real __timerSec: 5
    property bool __isCalibrate:false
    property bool __isAuto:false


    QGCPalette { id: qgcPal; colorGroupEnabled: panel.enabled }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent
        Rectangle {
            id:              logwindow
            anchors.fill:    parent
            anchors.margins: ScreenTools.defaultFontPixelWidth
            color:           qgcPal.window

            Text{
                id:sliderText
                color: "blue";
                text: "current - 0.1";
            }

            Slider
               {
                   x: (parent.width - width)/2
                   y: (parent.height - height)/2
                   width: 600
                   height: 20
                   stepSize: 1
                   minimumValue: 1100
                   maximumValue: 1900
                   onValueChanged:
                   {
                       //console.log(value)
                       sliderText.text = "current : " + value;
                   }
                   style: SliderStyle
                   {
                       groove: m_Slider
                       handle: m_Handle
                   }
               }
               Component
               {
                   id: m_Slider
                   Rectangle
                   {
                       implicitHeight:8
                       color:"gray"
                       radius:8
                   }
               }
               Component
               {
                   id: m_Handle
                   Rectangle{
                       anchors.centerIn: parent;
                       color:control.pressed ? "white":"lightgray";
                       border.color: "gray";
                       border.width: 2;
                       width: 34;
                       height: 34;
                       radius: 12;

                   }
               }


            QGCComboBox {
                id:             urulCombo
                anchors.left:          parent.left
                anchors.leftMargin:    ScreenTools.defaultFontPixelWidth
                width:                 manualBtn.width*1.5
                anchors.bottom:         parent.bottom
                model:          [qsTr("UL_1.4M"), qsTr("UL_10M"), qsTr("UL_20M")]

                onActivated: {
                    if (index != -1) {
                    }
                }
            }
            QGCComboBox {
                id:             urDlCombo
                anchors.left:          urulCombo.right
                anchors.leftMargin:    ScreenTools.defaultFontPixelWidth*0.5
                width:                 manualBtn.width*1.5
                anchors.bottom:         parent.bottom
                model:          [qsTr("DL_10M"), qsTr("DL_20M")]

                onActivated: {
                    if (index != -1) {
                    }
                }
            }

            QGCButton {
                id:                    calibrateButton
                anchors.left:          urDlCombo.right
                anchors.leftMargin:    ScreenTools.defaultFontPixelWidth*2
                width:                 manualBtn.width*1.5
                anchors.bottom:         parent.bottom
                text:            qsTr("Calibrate")
                onClicked:{
                    __isCalibrate = true;
                    urulCombo.visible = !__isCalibrate;
                    urDlCombo.visible = !__isCalibrate;

                    manualSetValue.visible = !__isCalibrate;
                    labelRec.visible = !__isCalibrate;

                    okButton.visible = !__isCalibrate;
                    manualBtn.visible = !__isCalibrate;
                    autoBtn.visible = !__isCalibrate;

                    messageDialog.open();
                }
            }


            Rectangle{
                id:                    showlabel
                anchors.top:           manualBtn.top
                anchors.right:         snrlabel.left
                anchors.rightMargin:   ScreenTools.defaultFontPixelWidth*0.5
                anchors.bottom:        parent.bottom
                width:                 manualBtn.width

                color:                 qgcPal.window
                border.width:          1
                //visible:               false
                Text{
                    id:                     showCurrelValueLabel
                    anchors.fill:           parent
                    text:                   qsTr("0")
                    //visible:                false
                    verticalAlignment:      Text.AlignVCenter
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:         okButton.pointSize
                }
            }

            //snr

            Rectangle{
                id:                    snrlabel
                anchors.top:           manualBtn.top
                anchors.right:         labelRec.left
                anchors.rightMargin:   ScreenTools.defaultFontPixelWidth*0.5
                anchors.bottom:        parent.bottom
                width:                 manualBtn.width

                color:                 qgcPal.window
                border.width:          1
                //visible:               false
                Text{
                    id:                     snrValueLabel
                    anchors.fill:           parent
                    text:                   qsTr("snr")
                    //visible:                false
                    verticalAlignment:      Text.AlignVCenter
                    horizontalAlignment:    Text.AlignHCenter
                    font.pointSize:         okButton.pointSize
                }
            }


            Rectangle{
                id:                    labelRec
                anchors.top:           manualBtn.top
                anchors.right:         okButton.left
                anchors.rightMargin:   ScreenTools.defaultFontPixelWidth*0.5
                anchors.bottom:        parent.bottom
                width:                 manualBtn.width
                color:                 qgcPal.window
                border.width:          1
                //visible:               false
                QGCTextField{
                    id:     manualSetValue
                    anchors.fill:           parent
                    width:                 manualBtn.width
                    text:   "0"
                    focus: true
                    inputMethodHints:       Qt.ImhFormattedNumbersOnly
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            QGCButton {
                id:                     okButton
                anchors.right:          manualBtn.left
                anchors.rightMargin:    ScreenTools.defaultFontPixelWidth*0.5
                anchors.bottom:         parent.bottom
                text:                   qsTr("OK")
                onClicked: {
                    manualBtn.checked = true;
                    autoBtn.checked = false;
                }
            }

            QGCButton {
                id:                     manualBtn
                anchors.right:          autoBtn.left
                anchors.rightMargin:    ScreenTools.defaultFontPixelWidth*0.5
                anchors.bottom:         parent.bottom
                text:                   qsTr("Manual")
                checkable:              true
                checked:                false

                onClicked:{
                    manualSetValue.visible = true;
                    labelRec.visible = true;
                    okButton.checkable = true;
                    okButton.checked = false;

                    manualBtn.checked = true;
                    autoBtn.checked = false;

                    __isAuto = false;
                }
            }

            QGCButton {
                id:                     autoBtn
                anchors.right:          parent.right
                anchors.rightMargin:     ScreenTools.defaultFontPixelWidth*0.5
                anchors.bottom:         parent.bottom
                text:                   qsTr("Auto")
                checkable:              true
                checked:                true
                onClicked:{
                    manualSetValue.visible = false;
                    labelRec.visible = false;
                    okButton.checkable = false;
                    okButton.checked = false;

                    manualBtn.checked = false;
                    autoBtn.checked = true;

                    __isAuto = true;
                }
            }

            MessageDialog {
                id: messageDialog
                icon: StandardIcon.Warning
                title: "WARNING"
                text: "Please long press the airplane calibrate button for 3 seconds within 30 seconds,and wait for a moment .\n"
                standardButtons:    StandardButton.NoButton
                Component.onCompleted: visible = false
            }

            MessageDialog {
                id: resultDialog
                icon: StandardIcon.Warning
                title: "WARNING"
                text: "calibrate succeed."
                standardButtons:    StandardButton.Ok
                onAccepted: {
                    close();
                }
                Component.onCompleted: visible = false
            }

            Timer {
                id: timer
                interval: 1000
                repeat: true
                triggeredOnStart: true
                //running: false
                onTriggered: {
                    __timerSec--;
                    if(__timerSec < 0)
                    {
                        timer.stop();
                        resultDialog.close();
                    }
                }
            }

            MessageDialog {
                id: svrMessageDialog
                icon: StandardIcon.Warning
                title: "WARNING"
                text: "select frequency point  error, please check !"
                standardButtons:    StandardButton.Ok
                onAccepted: {
                    close()
                }
                Component.onCompleted: visible = false
            }

            Component.onCompleted: {

            }
        }
    } // QGCViewPanel
} // QGCView

