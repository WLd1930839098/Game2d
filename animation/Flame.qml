import QtQuick 2.0
import QtQuick.Particles 2.0

Item{
    id:my_item

    function show(x,y){
        ps.visible = true
        emitter.x = x
        emitter.y = y
        ps.start()
    }

    function showOnce(x,y,time){
        ps.visible = true
        emitter.x = x
        emitter.y = y
        ps.start()
        timer.start()
    }

    function hide(){
        ps.visible = false
        ps.stop();
    }

    //火焰效果
    ParticleSystem{
        id:ps
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

    //时间到时关闭攻击特效
    Timer{
        id:timer
        interval: 1500
        running: false
        repeat: false
        onTriggered: {
            my_item.hide()
        }
    }

}
