import QtQuick 2.0

Item {
    id:hero
    x:0
    y:0

    //共有属性
    property string move_source:""
    property string attack_source:""
    property int map_width: 0
    property int map_height: 0

    function attack(x,y){
        if(!self.is_attack){
            if(self.is_moving)
                move_x_y.stop()
            self.is_attack = true
            self.count = 0
            self.moveTo_x = x;
            self.moveTo_y = y;
            timer.running = true
        }
    }


    function attackStop(){
        self.is_attack=false
    }


    function move(x,y){
        if(!self.is_attack){
            if(self.is_moving)
                move_x_y.stop()
            self.moveTo_x = self.getModeX(x)
            self.moveTo_y = self.getModeY(y)
            self.is_moving = true
            timer.running = true
        }
    }

    function moveStop(){
        move_x_y.stop()
    }

    //私有属性
    QtObject{
        id:self
        property int count: 0
        property int moveTo_x: 0
        property int moveTo_y: 0
        property string orientation: "down"
        property bool is_attack: false
        property bool is_moving: false

        function getOrientation(){
            if(Math.abs(self.moveTo_x-hero.x)>Math.abs(self.moveTo_y-hero.y)){
                //此种情况下有左右两种情况
                if(hero.x<self.moveTo_x)
                    return "right"
                else
                    return "left"
            }else{
                //此种情况下有上下两种情况
                if(hero.y<self.moveTo_y)
                    return "down"
                else
                    return "up"
            }
        }

        function getModeX(x){
            x = x-img.width/2
            if(x<0)
                return 0
            else if(x>hero.map_width-img.width)
                return hero.map_width-img.width
            else
                return x
        }

        function getModeY(y){
            y = y-img.height/2
            if(y<0)
                return 0
            else if(y>hero.map_height-img.height)
                return hero.map_height-img.height
            else
                return y
        }
    }


    Image {
        id:img
        source: hero.move_source+"/down/0.png"
    }

    ParallelAnimation{
        id:move_x_y
        running: false
        onStarted: {

        }

        onStopped: {
            self.is_moving = false
            if(hero.x===self.moveTo_x&&hero.y===self.moveTo_y){
                img.source = hero.move_source+"/"+self.orientation+"/0.png"
                timer.running = false
            }
        }

        NumberAnimation {
            id:xAnimation
            target: hero
            property: "x"
            from:hero.x
            to:self.moveTo_x
            duration: Math.sqrt((hero.x-self.moveTo_x)*8*(hero.x-self.moveTo_x)*8+(hero.y-self.moveTo_y)*8*(hero.y-self.moveTo_y)*8) //  5：该数字越大，人物走动越慢
            //        easing.type: Easing.InOutQuad     动画效果,不设置默认是匀速普通

        }

        NumberAnimation {
            id:yAnimation
            target: hero
            property: "y"
            from:hero.y
            to:self.moveTo_y
            duration: Math.sqrt((hero.x-self.moveTo_x)*8*(hero.x-self.moveTo_x)*8+(hero.y-self.moveTo_y)*8*(hero.y-self.moveTo_y)*8)
        }
    }

    //控时切换图片形成动画
    Timer{
        id:timer
        interval: 200
        running: false
        repeat: true
        onTriggered: {
            self.orientation = self.getOrientation()
            if(self.is_moving){
                move_x_y.start()
            }
            var folder = hero.move_source
            if(self.is_attack){
                folder = hero.attack_source
            }

            if(self.count==0){
                img.source=folder+"/"+self.orientation+"/0.png"
            }
            else if(self.count==1){
                img.source=folder+"/"+self.orientation+"/1.png"
            }
            else if(self.count==2){
                if(self.is_attack){
                    img.source=folder+"/"+self.orientation+"/2.png"
                }else{
                    img.source=folder+"/"+self.orientation+"/0.png"
                }
            }
            else{
                img.source=folder+"/"+self.orientation+"/2.png"
            }

            if(!self.is_attack&&!self.is_moving){
                timer.running = false
            }

            if(self.is_attack&&self.count+1==4){
                self.is_attack = false
            }

            self.count = (self.count+1)%4
        }
    }

}
