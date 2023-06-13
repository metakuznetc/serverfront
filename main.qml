import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 800
    height: 350
    title: "Простейший интерфейс"
    color: "#FFE4B5"

    RowLayout {
        anchors.centerIn: parent
        spacing: 10

        // список managers
        ColumnLayout {
            width: parent.width / 2
            spacing: 10

            TextField {
                id: nameInput
                placeholderText: "Введите имя"
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
            }

            Button {
                id: button
                text: "Получить список"
                onClicked: {
                    fetchDataFromServerNameWithDelay()
                }
                background: Rectangle {
                    color: "#edd29e" // Цвет фона
                    border.color: "#D2B48C"
                    implicitWidth: 200
                }
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
            }

            ListView {
                id: listView
                width: 300
                height: 200

                model: ListModel {
                    id: listModel
                }

                delegate: Item {
                    width: listView.width
                    height: 30

                    Rectangle {
                        color: "#ADD8E6"

                        anchors.fill: parent
                        anchors.margins: 5

                        Text {
                            text: model.id
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: model.name
                            anchors.centerIn: parent
                        }

                        Text {
                            text: model.family
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        // summ
        Column {
            width: parent.width / 2
            spacing: 10

            TextField {
                id: aInput
                placeholderText: "Введите a"
                width: 200
            }

            TextField {
                id: bInput
                placeholderText: "Введите b"
                width: 200
            }

            Button {
                text: "Открыть модальное окно"
                onClicked: {
                    fetchDataFromServerSumWithDelay()
                }
                background: Rectangle {
                    color: "#edd29e" // Цвет фона
                    border.color: "#D2B48C"
                    implicitWidth: 200
                }
            }

            Label {
                id: resultLabel
                text: ""
            }
        }
    }

    Popup {
        id: loadingPopup
        width: 100
        height: 100
        modal: true
        visible: false
        focus: true

        AnimatedImage {
            source: "load.gif"
            width: 100
            height: 100
            fillMode: AnimatedImage.PreserveAspectFit
        }
    }

    Dialog {
            id: resultDialog
            title: "Результат"
            standardButtons: Dialog.Ok
            contentItem: Text {
                text: resultLabel.text
                wrapMode: Text.WordWrap
            }
            onAccepted: {
                resultDialog.visible = false
            }
        }

    function fetchDataFromServerName() {
        var name = nameInput.text;
        var url = "http://localhost:8080/api/v1/managers?name=" + encodeURIComponent(name);

        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    listModel.clear();
                    for (var i = 0; i < response.length; i++) {
                        listModel.append({
                            "id": response[i].id,
                            "name": response[i].name,
                            "family": response[i].family
                        });
                    }
                } else {
                    console.error("Ошибка запроса к серверу");
                }
            }
        };

        xhr.open("GET", url);
        xhr.send();
    }

    function fetchDataFromServerNameWithDelay() {
        var delay = 3000;

        loadingPopup.visible = true;

        var timer = Qt.createQmlObject('import QtQuick 2.15; Timer {}', loadingPopup);
        timer.interval = delay;
        timer.repeat = false;
        timer.triggered.connect(function() {
            loadingPopup.visible = false;
            fetchDataFromServerName();
        });
        timer.start();
    }

    function fetchDataFromServerSum() {
        var a = aInput.text;
        var b = bInput.text;

        var url = "http://localhost:8080/api/v1/get_sum?a=" + a + "&b=" + b;
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    var response = JSON.parse(xhr.responseText);
                    var result = response.sum;
                    resultLabel.text = "Результат: " + result;
                    resultDialog.visible = true;
                } else {
                    console.error("Ошибка запроса к серверу");
                }
            }
        };
        xhr.open("GET", url, true);
        xhr.send();
    }

    function fetchDataFromServerSumWithDelay() {
        var delay = 3000;

        loadingPopup.visible = true;

        var timer = Qt.createQmlObject('import QtQuick 2.15; Timer {}', loadingPopup);
        timer.interval = delay;
        timer.repeat = false;
        timer.triggered.connect(function() {
            loadingPopup.visible = false;
            fetchDataFromServerSum();
        });
        timer.start();
    }
}
