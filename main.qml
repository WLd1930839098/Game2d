import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Particles 2.0
import "./animation"

ApplicationWindow {
    id:main_window
    visible: true
    visibility: "Maximized"     //最大化       //Minimized 最小化;
//    flags: Qt.WindowFullScreen   //有边框,全屏幕
    flags: Qt.FramelessWindowHint   //无边框
    title: qsTr("2D游戏主界面")

    //使用qml文件作为组件时,qml文件名一定要大写,且根组件为Item
    Hero{
        id:hero0
        move_source: "./resources/hero0"
        attack_source:"./resources/hero0_attack"
        map_width: background.width
        map_height: background.height
    }


    Image {
        id: background
        source: "./resources/back_ground.jpg"
        x:0
        y:0
        width: parent.width
        height: parent.height*5/6
        z:-1
    }

    MouseArea{
        id:mouse_area
        anchors.fill: background
        acceptedButtons: Qt.LeftButton|Qt.RightButton
        onClicked: {
            if(mouse.button===Qt.RightButton){
                hero0.move(mouse.x,mouse.y)
            }else if(mouse.button===Qt.LeftButton){
                hero0.attack(mouse.x,mouse.y)
                flame.showOnce(mouse.x,mouse.y)
            }
        }
    }

    //攻击时火焰效果组件
    Flame{
        id:flame
    }
    //飘雪效果组件
    Snow{
        id:snow
        emitter_width: background.width
        emitter_height: background.height/2
    }

    Button{text: "退出";y:120;onClicked:Qt.quit()}
    //飘雪效果

    Button{text: "开始";y:0;onClicked:{
            var test = Qt.vector2d(3,4)
            var i = test.times(2)
            console.log(i.times(-1).dotProduct(Qt.vector2d(1,0)))
        }
    }
    Button{text: "暂停";y:40;onClicked: snow.pause()}
    Button{text: "恢复";y:80;onClicked: snow.resume()}

    //下方信息栏
    Rectangle{
        id:option_info_area
        x:0
        y:parent.height*5/6
        width: parent.width
        height: parent.height/6
        Row{
            anchors.fill: parent
            spacing: 20
            Text {
                id: hero_info
                text: qsTr("人物坐标: (-,-)")
                width: 200
            }
            Text{
                id:view_info
                text: qsTr("屏幕尺寸: "+background.width.toFixed(0)+"*"+background.height.toFixed(0))
            }
        }
    }

}
