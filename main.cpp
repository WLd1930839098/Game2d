#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "mymsg.h"
#include <library.h>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QQmlContext *context = engine.rootContext();
    MyMsg mymsg;
    context->setContextProperty("msg",&mymsg);

    qmlRegisterType<MyMsg>("com.bins.mymsg",1,0,"Message");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    hello();
    return app.exec();
}
