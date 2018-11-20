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


    property real __currIndex: 0
    property real __currNum: 0

    property real __setValue: 0

    property real __oneSideBwLineWide: 50

    QGCPalette { id: qgcPal; colorGroupEnabled: panel.enabled }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent
        Rectangle {
            id:              logwindow
            anchors.fill:    parent
            anchors.margins: ScreenTools.defaultFontPixelWidth
            color:           qgcPal.window

            ChartView{
                id: chartView
                objectName: "FreqChartView"
                anchors.top:     parent.top
                anchors.left:    parent.left
                anchors.right:   parent.right
                anchors.bottom:  manualBtn.top
                theme: ChartView.ChartThemeBrownSand
                antialiasing: true
                legend.visible: false
                backgroundColor:qgcPal.window



                LineSeries {
                    id: currentLine
                    width:5
                    color: "#FFFF0000"
                }



                AreaSeries {
                    id:areaSeries
                    color: "#00D52B1E"
                    borderColor: "#00D52B1E"
                    borderWidth: 5
                    upperSeries: LineSeries {
                        id:upperline
                        XYPoint { x: 0; y: __ymaxNum }
                        XYPoint { x: __xMaxNum; y: __ymaxNum }

                    }
                    lowerSeries: LineSeries {
                        id:lowerline
                        XYPoint { x: 0; y: __yminNum }
                        XYPoint { x: __xMaxNum; y: __yminNum }
                    }

                    onPressed:{
                        //aotu and is not calibrate
                        if(__isAuto)
                            return;
                        __xcurrent = Math.floor(point.x);
                        manualSetValue.text = __xcurrent;
                     }
                }

                AreaSeries {
                    id:threepicture
                    visible:        true
                    color: "#00000000"
                    borderColor: "#AF00E3E3"
                    borderWidth: 3
                    upperSeries: LineSeries {
                        id:pictureupperline
                        width:5
                        XYPoint { x: __xcurrent - currentLine.width*2; y: __ymaxNum - 1}
                        XYPoint { x: __xcurrent + currentLine.width*2; y: __ymaxNum - 1}
                    }
                    lowerSeries: LineSeries {
                        id:picturelowerline
                        width:5
                        XYPoint { x: __xcurrent - currentLine.width*2; y: 0}
                        XYPoint { x: __xcurrent + currentLine.width*2; y: 0}
                    }
                }



                Row{
                    id:rowLayout
                    spacing: 0
                    anchors.top:     parent.top
                    anchors.topMargin: 70
                    anchors.left:    parent.left
                    anchors.leftMargin: 140
                    anchors.right:   parent.right
                    anchors.rightMargin: 140
                    anchors.bottom:  parent.bottom
                    anchors.bottomMargin: 102

                    Repeater{
                        id:rep
                        model :pD2dInforData.getCliModelList()
                        Rectangle{
                            id: repRectangle
                            height: parent.height
                            width: parent.width/115
                            gradient: Gradient {
                                GradientStop{
                                    position:modelData.value;
                                    color: "#00000000"
                                }
                                GradientStop{
                                    position: (1.0);
                                    color: "#BF00BB00"
                                }
                             }
                         }
                    }
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
                        pD2dInforData.setCliUlDlValue(index,1);
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
                        pD2dInforData.setCliUlDlValue(index,0);
                        __oneSideBwLineWide = 50
                        __oneSideBwLineWide = __oneSideBwLineWide*(index+1);
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

                    //set flag
                    pD2dInforData.setIsCalibrateFlag(__isCalibrate);

                    pD2dInforData.sendCalibrationCmd(3);
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
                    if(__isAuto == false)
                    {
                        //check value is right
                        __setValue = parseInt(manualSetValue.text);
                        if(urDlCombo.currentIndex == 0)
                        {
                            if(__setValue < 47050 || __setValue  > 47785)
                            {
                                svrMessageDialog.text = "select frequency point  error,check : 47050 < frequency point < 47785 ";
                                svrMessageDialog.open();
                                okButton.checked = false;
                                return;
                            }
                        }
                        else if(urDlCombo.currentIndex == 1)
                        {
                            if(__setValue < 47100 || __setValue > 47735)
                            {
                                svrMessageDialog.text = "select frequency point  error,check : 47100 < frequency point < 47735 ";
                                svrMessageDialog.open();
                                okButton.checked = false;
                                return;
                            }
                        }

                        __xcurrent = parseInt(manualSetValue.text);
                        pD2dInforData.setCurrentCalibrateValue(__xcurrent);
                        pD2dInforData.sendCalibrationCmd(2);
                        manualBtn.checked = true;
                        autoBtn.checked = false;
                    }
                    else
                    {
                        svrMessageDialog.text = "Frequency point cannot be set in aotu mode !";
                        svrMessageDialog.open();
                    }
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

                    //Auto -- > Manual CMD
                    pD2dInforData.setCurrentCalibrateValue(0);
                    pD2dInforData.sendCalibrationCmd(1);
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
                    //Manual -- > Auto CMD
                    pD2dInforData.setCurrentCalibrateValue(1);
                    pD2dInforData.sendCalibrationCmd(1);
                }
            }

            //send and reveiced ok
            Connections{
                target: pD2dInforData
                onSetCurrentCalibrateValueSucceed:{
                    if(__isCalibrate)
                    {
                        messageDialog.close();

                        __isCalibrate = false;

                        urulCombo.visible = !__isCalibrate;
                        urDlCombo.visible = !__isCalibrate;

                        manualSetValue.visible = !__isCalibrate;
                        labelRec.visible = !__isCalibrate;

                        okButton.visible = !__isCalibrate;
                        manualBtn.visible = !__isCalibrate;
                        autoBtn.visible = !__isCalibrate;

                        //set flag
                        pD2dInforData.setIsCalibrateFlag(__isCalibrate);

                        //
                        svrMessageDialog.text = qsTr("calibrate succeed.");
                        svrMessageDialog.open();
                    }
                    else
                    {
                        svrMessageDialog.text = qsTr(" succeed.");
                        svrMessageDialog.open();
                    }
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

            Connections{
                target: pD2dInforData
                onSetCurrentCalibrateValueFalied:{

                    if(__isCalibrate)
                    {
                        messageDialog.close();

                        __isCalibrate = false;

                        urulCombo.visible = !__isCalibrate;
                        urDlCombo.visible = !__isCalibrate;

                        manualSetValue.visible = !__isCalibrate;
                        labelRec.visible = !__isCalibrate;

                        okButton.visible = !__isCalibrate;
                        manualBtn.visible = !__isCalibrate;
                        autoBtn.visible = !__isCalibrate;

                        //set flag
                        pD2dInforData.setIsCalibrateFlag(__isCalibrate);

                        //
                        svrMessageDialog.text = qsTr("calibrate failed.");
                        svrMessageDialog.open();
                    }
                    else
                    {
                        svrMessageDialog.text = qsTr(" failed.");
                        svrMessageDialog.open();
                    }
                }
            }

            Connections {
                target: pD2dInforData
                onSetCalibrateStr: {
                    if(tmpStr == "0"){
                        manualSetValue.visible = true;
                        labelRec.visible = true;
                        manualBtn.checked = true;
                        autoBtn.checked = false;
                        __isAuto = false;
                    }
                    else if(tmpStr == "1"){
                        manualSetValue.visible = false;
                        labelRec.visible = false;
                        manualBtn.checked = false;
                        autoBtn.checked = true;
                        __isAuto = true;
                    }
                }
            }

            Connections {
                target: pD2dInforData
                onSignalCalibrateList: {
                    messageDialog.close();

                    __isCalibrate = false;

                    urulCombo.visible = !__isCalibrate;
                    urDlCombo.visible = !__isCalibrate;

                    manualSetValue.visible = !__isCalibrate;
                    labelRec.visible = !__isCalibrate;

                    okButton.visible = !__isCalibrate;
                    manualBtn.visible = !__isCalibrate;
                    autoBtn.visible = !__isCalibrate;

                    //set flag
                    pD2dInforData.setIsCalibrateFlag(__isCalibrate);

                    //
                    svrMessageDialog.text = qsTr("calibrate failed.");
                    svrMessageDialog.open();
                }
            }


            //update data
            Connections{
                target: pD2dInforData;
                onSignalList:{
                    if(__isCalibrate)
                    {
                        return;
                    }
                    chartView.axisX().min = pD2dInforData.getYMinValue();
                    chartView.axisX().max = pD2dInforData.getYMaxValue();
                    chartView.axisY().min = pD2dInforData.getCliYMinValue();
                    chartView.axisY().max = pD2dInforData.getCliYMaxValue();


                    __xcurrent = pD2dInforData.getCliCurrentNumValue();

                    //current calibbrate
                    showCurrelValueLabel.text = __xcurrent;

                    //snr
                     __currIndex = urDlCombo.currentIndex;
                     snrValueLabel.text = pD2dInforData.getSNRValue(__xcurrent,__currIndex)

                    currentLine.clear();
                    for(var i = pD2dInforData.getCliYMinValue();i <= pD2dInforData.getCliYMaxValue();i++)
                    {
                        currentLine.append(__xcurrent, i);
                    }

                    rep.model = pD2dInforData.getCliModelList();

                    if(__xcurrent!= 0)
                    {
                        pictureupperline.clear();

                        pictureupperline.append(__xcurrent - __oneSideBwLineWide,pD2dInforData.getCliYMaxValue() - 1);
                        pictureupperline.append(__xcurrent + __oneSideBwLineWide,pD2dInforData.getCliYMaxValue() - 1);

                        picturelowerline.clear();

                        picturelowerline.append(__xcurrent - __oneSideBwLineWide,pD2dInforData.getCliYMinValue());
                        picturelowerline.append(__xcurrent + __oneSideBwLineWide,pD2dInforData.getCliYMinValue());
                    }

                    //for TouchPoint
                    __currIndex = urDlCombo.currentIndex;
                    if(__currIndex == 0)
                    {
                        __currNum = 7;
                    }
                    else if(__currIndex == 1)
                    {
                        __currNum = 15 + 6;
                    }
                    else if(__currIndex == 2)
                    {
                        __currNum = 25 + 3;
                    }
                    else if(__currIndex == 3)
                    {
                        __currNum = 50 + 6;
                    }
                    else if(__currIndex == 4)
                    {
                        __currNum = 75 + 2;
                    }
                    else if(__currIndex == 5)
                    {
                        __currNum = 100 + 5;
                    }

                    upperline.clear();
                    upperline.append(pD2dInforData.getYMinValue() + __currNum,pD2dInforData.getCliYMaxValue());
                    upperline.append(pD2dInforData.getYMaxValue() - __currNum,pD2dInforData.getCliYMaxValue());

                    lowerline.clear();
                    lowerline.append(pD2dInforData.getYMinValue() + __currNum,pD2dInforData.getCliYMinValue());
                    lowerline.append(pD2dInforData.getYMaxValue() - __currNum,pD2dInforData.getCliYMinValue());
                    //end TouchPoint

                }
            }

            Connections{
                target: pD2dInforData
                onUplinkCFG:{
                    if(index == 0)
                    {
                        urulCombo.currentIndex = 0;
                    }
                    else if(index == 3)
                    {
                        urulCombo.currentIndex = 1;
                    }
                    else if(index == 5)
                    {
                        urulCombo.currentIndex = 2;
                    }
                }
            }

            Connections{
                target: pD2dInforData
                onDownlinkCFG:{
                    if(index == 3)
                    {
                        urDlCombo.currentIndex = 0;
                        __oneSideBwLineWide = 50
                    }
                    else if(index == 5)
                    {
                        urDlCombo.currentIndex = 1;
                        __oneSideBwLineWide = 100
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
               pD2dInforData.sendCalibrationCmd(0);
               pD2dInforData.sendCalibrationCmd(6);
               pD2dInforData.sendCalibrationCmd(7);
            }
        }
    } // QGCViewPanel
} // QGCView

