#include "mymsg.h"

MyMsg::MyMsg(QObject *parent) : QObject(parent)
{

}

bool MyMsg::postMsg(const QString msg)
{
    qDebug()<<"Called the C++ method with the message: "<<msg;
    return true;
}

QString MyMsg::getMessage()
{
    return msg;
}

void MyMsg::setMessage(QString msg)
{
    if(this->msg!=msg)
    {
        this->msg=msg;
        emit msgChanged();
    }
}

void MyMsg::refresh()
{
    qDebug()<<"Called the C++ slot";
}
