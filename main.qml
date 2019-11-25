import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
//导入游戏引擎,模块声明文件在Space2D文件夹中
import "./Space2D"
//导入引擎中包含的动画特效
import "./Space2D/animation"

ApplicationWindow {
    id:main_window
    visible: true
    visibility: "Maximized"     //最大化       //Minimized 最小化;
    //flags: Qt.WindowFullScreen   //有边框,全屏幕
    flags: Qt.FramelessWindowHint   //无边框
    title: qsTr("2D游戏主界面")


    Space{
        id:space
        x:0
        y:0
        width: parent.width
        height: parent.height*5/6
        source: "resources/back_ground.jpg"

        property var hero: 0
        MouseArea{
            id:mouse_area
            anchors.fill: space
            acceptedButtons: Qt.LeftButton|Qt.RightButton
            onClicked: {
                if(mouse.button===Qt.RightButton){
                    space.hero.move(mouse.x,mouse.y)
                }else if(mouse.button===Qt.LeftButton){
                    space.hero.attack(mouse.x,mouse.y)
                    flame.showOnce(mouse.x,mouse.y)
                }
            }
        }
    }

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
            Button{text: "退出"; onClicked:Qt.quit()}
            //飘雪效果
            Button{text: "开始";onClicked: snow.start()}
            Button{text: "暂停";onClicked: snow.pause()}
            Button{text: "恢复";onClicked: snow.resume()}
            Button{text: "更新位置";onClicked: {
//                    item1_location.text = qsTr("物体1: ("+space.item1.x.toFixed(0)+","+space.item1.y.toFixed(0)+")")
//                    item2_location.text = qsTr("物体2: ("+space.item2.x.toFixed(0)+","+space.item2.y.toFixed(0)+")")
                }
            }

            Text {
                id: item1_location
                text: qsTr("物体1: (-,-)")
                width: 200
            }
            Text{
                id:item2_location
                width: 200
                text: qsTr("物体2: (-,-)")
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
        emitter_width: space.width
        emitter_height: space.height/2
    }

    Init{
        onExec: {

            space.addBody(Space2D.image,Space2D.rigid,{
                                   x:500,
                                   y:500,
                                   source:"./resources/hero0/up/0.png",
                                   moveSource:"./resources/hero0",
                                   attackSource:"./resources/hero0_attack",
                                   velocity:Space2D.createVelocity(0, 0)});

            space.hero = space.addBody(Space2D.image,Space2D.rigid,{
                                   x:0,
                                   y:0,
                                   source:"./resources/hero0/down/0.png",
                                   moveSource:"./resources/hero0",
                                   attackSource:"./resources/hero0_attack",
                                   velocity:Space2D.createVelocity(10, 10)});
        }
    }
}


