import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2
import SortFilterProxyModel 0.1

import "qml-components"

ApplicationWindow {
	visible: true
	width: 640
	height: 480
	title: qsTr("League - Tournament Management Software")

	property string dbName: "league-db"
	property string dbVer: "1.0"
	property string dbDesc: "Database of games recorded using League"
	property int dbEstSize: 1000000

	Component.onCompleted: {
		var db = LocalStorage.openDatabaseSync(dbName, dbVer, dbDesc, dbEstSize)

		db.transaction(
			function(tx) {
				tx.executeSql(
'CREATE TABLE IF NOT EXISTS Players(id INTEGER PRIMARY KEY NOT NULL,
                                    name TEXT NOT NULL)'
				);

				tx.executeSql(
'CREATE TABLE IF NOT EXISTS Teams(id INTEGER PRIMARY KEY,
                                  name TEXT NOT NULL)'
				);

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

	menuBar: MenuBar {
		Menu {
			title: "Actions"
			MenuItem {
				text: qsTr("Insert New Game...")
				shortcut: "Ctrl+N"
				onTriggered: insertWindow.show()
			}
			MenuItem {
				text: qsTr("Game List")
				shortcut: "Ctrl+L"
				onTriggered: gameListWindow.show()
			}
			MenuItem {
				text: qsTr("Custom Search")
				shortcut: "Ctrl+S"
			}
			MenuSeparator { }
			MenuItem { text: qsTr("About") }
			MenuItem { text: qsTr("Change Language") }
			MenuItem {
				text: qsTr("Exit")
				onTriggered: Qt.quit()
			}
		}
	}

	InsertWindow {
		id: insertWindow
		visible: false
	}

	GameListWindow {
		id: gameListWindow
		visible: false
	}

	ListModel {
		id: listModel
	}

	TableView {
		id: tableView
		width: parent.width
		height: parent.height

		sortIndicatorColumn: 8
		sortIndicatorVisible: true
		sortIndicatorOrder: Qt.DescendingOrder

		model: SortFilterProxyModel {
			id: proxyModel
			source: listModel.count > 0 ? listModel : null

			sortOrder: tableView.sortIndicatorOrder
			sortCaseSensitivity: Qt.CaseInsensitive
			sortRole: listModel.count > 0 ?
					tableView.getColumn(tableView.sortIndicatorColumn).role : ""
		}

		TableViewColumn {
			title: qsTr("#")
			delegate: Text {
				text: styleData.row + 1
				horizontalAlignment: Text.AlignRight
			}
			width: 30
		}

		TableViewColumn {
			title: qsTr("Player")
			role: "name"
			delegate: Text {
				text: styleData.value
				leftPadding: 10
			}
			width: 80
		}

		TableViewColumn {
			title: qsTr("G")
			role: "games"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		TableViewColumn {
			title: qsTr("W")
			role: "wins"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		TableViewColumn {
			title: qsTr("L")
			role: "losses"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		TableViewColumn {
			title: qsTr("F")
			role: "goals"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		TableViewColumn {
			title: qsTr("A")
			role: "goals_against"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		TableViewColumn {
			title: qsTr("GD")
			role: "goal_difference"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		TableViewColumn {
			title: qsTr("WD")
			role: "win_difference"
			delegate: Text {
				text: styleData.value
				horizontalAlignment: Text.AlignRight
			}
			width: 40
		}

		function updateFromDatabase(listModel) {
			var db = LocalStorage.openDatabaseSync(dbName, dbVer, dbDesc, dbEstSize)

			db.transaction(
				function(tx) {
					var rs
					try {
						rs = tx.executeSql(
'SELECT Player_One.name AS player_one, Player_Two.name AS player_two,
	Team_One.name As team_one, Team_Two.name AS team_two,
	Games.goals_one, Games.goals_two,
	Games.penalties_one, Games.penalties_two
FROM Games
JOIN Players AS Player_One ON Player_One.id = Games.player_one
JOIN Players AS Player_Two ON Player_Two.id = Games.player_two
JOIN Teams AS Team_One ON Team_One.id = Games.team_one
JOIN Teams AS Team_Two ON Team_Two.id = Games.team_two'
						);
					} catch (e) {
						console.log("Failure loading games.")
						return
					}

					var playerDict = {}
					for (var i = 0; i < rs.rows.length; ++i) {
						var players =
								[rs.rows.item(i).player_one, rs.rows.item(i).player_two]
						var teams =
								[rs.rows.item(i).team_one, rs.rows.item(i).team_two]
						var goals =
								[rs.rows.item(i).goals_one, rs.rows.item(i).goals_two]
						var penalties =
								[rs.rows.item(i).penalties_one, rs.rows.item(i).penalties_two]

						for (var j = 0; j < 2; ++j) {
							if (!(players[j] in playerDict)) {
								playerDict[players[j]] = {
									name: players[j],
									games: 0,
									wins: 0,
									losses: 0,
									goals: 0,
									goals_against: 0,
									goal_difference: 0,
									win_difference: 0
								}
							}

							playerDict[players[j]].games++

							if (goals[j] > goals[1 - j] || penalties[j] > penalties[1 - j]) {
								playerDict[players[j]].wins++
							} else {
								playerDict[players[j]].losses++
							}

							playerDict[players[j]].goals += goals[j]
							playerDict[players[j]].goals_against += goals[1 - j]
						}
					}

					for (var key in playerDict) {
						playerDict[key].goal_difference =
								playerDict[key].goals - playerDict[key].goals_against
						playerDict[key].win_difference =
								playerDict[key].wins - playerDict[key].losses

						listModel.append(playerDict[key])
					}
				}
			)
		}

		Component.onCompleted: updateFromDatabase(listModel)
	}
}
