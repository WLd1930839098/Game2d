#ifndef MYMSG_H
#define MYMSG_H

#include <QObject>
#include <QDebug>

class MyMsg : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString message READ getMessage WRITE setMessage NOTIFY msgChanged)
public:
    explicit MyMsg(QObject *parent = nullptr);
    Q_INVOKABLE bool postMsg(const QString msg);
    QString getMessage();
    void setMessage(QString msg);

signals:
    void msgChanged();
public slots:
    void refresh();

private:
    QString msg;
};

#endif // MYMSG_H
