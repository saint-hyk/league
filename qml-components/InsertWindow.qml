import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

import "window-components"

Window {
	id: insertWindow
	width: 452
	height: 182
	title: qsTr("League - Insert New Game")
	modality: Qt.ApplicationModal
	color: "white"

	Window {
		id: calendarWindow
		width: 400
		height: 200
		visible: false
		title: qsTr("Select Date")

		onActiveChanged: if (!active) { visible = false }

		Calendar {
			id: calendar
			anchors {
				top: parent.top
				left: parent.left
				right: parent.right
			}

			onSelectedDateChanged: dateButton.text = selectedDate.toDateString()
			onDoubleClicked: calendarWindow.visible = false
		}
	}

	Row {
		id: topRow
		height: 50
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		spacing: 5

		Label {
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Date:")
		}

		Button {
			id: dateButton
			anchors.verticalCenter: parent.verticalCenter
			text: new Date().toDateString()

			onClicked: calendarWindow.show()
		}

		Separator {
			height: topRow.height - 20
			anchors.verticalCenter: parent.verticalCenter
		}

		Button {
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Toggle Penalties")
			onClicked: {
				playerEntryColumnA.activePenalties = !playerEntryColumnA.activePenalties
				playerEntryColumnB.activePenalties = !playerEntryColumnB.activePenalties
			}
		}

		Separator {
			height: topRow.height - 20
			anchors.verticalCenter: parent.verticalCenter
		}

		Button {
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Add Game")

			//onClicked: console.log(insertWindow.width + ", " + insertWindow.height)
			onClicked: {
				var db = LocalStorage.openDatabaseSync("league-db", "1.0", "Database of games recorded using League", 1000000)

				db.transaction(
					function(tx) {
						tx.executeSql('INSERT INTO Players (name) VALUES ("Harold"), ("Ali")');
						tx.executeSql('INSERT INTO Teams (name) VALUES ("ARS"), ("CXI")');
						tx.executeSql('INSERT INTO Games (date, player_one, player_two, team_one, team_two, goals_one, goals_two) VALUES ("2016-12-17", 1, 2, 1, 2, 5, 2)');

						//var rs = tx.executeSql('SELECT Games.id, Games.date, Player_One.name AS player_one, Player_Two.name AS player_two, Games.goals_one, Games.goals_two FROM Games JOIN Players AS Player_One ON Player_One.id = Games.player_one JOIN Players AS Player_Two ON Player_Two.id = Games.player_two');
						var rs = tx.executeSql('SELECT Players.id, Players.name FROM Players');

						var r = ""
						for(var i = 0; i < rs.rows.length; i++) {
							r += rs.rows.item(i).id + ": " + rs.rows.item(i).name + "\n"
						}
						console.log(r)
					}
				)
			}
		}
	}

	Row {
		anchors {
			top: topRow.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		PlayerEntryColumn {
			id: playerEntryColumnA
		}

		Separator {
			height: parent.height - 20
			anchors.verticalCenter: parent.verticalCenter
		}

		PlayerEntryColumn {
			id: playerEntryColumnB
		}
	}
}
