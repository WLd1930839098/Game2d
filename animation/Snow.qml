import QtQuick 2.0
import QtQuick.Particles 2.0

Item {
    property int emitter_width: 0
    property int emitter_height: 0
    function start(){
        particles.start()
    }
    function stop(){
        particles.stop()
    }
    function resume(){
        particles.resume()
    }
    function pause(){
        particles.pause()
    }

    ParticleSystem{
        id:particles
        running: false
    }

    ImageParticle{
        system: particles
        rotationVelocity:60
        sprites: Sprite{
            name: "snow"
            source: "../resources/snow_flake.png"
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
        width: emitter_width
        height: emitter_height
    }
}
