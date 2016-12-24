import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.LocalStorage 2.0
import QtQuick.Window 2.2

Column {
	id: root
	padding: 5
	spacing: 5

	property bool activePenalties: false

	// TODO: error checking
	function getSelectedPlayer() { return nameSelect.model.get(nameSelect.currentIndex) }
	function getSelectedTeam() { return teamSelect.model.get(teamSelect.currentIndex) }
	property alias goals: scoreTextField.text
	property var penalties: activePenalties ? penaltiesTextField.text : null

	function updateNames() {
		updateFromDatabase('Players', nameSelect)
	}

	function updateTeams() {
		updateFromDatabase('Teams', teamSelect)
	}

	function updateFromDatabase(table, combobox) {
		var db = LocalStorage.openDatabaseSync("league-db", "1.0", "Database of games recorded using League", 1000000)

		db.transaction(
			function(tx) {
				var rs
				try {
					rs = tx.executeSql('SELECT id, name FROM ' + table);
				} catch (e) {
					return
				}

				for (var i = 0; i < rs.rows.length; ++i) {
					if (combobox.find(rs.rows.item(i).name) === -1) {
						combobox.model.append({'id': rs.rows.item(i).id, 'name': rs.rows.item(i).name})
					}
				}
			}
		)
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
				root.updateFromDatabase('Players', this)
			}

			model: ListModel { }
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
			id: teamSelect
			width: nameSelect.width
			anchors.verticalCenter: parent.verticalCenter
			textRole: 'name'

			Component.onCompleted: {
				root.updateFromDatabase('Teams', this)
			}

			model: ListModel { }
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
			id: scoreTextField
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
			id: penaltiesTextField
			width: nameSelect.width
			anchors.verticalCenter: parent.verticalCenter
			enabled: root.activePenalties
		}
	}
}
