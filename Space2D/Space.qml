import QtQuick 2.0

Item {
    id: space
    //用于给新创建的物体添加监听对象
    property var listenBodies: []
    //用于记录静止不动的物体对象
    property var stillBodies: []
    property string source: ""
    //添加不动的物体对象
    function addStillBody(body){
        if(body)
            stillBodies.push(body);
    }
    //添加运动物体对象
    function addBody(shape,type, properties){
        Space2D.createBodyFinished.connect( function(body) {
            //将createBodyFinished信号和匿名函数断开连接,防止该物体重复添加要监听的对象
            Space2D.createBodyFinished.disconnect(arguments.callee);

            body.addListenBodies(listenBodies);
            listenBodies.push(body);
            //将由引擎的刷新信号激发物体的刷新信号
            Space2D.refresh.connect(body.refresh);
        });
        return Space2D.createBody(space, shape, type, properties);
    }

    Image {
        id: map
        source: space.source
        anchors.fill: parent
    }
}

