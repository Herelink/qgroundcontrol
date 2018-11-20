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


QGCView {
    id:         freqCalibration
    viewPanel:  panel
    property var _qgcView: qgcView
    property real __xMaxNum: 20
    property real __yminNum: 47000
    property real __ymaxNum: 47820
    property real __xcurrent: 0
    property bool __isAoto:true


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
                anchors.bottom:  parent.bottom//writeButton.top
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
                    borderWidth: 3
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
                        manualSetValueLabel.text = Math.floor(point.y);
                        __xcurrent = Math.floor(point.y);

                        pictureupperline.clear();
                        pictureupperline.append(0,__xcurrent);
                        pictureupperline.append(__xMaxNum/20,__xcurrent + 50);

                        picturelowerline.clear();
                        picturelowerline.append(__xMaxNum/20,__xcurrent - 50);
                        picturelowerline.append(__xMaxNum/20,__xcurrent);

                        if(manualSetValueLabel.visible)
                            okButton.text = "OK";

                     }
                     onReleased:{
                         manualSetValueLabel.text = Math.floor(point.y);
                         __xcurrent = Math.floor(point.y);

                         pictureupperline.clear();
                         pictureupperline.append(0,__xcurrent);
                         pictureupperline.append(__xMaxNum/20,__xcurrent + 50);

                         picturelowerline.clear();
                         picturelowerline.append(__xMaxNum/20,__xcurrent - 50);
                         picturelowerline.append(__xMaxNum/20,__xcurrent);

                         if(manualSetValueLabel.visible)
                             okButton.text = "OK";

                     }
                }

                AreaSeries {
                    id:threepicture
                    visible:        false
                    color: "#FF0000E3"
                    borderColor: "#FF0000E3"
                    borderWidth: 3
                    upperSeries: LineSeries {
                        id:pictureupperline
                        XYPoint { x: 0; y: __yminNum + 50 }
                        XYPoint { x: __xMaxNum/20; y: __yminNum + 100 }
                    }
                    lowerSeries: LineSeries {
                        id:picturelowerline
                        XYPoint { x: __xMaxNum/20; y: __yminNum }
                        XYPoint { x: __xMaxNum/20; y: __yminNum + 50 }
                    }
                }


                Grid{
                    id:     grid

                    anchors.top:     parent.top
                    anchors.topMargin: 69
                    anchors.left:    parent.left
                    anchors.leftMargin: 222
                    anchors.right:   parent.right
                    anchors.rightMargin: 30
                    anchors.bottom:  parent.bottom
                    anchors.bottomMargin: 102

                    rows: 115;
                    columns: __xMaxNum;
                    rowSpacing: 0;
                    columnSpacing: 0;

                    flow: Grid.TopToBottom;
                    Repeater {
                        id:rep
                        model : pD2dInforData.getModelList()
                        Rectangle {
                            color: modelData.color;
                            width: (parent.width - 56)/__xMaxNum;
                            height: parent.height/115
                        }
                    }
                }
             }
            //update data
            Connections{
                target: pD2dInforData;
                onSignalList:{

                    __yminNum = pD2dInforData.getYMinValue();
                    __ymaxNum = pD2dInforData.getYMaxValue();
                    chartView.axisY().min = __yminNum;
                    chartView.axisY().max = __ymaxNum;


                    __xcurrent = pD2dInforData.getCurrentNumValue(0);

                    currentLine.clear();
                    for(var i = 0;i < pD2dInforData.getCurrentNumList();i++)
                    {
                        currentLine.append(i, pD2dInforData.getCurrentNumValue(i));
                        currentLine.append(i+1, pD2dInforData.getCurrentNumValue(i));
                    }

                    rep.model = pD2dInforData.getModelList();
                }
            }
            Timer {
                id: timer
                interval: 1000
                repeat: true
                triggeredOnStart: true
                running: false
                onTriggered: {
                    autoBtn.text= pD2dInforData.getTestStr();
                    //filterButton.text= modemDataList.getTestStr2();
                }
            }
            Component.onCompleted: {

                chartView.axisX().min = 0;
                chartView.axisX().max = __xMaxNum;
                chartView.axisY().min = __yminNum;
                chartView.axisY().max = __ymaxNum;

                __yminNum = pD2dInforData.getYMinValue();
                __ymaxNum = pD2dInforData.getYMaxValue();

                //pD2dInforData.sendCalibrationCmd(0);
            }
        }
    } // QGCViewPanel
} // QGCView

