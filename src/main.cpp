#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "sortfilterproxymodel.h"

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);

	qmlRegisterType<SortFilterProxyModel>("SortFilterProxyModel", 0, 1, "SortFilterProxyModel");

	QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

	return app.exec();
}
