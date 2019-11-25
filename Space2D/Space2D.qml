pragma Singleton
import QtQuick 2.0

/*
  文档介绍：文档中包含了对形状类型以及物体类型的定义,
            以及物体的刷新时间timeStep单位是秒
            以及控制刷新计时器的pause,start函数
            创建圆、矩形、和多边形的createBody函数
            实现判断圆与圆、矩形与矩形的碰撞检测以及碰撞后的效果
            提供了对vector2d数据类型的一些常用操作,正交分解以及反射
*/

QtObject {
    id: space2D

    //objType
    readonly property int hero: 1          //图像
    //bodyType
    readonly property int item: 0           //可以检测到碰撞,发生碰撞后就停止
    readonly property int rigid: 1          //检测到碰撞后产生理想刚体碰撞效果
    readonly property int still: 2          //该类型的物体静止不动
    //刷新时间间隔
    readonly property real timeStep: 0.01   //单位s
    readonly property real maxVelocity: 3 / timeStep

    readonly property real g: 10           //定义重力加速度

    signal refresh

    //使用计时器来定时刷新
    property Timer timer : Timer{
        id: timer
        interval: timeStep * 1000
        repeat: true
        running: true
        onTriggered: refresh();
    }
    //停止刷新
    function pause(){
        timer.stop();
    }
    //开始刷新
    function start(){
        timer.start();
    }

    //创建速度
    function createVelocity(x, y){
        var v = Qt.vector2d(x, y);
        if(v.length() > maxVelocity){
            v = v.normalized().times(maxVelocity);
        }
        return v;
    }

    //当创建对象完成后,发射该信号
    signal createBodyFinished(var body)

    //在指定的Space创建指定的对象
    //propertys参数一般是"{x:0;y:0}"指定布局的参数,该参数在incubator函数中调用
    function createBody(space, shapeType, bodyType, properties){
        var url = "./ImageBody.qml";
        if(bodyType !== still){
            switch(shapeType){
            case hero:
                url = "./ImageBody.qml";
                break;
            default:break;
            }
        } else {
            url = "./ImageBody.qml";
        }
        var component = Qt.createComponent(url);
        console.assert(component,"component created failedly");
        var incubator = component.incubateObject(space, properties);
        console.assert(!objectIsNull(incubator));
        if(!objectIsNull(incubator)){
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        createBodyFinished(incubator.object);
                    }
                }
            } else {
                createBodyFinished(incubator.object);
            }
            incubator.forceCompletion();
        }else {
            createBodyFinished(incubator.object);
        }
        //bins自定义
        return incubator.object
    }

    function objectIsNull(object){
        if (!object && typeof(object)!="undefined" && object !== 0){
            return true;
        }
        return false;
    }

    //检测碰撞函数,用shape_collide函数进行检测,若检测到碰撞则用collide_reaction函数进行渲染
    function collide(obj1, obj2, collide_test_function){
        if(collide_test_function(obj1, obj2)){
            obj1.crashed(obj2);
            obj2.crashed(obj1);
        }
    }

    //圆形物体碰撞函数
    function circular_collide_reaction(cir1, cir2){
        // 物体1和物体2的质量和速度
        var m1 = cir1.mass;
        var v1 = cir1.velocity;
        var m2 = cir2.mass;
        var v2 = cir2.velocity;

        // 求 cir1 和 cir2 的碰撞面的单位法线,即两个圆心位置确定的单位向量
        var N = cir1.center.minus(cir2.center).normalized();

        // 求 v1 在 N 上正交分解
        var v1_paraller_N = N.times(v1.dotProduct(N));
        // 求 v1 在与N垂直方向上的分解
        var v1_vertial_N = v1.minus(v1_paraller_N);

        // 求 v2 在 N 上正交分解
        var v2_paraller_N = N.times(v2.dotProduct(N));
        // 求 v2 在 与N垂直方向上的分解
        var v2_vertial_N = v2.minus(v2_paraller_N);

        //保存两个力在N上的大小值,同向取正,异向取负
        var v1_paraller_N_size, v2_paraller_N_size;
        //保存v1和v2碰撞后的值,类型为vector2d
        var v1_reflect_paraller_N, v2_reflect_paraller_N;

        if(m1 !== m2) {
            if(vectorsHasSameDirection(v1_paraller_N, N))
                v1_paraller_N_size = v1_paraller_N.length();
            else
                v1_paraller_N_size = -v1_paraller_N.length();
            if(vectorsHasSameDirection(v2_paraller_N, N))
                v2_paraller_N_size = v2_paraller_N.length();
            else
                v2_paraller_N_size = -v2_paraller_N.length();

            //根据动量守恒和机械能守恒求解碰撞后在N上的速度,N.teimes()操作将v1_reflect_paraller_N确定为vector2d类型
            //N的length为1,故乘以N并不改变力的大小
            v1_reflect_paraller_N = N.times(((m1-m2)*v1_paraller_N_size+2*m2*v2_paraller_N_size)/(m1+m2));
            v2_reflect_paraller_N = N.times(((m2-m1)*v2_paraller_N_size+2*m1*v1_paraller_N_size)/(m1+m2));

        } else {
            v1_reflect_paraller_N = v2_paraller_N;
            v2_reflect_paraller_N = v1_paraller_N;
        }

        // 合并 N 以及 垂直 N 上的速度
        cir1.velocity = v1_reflect_paraller_N.plus(v1_vertial_N);
        cir2.velocity = v2_reflect_paraller_N.plus(v2_vertial_N);
    }

    //检测矩形物体是否碰撞,不考虑矩形会旋转的情况
    function rectangles_collide(rect1, rect2){
        if(((rect1.y+rect1.height) >= rect2.y) && (rect1.y <=( rect2.y+rect2.height)))
            if(((rect1.x+rect1.width) >= rect2.x) && (rect1.x <=( rect2.x+rect2.width)))
                return true;
        return false;
    }

    //判断两个力的方向是否同向
    function vectorsHasSameDirection(vector1, vector2){
        if(vectorIsCollinear(vector1, vector2))
            if(vector1.x / vector2.x > 0 ) return true;
        return false;
    }
    //判断两个力是否共线,规定大小为0的力与任何力都不共线
    function vectorIsCollinear(vector1, vector2){
        if(vector1.length() === 0 || vector2.length() === 0) return false;
        if(vector1.x * vector2.y === vector1.y * vector2.x)  return true;
        return false;
    }

    //力(vector2d)在指定线(平面)上的反射,N为指定线(平面)的法线
    function vector2dReflect(v, N){
        // 第一步将 法向量N 转换为单位向量
        N = N.normalized();
        // 然后求-v在向量N上的投影长度的两倍 projectionLengthX2
        var lengthX2 = v.times(-1).dotProduct(N) * 2;
        // 将N乘以 projectionLengthX2 再加上v
        return N.times(lengthX2).plus(v);
    }

    //将向量沿着N正交分解
    function orthogonal_decomposition_N(v, N){
        var v_paraller_N, v_vertial_N;
        N = N.normalized();
        v_paraller_N = N.times(v.dotProduct(N));
        v_vertial_N = v.minus(v_paraller_N);
        return  [v_paraller_N,v_vertial_N];
    }

    //求两点的距离,a,b都是Qt.vector2d类型
    function distance(a,b){
        return Math.sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y))
    }

}

