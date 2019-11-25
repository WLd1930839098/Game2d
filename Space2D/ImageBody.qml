import QtQuick 2.0

Image {
    id: img
    x:0
    y:0
    //图片文件夹
    source: moveSource+"/down/0.png"
    //走动动画资源
    property string moveSource: ""
    //攻击动画资源
    property string attackSource: ""
    //游戏对象类型
    property int objType: Space2D.hero
    //物体实体性质
    property int bodyType: Space2D.rigid
    //该物体监听的对象
    property var listenBodies: []
    //物体中心
    readonly property vector2d center: Qt.vector2d(x+width/2, y+height/2);
    //质量
    property real mass: 1
    // 物体向某个方向的速度 (单位： pix / s)
    property vector2d velocity: Qt.vector2d(0,0)
    //物体移动的快慢
    property int speed: 150

    function addListenBodies(bodyList){
        for(var i=0;i<bodyList.length;i++){
            listenBodies.push(bodyList[i]);
        }
    }

    //鼠标或算法移动
    function move(x,y){
        //走动时停止攻击
        self.destination = Qt.vector2d(x,y);
        self.orientation = self.getOrientation();
        if(!self.isMoving){
            img.source = img.moveSource+"/"+self.orientation+"/1.png";
            self.isMoving = true;
        }
        self.isAttacking = false;
        timer.running = true;
        velocity = self.destination.minus(center).normalized().times(speed);
    }

    function stop(){
        //将速度置为0
        self.isMoving = false;
        self.moveByKey = false;
        velocity = Qt.vector2d(0,0);
        if(center.fuzzyEquals(self.destination,5))
            timer.running = false;
        img.source = moveSource+"/"+self.orientation+"/0.png";
        self.destination = center;
    }

    function attack(x,y){
        if(!self.isAttacking){
            stop();
            self.isAttacking = true;
            self.destination = Qt.vector2d(x,y);
            self.orientation = self.getOrientation();
            self.count = 0;
            timer.running = true;
        }
    }

    function stopAttack(){
        self.isAttacking = false;
        timer.running = false;
    }

    signal crashed(var obj)

    onCrashed: {
        var a = Space2D.distance(center,obj.center);
        var nextLocation = center.plus(velocity.times(Space2D.timeStep));
        var b = Space2D.distance(nextLocation,obj.center);
        if(a>b)
            stop();
    }

    signal refresh

    onRefresh:  {
        self.refreshMove()
        //检测碰撞
        if(bodyType === Space2D.rigid){
            var i=0,len ;
            Space2D.pause();
            for(i=0, len = listenBodies.length; i<len; i++){
                Space2D.collide(img,listenBodies[i],Space2D.rectangles_collide);
            }
            Space2D.start();
        }
    }


    //存放私有属性以及私有方法
    QtObject{
        id:self

        //物体移动到的下一个点
        property vector2d nextPoint

        //运动目的地点
        property vector2d destination: center

        onNextPointChanged: {
            img.x = nextPoint.x;
            img.y = nextPoint.y;
        }
        property bool moveByKey: false
        property bool isMoving: false
        property bool isAttacking: false
        property int count: 0
        property string orientation: "down"

        function refreshMove(){
            if(!self.moveByKey&&center.fuzzyEquals(destination,5))
                stop();
            else
                self.nextPoint = nextPoint.plus(velocity.times(Space2D.timeStep));
        }

        function getOrientation(){
            if(Math.abs(self.destination.x-img.x)>Math.abs(self.destination.y-img.y)){
                //此种情况下有左右两种情况
                if(img.x<self.destination.x)
                    return "right"
                else
                    return "left"
            }else{
                //此种情况下有上下两种情况
                if(img.y<self.destination.y)
                    return "down"
                else
                    return "up"
            }
        }
    }


    //控时切换图片形成动画
    Timer{
        id:timer
        interval: 200
        running: false
        repeat: true
        onTriggered: {
            var folder = img.moveSource;
            if(self.isAttacking){
                folder = img.attackSource;
            }

            switch(self.count){
            case 0:
                img.source=folder+"/"+self.orientation+"/0.png"
                break;
            case 1:
                img.source=folder+"/"+self.orientation+"/1.png"
                break;
            case 2:
                if(self.isAttacking){
                    img.source=folder+"/"+self.orientation+"/2.png"
                }else{
                    img.source=folder+"/"+self.orientation+"/0.png"
                }
                break;
            case 3:
                img.source=folder+"/"+self.orientation+"/2.png"
                break;
            default:
                console.log("count error")
            }

            if(!self.isAttacking&&!self.isMoving){
                //攻击结束,且没有走动
                timer.running = false
            }

            if(self.isAttacking&&self.count+1==4){
                self.isAttacking = false
            }

            self.count = (self.count+1)%4
        }
    }
}
