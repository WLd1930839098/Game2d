import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Particles 2.0

ApplicationWindow {
    id:main_window
    visible: true
    visibility: "Maximized"     //最大化       //Minimized 最小化;
//    flags: Qt.WindowFullScreen   //有边框,全屏幕
    flags: Qt.FramelessWindowHint   //无边框

    title: qsTr("qml组件测试")

    Image {
        id:img
        source: "./resources/hero0/down/0.png"
        x:0
        y:0
        property int count: 0
        property int to_x: 0
        property int to_y: 0
        property string orientation: "down"
        property bool is_attack: false
        property bool is_moving: false

        function getOrientation(){
            if(Math.abs(img.to_x-img.x)>Math.abs(img.to_y-img.y)){
                //此种情况下有左右两种情况
                if(img.x<img.to_x)
                    return "right"
                else
                    return "left"
            }else{
                //此种情况下有上下两种情况
                if(img.y<img.to_y)
                    return "down"
                else
                    return "up"
            }
        }

        function attackStop(){
            img.is_attack=false
        }
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
            var x = mouse.x
            var y = mouse.y
            if(x<img.width/2)
                x = img.width/2
            if(x>background.width-img.width/2)
                x = background.width-img.width/2
            if(y<img.height/2)
                y = img.height/2
            if(y>background.height-img.height/2)
                y = background.height-img.height/2
            x = x-img.width/2
            y = y-img.height/2
            img.to_x = x
            img.to_y = y
            if(mouse.button===Qt.RightButton){
                img.attackStop();
                move_x_y.stop();//可以中断人物的移动，进行下一次移动

                img.orientation = img.getOrientation()
                move_x_y.start()
            }else if(mouse.button===Qt.LeftButton){
                //TODO 添加攻击效果
                if(!img.is_attack)
                {
                    if(img.is_moving)
                        move_x_y.stop();
                    img.is_attack=true
                    img.count = 0
                    img.orientation=img.getOrientation()
                    timer.running=true;
                }
            }
        }
    }
    ParallelAnimation{
        id:move_x_y
        running: false
        onStarted: {
            if(timer.running==false){
                img.source="./resources/hero0/"+img.orientation+"/1.png"
                timer.running = true
                img.is_moving = true
            }
        }

        onStopped: {
            if(img.x===img.to_x&&img.y===img.to_y){
                img.source = "./resources/hero0/"+img.orientation+"/0.png"
                timer.running = false
                img.is_moving = false
            }
        }

        NumberAnimation {
            id:xAnimation
            target: img
            property: "x"
            from:img.x
            to:img.to_x
            duration: Math.sqrt((img.x-img.to_x)*8*(img.x-img.to_x)*8+(img.y-img.to_y)*8*(img.y-img.to_y)*8) //  5：该数字越大，人物走动越慢
            //        easing.type: Easing.InOutQuad     动画效果,不设置默认是匀速普通

        }

        NumberAnimation {
            id:yAnimation
            target: img
            property: "y"
            from:img.y
            to:img.to_y
            duration: Math.sqrt((img.x-img.to_x)*8*(img.x-img.to_x)*8+(img.y-img.to_y)*8*(img.y-img.to_y)*8)
        }
    }

    Timer{
        id:timer
        interval: 200
        running: false
        repeat: true
        onTriggered: {
            if(img.is_moving)
                img.orientation = img.getOrientation()
            var attack_complete = false
            if(img.count+1==4){
                attack_complete = true
            }
            img.count = (img.count+1)%4
            var folder = "hero0"

            if(img.is_attack&&!attack_complete){
                folder = "hero0_attack"
            }

            if(img.count==0){
                img.source="./resources/"+folder+"/"+img.orientation+"/0.png"
            }
            else if(img.count==1){
                img.source="./resources/"+folder+"/"+img.orientation+"/1.png"
            }
            else if(img.count==2){
                if(img.is_attack&&!attack_complete){
                    img.source="./resources/"+folder+"/"+img.orientation+"/2.png"
                }else{
                img.source="./resources/"+folder+"/"+img.orientation+"/0.png"
                }
            }
            else{
                img.source="./resources/"+folder+"/"+img.orientation+"/2.png"
                //显示攻击特效
                if(img.is_attack){
                    emitter.x = mouse_area.mouseX
                    emitter.y = mouse_area.mouseY
                    flame.visible = true
                    flame.start()
                    attack_timer.running = true
                }
            }

            if(img.is_attack&&attack_complete){
                folder = "hero0"
                img.is_attack = false
                timer.running = false
            }

            hero_info.text = qsTr("人物坐标: ("+img.x.toFixed(0)+","+img.y.toFixed(0)+")")
        }
    }

    //时间到时关闭攻击特效
    Timer{
        id:attack_timer
        interval: 1000
        running: false
        repeat: false
        onTriggered: {
            flame.visible = false
            flame.stop()
        }
    }

    //火焰效果
    ParticleSystem{
        id:flame
        anchors.fill: parent
        running: false
        ImageParticle{
            groups: ["smoke"]
            color: "#222222"
            source: "qrc:/particleresources/glowdot.png"
        }
        ImageParticle{
            groups: ["flame"]
            color: "#11ff400f"
            colorVariation: 0.1
            source: "qrc:/particleresources/glowdot.png"
        }
        Emitter{
            id:emitter
            x:300
            y:300
            group: "flame"
            emitRate:120
            lifeSpan: 1200
            size: 20
            endSize: 10
            sizeVariation: 10
            acceleration: PointDirection{y:-40}
            velocity: AngleDirection{angle: 270;magnitude: 20;angleVariation: 22;magnitudeVariation: 5}
        }
        TrailEmitter{
            group: "smoke"
            follow: "flame"
            emitRatePerParticle: 1
            lifeSpan: 2400
            lifeSpanVariation: 400
            size: 16
            endSize: 8
            sizeVariation: 8
            acceleration: PointDirection{y:-40}
            velocity: AngleDirection{angle: 270;magnitude: 40;angleVariation: 22;magnitudeVariation: 5}
        }
    }

    Button{text: "退出";y:120;onClicked:Qt.quit()}
    //飘雪效果
    Button{text: "开始";y:0;onClicked: particles.start()}
    Button{text: "暂停";y:40;onClicked: particles.pause()}
    Button{text: "恢复";y:80;onClicked: particles.resume()}



    ParticleSystem{
        id:particles
        running: false
    }

    ImageParticle{
        system: particles
        rotationVelocity:60
        sprites: Sprite{
            name: "snow"
            source: "./resources/snow_flake.png"
        }
        colorVariation: 0
        entryEffect: ImageParticle.Scale
    }
    Emitter{
        system: particles
        emitRate:20
        lifeSpan:5000
        velocity: PointDirection{
            y:80
            xVariation: 100
            yVariation: 40
        }
        acceleration: PointDirection{y:4}
        size: 20
        sizeVariation: 10
        width: background.width
        height: background.height/2
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
