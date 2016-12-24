import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

Column {
	id: root
	padding: 5
	spacing: 5

	property bool activePenalties: false

	Window {
		id: newDataWindow
		width: 250
		height: 25
		visible: false
		modality: Qt.ApplicationModal

		onVisibleChanged: if (visible) { newDataInput.text = '' }

		TextField {
			id: newDataInput
			anchors.fill: parent
			focus: true
		}
	}

	Row {
		id: nameRow
		spacing: 5

		Label {
			id: nameLabel
			width: 55
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Name: ")
		}

		ComboBox {
			id: nameSelect
			width: 120
			anchors.verticalCenter: parent.verticalCenter
			textRole: 'name'

			Component.onCompleted: {
				updateDatabase()
			}

			model: ListModel {
				id: listModel
			}

			function updateDatabase() {
				var db = LocalStorage.openDatabaseSync("league-db", "1.0", "Database of games recorded using League", 1000000)

				db.transaction(
					function(tx) {
						var rs = tx.executeSql('SELECT id, name FROM Players');

						for (var i = 0; i < rs.rows.length; ++i) {
							if (nameSelect.find(rs.rows.item(i).name) === -1) {
								nameSelect.model.append({'id': rs.rows.item(i).id, 'name': rs.rows.item(i).name})
							}
						}
					}
				)
			}
		}

		Button {
			id: newNameButton
			width: 30
			anchors.verticalCenter: parent.verticalCenter
			text: "+"

			onClicked: {
				newDataWindow.visible = true
				newDataWindow.title = qsTr("Enter New Player Name")
				newDataInput.accepted.connect(newPlayer)
			}

			signal newPlayer
			onNewPlayer: {
				newDataInput.accepted.disconnect(newPlayer)
				var db = LocalStorage.openDatabaseSync("league-db", "1.0", "Database of games recorded using League", 1000000)

				db.transaction(
					function(tx) {
						tx.executeSql('INSERT INTO Players (name) VALUES ("' + newDataInput.text + '")'); //TODO: fix obvious SQL injection
					}
				)
				newDataWindow.visible = false
				nameSelect.updateDatabase()
			}
		}
	}

	Row {
		spacing: nameRow.spacing

		Label {
			width: nameLabel.width
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Team: ")
		}

		ComboBox {
			width: nameSelect.width
			anchors.verticalCenter: parent.verticalCenter
			model: [ "ARS", "CXI", "FCB" ]
		}

		Button {
			width: newNameButton.width
			anchors.verticalCenter: parent.verticalCenter
			text: "+"

			onClicked: {
				newDataWindow.visible = true
				newDataWindow.title = qsTr("Enter New Team Name")
				newDataInput.accepted.connect(newTeam)
			}

			signal newTeam
			onNewTeam: {
				var db = LocalStorage.openDatabaseSync("league-db", "1.0", "Database of games recorded using League", 1000000)

				db.transaction(
					function(tx) {
						tx.executeSql('INSERT INTO Teams (name) VALUES ("' + newDataInput.text + '")');
					}
				)
				newDataWindow.visible = false
			}
		}
	}

	Row {
		spacing: nameRow.spacing

		Label {
			width: nameLabel.width
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Score: ")
		}

		TextField {
			width: nameSelect.width
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	Row {
		spacing: nameRow.spacing

		Label {
			width: nameLabel.width
			anchors.verticalCenter: parent.verticalCenter
			text: qsTr("Penalties: ")
			enabled: root.activePenalties
		}

		TextField {
			width: nameSelect.width
			anchors.verticalCenter: parent.verticalCenter
			enabled: root.activePenalties
		}
	}
}
