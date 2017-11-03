import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2
import SortFilterProxyModel 0.1

Window {
	id: insertWindow
	width: 620
	height: 400
	title: qsTr("League - Game List")
	modality: Qt.ApplicationModal
	color: "white"

	onVisibleChanged: if (visible) { tableView.updateFromDatabase(listModel) }

	ListModel {
		id: listModel
	}

	TableView {
		id: tableView
		width: parent.width
		height: parent.height

		sortIndicatorVisible: true
		sortIndicatorOrder: Qt.DescendingOrder
		sortIndicatorColumn: 0

		model: SortFilterProxyModel {
			id: proxyModel
			source: listModel.count > 0 ? listModel : null

			sortOrder: tableView.sortIndicatorOrder
			sortCaseSensitivity: Qt.CaseInsensitive
			sortRole: listModel.count > 0 ?
					tableView.getColumn(tableView.sortIndicatorColumn).role : ""
		}

		TableViewColumn {
			title: qsTr("Date")
			role: "date"
			width: 80
		}

		TableViewColumn {
			title: qsTr("Player A")
			role: "playerA"
			width: 70
		}

		TableViewColumn {
			title: qsTr("Player B")
			role: "playerB"
			width: 70
		}

		TableViewColumn {
			title: qsTr("Team A")
			role: "teamA"
			width: 60
		}

		TableViewColumn {
			title: qsTr("Team B")
			role: "teamB"
			width: 60
		}

		TableViewColumn {
			title: qsTr("Goals")
			role: "goals"
			width: 60
			horizontalAlignment: Text.AlignRight
		}

		TableViewColumn {
			title: qsTr("Penalties")
			role: "penalties"
			width: 80
			horizontalAlignment: Text.AlignRight
		}

		function updateFromDatabase(listModel) {
			var db = LocalStorage.openDatabaseSync(dbName, dbVer, dbDesc, dbEstSize)

			db.transaction(
				function(tx) {
					var rs
					try {
						rs = tx.executeSql(
'SELECT Games.id, Games.date,
	Player_One.name AS player_one, Player_Two.name AS player_two,
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
						playerDict[rs.rows.item(i).id] = {
							date: rs.rows.item(i).date,
							playerA: rs.rows.item(i).player_one,
							playerB: rs.rows.item(i).player_two,
							teamA: rs.rows.item(i).team_one,
							teamB: rs.rows.item(i).team_two,
							goals: rs.rows.item(i).goals_one + ":" + rs.rows.item(i).goals_two,
							penalties: rs.rows.item(i).penalties_one === null ? "" :
									rs.rows.item(i).penalties_one + ":" +
									rs.rows.item(i).penalties_two
						}
					}

					listModel.clear()
					for (var key in playerDict) {
						listModel.append(playerDict[key])
					}
				}
			)
		}

		Component.onCompleted: updateFromDatabase(listModel)
	}
}
