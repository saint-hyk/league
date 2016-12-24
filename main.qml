import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

import "qml-components"

ApplicationWindow {
	visible: true
	width: 640
	height: 480
	title: qsTr("League - Tournament Management Software")
	color: "white"

	menuBar: MenuBar {
		Menu {
			title: "Actions"
			MenuItem {
				text: qsTr("Insert New Game...")
				shortcut: "Ctrl+N"
				onTriggered: insertWindow.show()
			}
			MenuItem { text: qsTr("Custom Search") }
			MenuSeparator { }
			MenuItem { text: qsTr("About") }
			MenuItem { text: qsTr("Change Language") }
			MenuItem {
				text: qsTr("Exit")
				onTriggered: Qt.quit()
			}
		}
	}

	Component.onCompleted: {
		var db = LocalStorage.openDatabaseSync("league-db", "1.0", "Database of games recorded using League", 1000000)

		db.transaction(
			function(tx) {
				tx.executeSql('CREATE TABLE IF NOT EXISTS Players(id INTEGER PRIMARY KEY NOT NULL, name TEXT NOT NULL)');
				tx.executeSql('CREATE TABLE IF NOT EXISTS Teams(id INTEGER PRIMARY KEY, name TEXT NOT NULL)');
				tx.executeSql(
'CREATE TABLE IF NOT EXISTS Games(id INTEGER PRIMARY KEY,
                         date TEXT NOT NULL,
                         player_one INT NOT NULL,
                         player_two INT NOT NULL,
                         team_one INT NOT NULL,
                         team_two INT NOT NULL,
                         goals_one INT NOT NULL,
                         goals_two INT NOT NULL,
                         penalties_one INT,
                         penalties_two INT,
                         FOREIGN KEY(player_one) REFERENCES Players(id),
                         FOREIGN KEY(player_two) REFERENCES Players(id),
                         FOREIGN KEY(team_one) REFERENCES Teams(id),
                         FOREIGN KEY(team_two) REFERENCES Teams(id))'
					);
			}
		)
	}

	InsertWindow {
		id: insertWindow
		visible: false
	}
}
